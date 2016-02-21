var dotenv = require('dotenv');
dotenv.load();
var express = require('express');
var bodyParser = require('body-parser');
var colors = require('colors');
var fs = require('fs');
var os = require('os');
var path = require('path');
var prettyjson = require('prettyjson');
var querystring = require('querystring');
var request = require('request');

var port = 3000;

// shell commands
require('shelljs/global');

var app = express();
app.use(bodyParser({limit: '50mb'}));
app.use(express.static(__dirname + '/uploaded_data'));
app.use("/", express.static(__dirname + '/landing'));
app.use(function(req, res, next) { // enable CORS
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  res.setHeader('Content-Type', 'application/json');
  next();
});

mkdir(__dirname+'/uploaded_data');

// for getting network data
var ifaces = os.networkInterfaces();

app.post('/food-analysis', function (req, res) {
  if (req.body.image) {
    var imageID = generatePushID();
    fs.writeFile(__dirname+'/uploaded_data/'+imageID+'.jpeg', req.body.image, 'base64', function (err) {
      if (err) throw err;
      var image_url = process.env.HOSTNAME+"/uploaded_img/"+imageID+".jpeg";
      console.log(image_url);
      // recognize image
      request.post('http://usekenko.co:3005/remote-identify',{form: {'image_url': image_url}}, function (e, r, b) {
        if (!e && r.statusCode == 200) {
            var caption = "a " + JSON.parse(b).name;
            console.log(caption);
          
	    request.post("http://gateway-a.watsonplatform.net/calls/text/TextGetRankedTaxonomy", {"form": {"apikey":process.env.ALCHEMY_KEY, "text": caption, "outputMode": "json"}}, function (errorAl, resAl, bodyAl) {
		bodyAl = JSON.parse(bodyAl);
		if (bodyAl["status"] != "ERROR") {
		    del = bodyAl["taxonomy"][0].label;
		    var foodDelegate;
		    if (del.indexOf("food") > -1 || del.indexOf("drink") > -1 || del.indexOf("beverage") > -1) {
			foodDelegate = "FOOD";
		    } else {
			foodDelegate = "NOT FOOD";
		    }
		    
		    console.log(foodDelegate);

		    if (foodDelegate == "UNKNOWN") {
			res.send({"Error": "Cannot verify food image.", "object": caption});
		    } else if (foodDelegate == "NOT FOOD") {
			res.send({"Error": "That is not food.", "object": caption});
		    } else if (foodDelegate) { // aha! I see that it is food!
			// Run nutrition database search
			request.post("http://usekenko.co:3006/nutritionize", {form: {"query": caption}}, function (nutriErr, nutriRes, nutriBody) {
			    // console.log(nutriRes.statusCode);
			    if (!nutriErr && nutriRes.statusCode == 200) {
				console.log(JSON.parse(nutriBody).NUTRITION_LABEL);
				res.send(nutriBody); // send the nutrition label
			    } else {
				res.send({"Error": "Error processing image.", "object": caption});
			    }
			}); // end nutrition search
		    } // end if FOOD
		} else {
		    console.log("Food recognizer returned error");
		    res.send({"Error": "That is not food.", "object": caption});
		}
		}); // end alchemy
	} else {
	    res.send({"Error": "Error processing image."});
	}
      });
    });
  } else {
    res.send({"Error": "Missing parameters."})
  }
}); // end food-analysis


app.get('/uploaded_img/:id', function (req, res) {
  res.set('Content-Type', 'application/jpeg');
  res.sendFile(__dirname + "/uploaded_data/" +req.param('id'));
});


app.get("/saved-user-data", function (req, res) {
  res.setHeader('Content-Type', 'application/json');

  var finalJSON = [];
  var savedContents = ls(__dirname+'/user_cache');
  console.log(savedContents);

  if (savedContents.length > 0) {
    var fileIndex = 0;
    loopJSON();

    function loopJSON() {
      console.log(savedContents[fileIndex]);
      fs.readFile(__dirname+"/user_cache/"+savedContents[fileIndex], "utf-8", function (err, data) {
        if (err) throw err;

        finalJSON.push(JSON.parse(data));
        rm('-rf', __dirname+"/user_cache/"+savedContents[fileIndex]);

        if (fileIndex < savedContents.length-1) {
          fileIndex++;
          loopJSON();
        } else {
          res.send(JSON.stringify(finalJSON));
        }
      });

    }
  } else {
    res.setHeader('Content-Type', 'application/text');
    res.send("No new content.");
  }
});



// fire up the server
var server = app.listen(port, function () {
  Object.keys(ifaces).forEach(function (ifname) {
    var alias = 0;
    ifaces[ifname].forEach(function (iface) {
      if ('IPv4' !== iface.family || iface.internal !== false) {
        return;
      }
      console.log(("Server running on "+iface.address+":"+port).blue);
    });
  });
});


generatePushID = (function() {
  var PUSH_CHARS = '-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz';
  var lastPushTime = 0;
  var lastRandChars = [];
  return function() {
    var now = new Date().getTime();
    var duplicateTime = (now === lastPushTime);
    lastPushTime = now;
    var timeStampChars = new Array(8);
    for (var i = 7; i >= 0; i--) {
      timeStampChars[i] = PUSH_CHARS.charAt(now % 64);
      now = Math.floor(now / 64);
    }
    if (now !== 0) throw new Error('We should have converted the entire timestamp.');
    var id = timeStampChars.join('');
    if (!duplicateTime) {
      for (i = 0; i < 12; i++) {
        lastRandChars[i] = Math.floor(Math.random() * 64);
      }
    } else {
      for (i = 11; i >= 0 && lastRandChars[i] === 63; i--) {
        lastRandChars[i] = 0;
      }
      lastRandChars[i]++;
    }
    for (i = 0; i < 12; i++) {
      id += PUSH_CHARS.charAt(lastRandChars[i]);
    }
    if(id.length != 20) throw new Error('Length should be 20.');

    return id;
  };
})();

function toTitleCase(str)
{
    return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
}
