// Copyright 2016 Gautam Mittal
// $ npm install
// Requires node-canvas installed
// Requires the custom build of PhantomJS included in the directory
// Execute outside of the nutritionize directory like so:
// $ node nutritionize/nutritionize.js "FOOD ITEM"
var fs = require('fs');
var img = require('cropng');
require('shelljs/global');

var searchQuery = process.argv[2];
if (searchQuery) {
    var netResult = JSON.parse(exec('nutritionize/./phantomjs nutritionize/deps/nutritionize-net.js "'+ searchQuery +'"').output);

    var png = new img(netResult.rawImage_path);

    png.crop({x:57, y:184, height: netResult.size.height+22, width: netResult.size.width+22}, function (err, image) {
	fs.writeFile(netResult.rawImage_path, image.data, function (err) {
	    if (err) console.log(err);
	});
    });

} else {
  console.log("Missing parameters.");
  process.exit();
}
