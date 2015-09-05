var dotenv = require('dotenv');
dotenv.load();

var express = require('express');
var bodyParser = require('body-parser');
var colors = require('colors');
var fs = require('fs');
var os = require('os');
var querystring = require('querystring');
var request = require('request');

// shell commands
require('shelljs/global');

var app = express();
app.use(bodyParser({limit: '50mb'}));
app.use(express.static(__dirname + '/uploaded_data'));
app.use(function(req, res, next) { // enable CORS
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  res.setHeader('Content-Type', 'application/json');
  next();
});


var port = 3000;

// for getting network data
var ifaces = os.networkInterfaces();

app.get('/', function (req, res) {
  res.send('Hello World!');
});

app.post('/food-analysis', function (req, res) {
  res.setHeader('Content-Type', 'application/json');

  if (req.body.image) {
    console.log(req.body.image);

    var imageID = generatePushID(); // generate a unique token for each image

    fs.writeFile(__dirname+'/uploaded_data/'+imageID+'.jpeg', req.body.image, 'base64', function (err) {
      if (err) throw err;
      console.log('Image successfully uploaded.'.green);
      console.log((process.env.HOSTNAME+"/uploaded_img/"+imageID).blue);

      var form = {
          'image_request[remote_image_url]': process.env.HOSTNAME+"/uploaded_img/"+imageID+".jpeg",
          "image_request[locale]": "en-US"
      };

      var formData = querystring.stringify(form);
      var contentLength = formData.length;

      console.log(process.env.CLOUDSIGHT_KEY);


        request({
            headers: {
              'Authorization': 'CloudSight '+ process.env.CLOUDSIGHT_KEY,
              'Content-Length': contentLength,
              'Content-Type': 'application/x-www-form-urlencoded'
            },
            uri: 'https://api.cloudsightapi.com/image_requests',
            body: formData,
            method: 'POST'
          }, function (err, res, body) {
            //it works!
            if (err) {
              res.send({"Error": "There was an error from images-request"})
            } else {
              console.log(body);
              var resToken = JSON.parse(body).token;

              console.log("Processing image information...".cyan);

              loopResponseCloud();
              function loopResponseCloud() {
                  request({url: "https://api.cloudsightapi.com/image_responses/"+resToken, headers: {'Authorization': 'CloudSight '+ process.env.CLOUDSIGHT_KEY}}, function (resError, resResponse, resBody) {
                      if (JSON.parse(resBody).status == "not completed") {
                        loopResponseCloud();
                      } else {
                        console.log(resBody);
                        if (typeof resBody.name !== "undefined") {
                          console.log((JSON.parse(resBody).name).green);
                        } else {
                          res.send({"Error": "There was an error."});
                        }




                      }
                  });
                }

            }

          });




    });


  }
});

app.get('/uploaded_img/:id', function (req, res) {
  res.set('Content-Type', 'application/jpeg');
  res.sendFile(__dirname + "/uploaded_data/" +req.param('id'));
});


// start the server
var server = app.listen(port, function () {
  Object.keys(ifaces).forEach(function (ifname) {
    var alias = 0;

    ifaces[ifname].forEach(function (iface) {
      if ('IPv4' !== iface.family || iface.internal !== false) {
        // skip over internal (i.e. 127.0.0.1) and non-ipv4 addresses
        return;
      }

      // this interface has only one ipv4 adress
      console.log(("Server running on "+iface.address+":"+port).blue);


    });
  });
});


// uuid generation
generatePushID = (function() {
  // Modeled after base64 web-safe chars, but ordered by ASCII.
  var PUSH_CHARS = '-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz';

  // Timestamp of last push, used to prevent local collisions if you push twice in one ms.
  var lastPushTime = 0;

  // We generate 72-bits of randomness which get turned into 12 characters and appended to the
  // timestamp to prevent collisions with other clients.  We store the last characters we
  // generated because in the event of a collision, we'll use those same characters except
  // "incremented" by one.
  var lastRandChars = [];

  return function() {
    var now = new Date().getTime();
    var duplicateTime = (now === lastPushTime);
    lastPushTime = now;

    var timeStampChars = new Array(8);
    for (var i = 7; i >= 0; i--) {
      timeStampChars[i] = PUSH_CHARS.charAt(now % 64);
      // NOTE: Can't use << here because javascript will convert to int and lose the upper bits.
      now = Math.floor(now / 64);
    }
    if (now !== 0) throw new Error('We should have converted the entire timestamp.');

    var id = timeStampChars.join('');

    if (!duplicateTime) {
      for (i = 0; i < 12; i++) {
        lastRandChars[i] = Math.floor(Math.random() * 64);
      }
    } else {
      // If the timestamp hasn't changed since last push, use the same random number, except incremented by 1.
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
