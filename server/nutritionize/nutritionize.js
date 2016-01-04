// Copyright 2016 Gautam Mittal
// $ npm install
// Requires a simple HTTP server running on port 4001 in the label_templates directory
var dotenv = require('dotenv');
dotenv.load();
var bodyParser = require('body-parser');
var express = require('express');
var fs = require('fs');
var img = require('cropng');
require('shelljs/global');
var app = express();
var port = 3006;
app.use(bodyParser.json({extended: true}));
app.use(bodyParser.urlencoded({extended: true}));
app.use("/", express.static(__dirname + "/label_templates"));
app.use(function(req, res, next) { // enable CORS
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  res.setHeader('Content-Type', 'application/json');
  next();
});

mkdir('label_templates');
// Send search query, receive awesomeness back
app.post('/nutritionize', function (req, res) {
  if (req.body.query) {
        var searchQuery = req.body.query;
        var netResult = exec('phantomjs --web-security=no --ssl-protocol=any --ignore-ssl-errors=yes deps/nutritionize-net.js "'+ searchQuery +'"', {silent:true}).output;

        var uuid = generatePushID();
        fs.writeFile(__dirname + "/label_templates/"+uuid+".json", netResult, function (err) {
          if (err) throw err;
          fs.readFile("deps/label.html", "utf-8", function (e, d) {
            if (e) throw e;
            fs.writeFile("label_templates/"+uuid+".html", d, function (error) {
              if (error) throw error;
              console.log("Successfully created template: " + uuid);
              console.log(process.env.HOSTNAME+"/"+uuid+".html");
              var photo = JSON.parse(exec('phantomjs deps/camera.js http://localhost:4001/'+uuid+'.html', {silent:false}).output);

              var uploaded_image = exec('curl -F "file=@'+photo.rawImage_path+'" https://file.io', {silent:true}).output.split("\n");
              rm('-rf', photo.rawImage_path); // delete what is now stored in the cloud
              console.log(JSON.parse(uploaded_image[uploaded_image.length-1]).link);
              res.send({"label":JSON.parse(uploaded_image[uploaded_image.length-1]).link});
            });
          });


        });
  } else {
    res.send({"Error": "You mad?"});
  }
});

var server = app.listen(port, function () {
  var host = server.address().address;
  var port = server.address().port;
  console.log('Subtly listening at port '+port+'...');
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
  };})();
