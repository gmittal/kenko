var page = require('webpage').create(),
system = require('system');
var addressURL;

function evaluate(page, func) {
    var args = [].slice.call(arguments, 2);
    var fn = "function() { return (" + func.toString() + ").apply(this, " + JSON.stringify(args) + ");}";
    return page.evaluate(fn);
}

  page.open("http://cloudsightapi.com/api", function(status) {
    page.onConsoleMessage = function (msg) { console.log(msg);  phantom.exit(); };

    var address = system.args[1];

      evaluate(page, function (address) {
          $.ajax({
                  url: "/image_requests",
                  type: "POST",
                  crossDomain: !0,
                  data: {
                      "image_request[remote_image_url]": address,
                      "image_request[locale]": "en-US",
                      "image_request[language]": "en-US"
                  },
                  datatype: "json",
                  beforeSend: $.rails.CSRFProtection,
                  success: function(e) {
                      // console.log(e.token);
                      loopResponseCloud();
                      function loopResponseCloud() {
                          $.get("/image_responses/"+e.token, function (resBody) {
                              if (resBody.status == "not completed") {
                                // console.log(JSON.stringify(resBody));
                                loopResponseCloud();
                              } else if (resBody.status == "skipped") {
                                console.log(JSON.stringify({"Error": "Error reading the photo. Please try again."}));
                              } else if (resBody.status == "completed") {
                                console.log(JSON.stringify(resBody));
                              }
                        });
                      }

                  },
                  error: function(e) {
                      console.log(JSON.stringify(e));
                  }
            });

      }, address);

  }); // end page open
