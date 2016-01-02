// Copyright 2016 Gautam Mittal
// Meant to be run only on the usekenko.co server
var request = require('request');
var natural = require('natural');
var fs = require('fs');
require('shelljs/global');

var classifier = new natural.BayesClassifier();

var food_urls = [];
var nonfood_urls = [];
fs.readFile(__dirname+'/training_data/imagenet.drink[food].txt', 'utf-8', function (err, data) {
    if (err) throw err;
    food_urls = data.split("\n");
    fs.readFile(__dirname+'/training_data/imagenet.food[food].txt', 'utf-8', function (e, d) {
      if (err) throw err;
      var f = d.split("\n");
      food_urls = food_urls.concat(f);
      fs.readFile(__dirname+'/training_data/imagenet.urban[not-food].txt', 'utf-8', function (error, ndata) {
        if (err) throw err;
        nonfood_urls = ndata.split("\n");

        // init training
        trainFoodClassifier();
      });
    });
});

function trainFoodClassifier() {
  for (var i = 0; i < food_urls.length; i++) {
    console.log('visualize "'+food_urls[i]).output+'"');
    var caption = JSON.parse(exec('phantomjs ~/visual-search-god-api/visualize.js "'+food_urls[i]).output+'"').name;
    classifier.addDocument(caption, 'food');
    console.log(((i/food_urls.length)*100)+"% -- " + food_urls[i]);
  }
}
