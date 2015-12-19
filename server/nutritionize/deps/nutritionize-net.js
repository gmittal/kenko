// Copyright 2016 Gautam Mittal
// This is the networking interface for Nutritionix
var width = 1024;
var height = 1024;
var page = require('webpage').create(),
system = require('system'),
fs = require('fs');

function evaluate(page, func) {
    var args = [].slice.call(arguments, 2);
    var fn = "function() { return (" + func.toString() + ").apply(this, " + JSON.stringify(args) + ");}";
    return page.evaluate(fn);
}

page.open("http://www.nutritionix.com/search?q="+encodeURI(system.args[1]), function (status) {
  if (status !== 'success') {
        console.log('Unable to access network');
    } else {
        var address = system.args[1];
        var results = page.evaluate(function(address) {
            var pizza = "http://www.nutritionix.com" + $(".list-search-results li:nth-child(1) > a").attr("href");
            return pizza;
        }, address);

        var detailPage = require('webpage').create();
        detailPage.open(results, function (s) {
          // prepare the screenshot of the label
          detailPage.viewportSize = {width: width, height: height};


          var labelDimensions = detailPage.evaluate(function (w, h) {
            document.body.style.width = w + "px";
            document.body.style.height = h + "px";
            return {height: $(".nutritionLabel").height(), width: $(".nutritionLabel").width()};
          }, width, height);
          // console.log(JSON.stringify(labelDimensions));

          detailPage.clipRect = {top: 0, left: 0, width: width, height: height};

          var labelUUID = generatePushID();
          detailPage.render("nutritionize/labels/"+labelUUID+".png");

          console.log(JSON.stringify({size: labelDimensions, rawImage_path: fs.workingDirectory+"/nutritionize/labels/"+labelUUID+".png"}));
          phantom.exit();
        }); // end detailPage

    }
});


function renderCurrentViewport(page, filename) {
  var viewportSize = page.viewportSize;
  var scrollOffsets = page.evaluate(function() {
    return {
      x: window.pageXOffset,
      y: window.pageYOffset
    };
  });
  page.clipRect = {
    top: scrollOffsets.y,
    left: scrollOffsets.x,
    height: viewportSize.height,
    width: viewportSize.width
  };
  page.render(filename);
}

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
