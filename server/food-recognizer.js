// Copyright 2016 Gautam Mittal
// Food recognizer
// Command line tool that tells you whether something is food or not
// Returns FOOD, NOT FOOD, or UNKNOWN
// Add --json flag to spit out JSON
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
  page.onConsoleMessage = function (msg) {
    phantomLogCounter++;
    if (phantomLogCounter == 12) {
      if (system.args[2] != "--json") {
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
      } else {
        console.log(msg);
      }

      phantom.exit();
    }
  };

  if (status !== 'success') {
        console.log('UNKNOWN');
        phantom.exit();
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
