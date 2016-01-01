// Copyright 2016 Gautam Mittal
// $ npm install
// Requires node-canvas installed
// Requires the custom build of PhantomJS included in the directory

var bodyParser = require('body-parser');
var express = require('express');
var fs = require('fs');
var img = require('cropng');
require('shelljs/global');
var app = express();
var port = 3005;
app.use(bodyParser.json({limit:'50mb', extended: true}));
app.use(bodyParser.urlencoded({limit:'50mb', extended: true}));
app.use(function(req, res, next) { // enable CORS
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  res.setHeader('Content-Type', 'application/json');
  next();
});


// Send search query, receive awesomeness back
app.post('/nutritionize', function (req, res) {
  if (req.body.query) {
        var netResult = JSON.parse(exec('./phantomjs deps/nutritionize-net.js "'+ searchQuery +'"', {silent:true}).output);

        var png = new img(netResult.rawImage_path);

        png.crop({x:60, y:187, height: netResult.size.height+16, width: netResult.size.width+16}, function (err, image) {
        	fs.writeFile(netResult.rawImage_path, image.data, function (err) {
        	    if (err) console.log(err);
        	    var uploaded_image = exec('curl -F "file=@'+netResult.rawImage_path+'" https://file.io', {silent:true}).output.split("\n");
              rm('-rf', netResult.rawImage_path); // delete what is now stored in the cloud
              res.send({"label":JSON.parse(uploaded_image[uploaded_image.length-1]).link});

        	});
        });
  } else {
    res.send({"Error": "You mad?"});
  }
});
