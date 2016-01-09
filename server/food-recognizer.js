// Copyright 2016 Gautam Mittal
// Food recognizer
// Command line tool that tells you whether something is food or not
// Returns FOOD, NOT FOOD, or UNKNOWN
// Add --json flag to spit out JSON
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

page.open("http://demo1.alchemyapi.com/language.php", function (status) {
  var phantomLogCounter = 0;
  page.onConsoleMessage = function (msg) { // the msg object contains all of the JSON data returned by the AI
    phantomLogCounter++;
    if (phantomLogCounter == 12) {
      if (JSON.parse(msg).length > 0) {
        var i = JSON.parse(msg)[0].label;
        if (i.indexOf("food") > -1 || i.indexOf("drink") > -1 || i.indexOf("beverage") > -1) {
          console.log("FOOD");
        } else {
          console.log("NOT FOOD");
        }
      } else {
        console.log("UNKNOWN");
      }
      phantom.exit();
    }
  };

  if (status !== 'success') {
        console.log('Unable to access network');
    } else {
        var address = system.args[1];
        var results = page.evaluate(function(address) {
            var logcounter = 0;
            var _consoleLog = console.log;
            console.log = function() {
                logcounter++;
                if (logcounter == 11) {
                  setTimeout(function() {
                    $("div[data-is=category]").click()
                    $("span[data-is=JSON]").click()
                    var i = ($(".json_container").text().split(']')[2]+"]}");
                    console.log(JSON.stringify(JSON.parse(i.slice(2, i.length)).taxonomy));
                  }, 2000);
                }
                return _consoleLog.apply(console, arguments);
            };
            $("div[data-is=text][data-does=sample]").click();
            $("textarea").val(address);
            $(".btn[data-is=submit]").click();

        }, address);





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
