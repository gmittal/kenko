var dotenv = require('dotenv');
dotenv.load();
var bodyParser = require('body-parser');
var express = require('express');
var fs = require('fs');
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

app.post('/sms-analyze', function (req, res) {
	if (req.body.MediaUrl0) {
		console.log(req.body.MediaUrl0);

    request({url: req.body.MediaUrl0, encoding: null}, function (e, r, b) {
        var a = new Buffer(b).toString('base64');
        request.post("http://usekenko.co/food-analysis", {form: {"image": a}}, function (nutriError, nutriRes, nutriBody) {
          console.log(JSON.parse(nutriBody).NUTRITION_LABEL);
          client.messages.create({
              body: "",
              to: req.body.From,
              from: responseNumber,
              mediaUrl: JSON.parse(nutriBody).NUTRITION_LABEL
          }, function(err, message) {
            console.log(err);
          });
        });
    });

	} else {

		client.messages.create({
		    body: "Kenko needs a picture (MMS) to process...",
		    to: req.body.From,
		    from: responseNumber,
		}, function(err, message) {
			if (err) console.log(err);
		});
	}

});

var server = app.listen(port, function () {
  var host = server.address().address;
  var port = server.address().port;

  console.log('Kenko SMS listening at http://localhost:%s', port);
});
