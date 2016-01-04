var dotenv = require('dotenv');
dotenv.load();
var bodyParser = require('body-parser');
var express = require('express');
var request = require('request');
var twilio = require('twilio');
var app = express();

var port = 3008;
var client = require('twilio')(process.env.TWILIO_SID, process.env.TWILIO_AUTHTOKEN);
var responseNumber = process.env.TWILIO_NUMBER;

app.use(bodyParser({limit: '50mb'}));
app.use(function(req, res, next) { // enable CORS
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  res.setHeader('Content-Type', 'application/json');
  next();
});

app.get('/sms-analyze', function (req, res) {
  res.send('Hello World!');
});

var server = app.listen(port, function () {
  var host = server.address().address;
  var port = server.address().port;

  console.log('Kenko SMS listening at http://%s:%s', host, port);
});
