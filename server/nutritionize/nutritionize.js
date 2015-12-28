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
    var netResult = JSON.parse(exec('nutritionize/./phantomjs nutritionize/deps/nutritionize-net.js "'+ searchQuery +'"', {silent:true}).output);

    var png = new img(netResult.rawImage_path);

    png.crop({x:60, y:187, height: netResult.size.height+16, width: netResult.size.width+16}, function (err, image) {
	fs.writeFile(netResult.rawImage_path, image.data, function (err) {
	    if (err) console.log(err);
	    var uploaded_image = exec('curl -F "file=@'+netResult.rawImage_path+'" https://file.io', {silent:true}).output.split("\n");
	    console.log(JSON.parse(uploaded_image[uploaded_image.length-1]).link);
	    rm('-rf', netResult.rawImage_path); // delete what is now stored in the cloud
	    process.exit();
	});
    });

} else {
  console.log("Missing parameters.");
  process.exit();
}
