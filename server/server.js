var dotenv = require('dotenv');
dotenv.load();

var express = require('express');
var bodyParser = require('body-parser');
var colors = require('colors');
var fs = require('fs');
var os = require('os');
var prettyjson = require('prettyjson');
var querystring = require('querystring');
var request = require('request');

// shell commands
require('shelljs/global');

var app = express();
app.use(bodyParser({limit: '50mb'}));
app.use(express.static(__dirname + '/uploaded_data'));
app.use(function(req, res, next) { // enable CORS
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  res.setHeader('Content-Type', 'application/json');
  next();
});


var port = 3000;

// for getting network data
var ifaces = os.networkInterfaces();

app.get('/', function (req, res) {
  res.send('Hello World!');
});

app.post('/food-analysis', function (req, res) {
  res.setHeader('Content-Type', 'application/json');

  if (req.body.image) {
    // console.log((req.body.image).grey);

    var imageID = generatePushID(); // generate a unique token for each image

    fs.writeFile(__dirname+'/uploaded_data/'+imageID+'.jpeg', req.body.image, 'base64', function (err) {
      if (err) throw err;
      console.log('Image successfully uploaded.'.green);
      console.log((process.env.HOSTNAME+"/uploaded_img/"+imageID).blue);

      var form = {
          'image_request[remote_image_url]': process.env.HOSTNAME+"/uploaded_img/"+imageID+".jpeg",
          "image_request[locale]": "en-US"
      };

      var formData = querystring.stringify(form);
      var contentLength = formData.length;

      console.log(process.env.CLOUDSIGHT_KEY);


        request({
            headers: {
              'Authorization': 'CloudSight '+ process.env.CLOUDSIGHT_KEY,
              'Content-Length': contentLength,
              'Content-Type': 'application/x-www-form-urlencoded'
            },
            uri: 'https://api.cloudsightapi.com/image_requests',
            body: formData,
            method: 'POST'
          }, function (err, resPost, body) {
            //it works!
            if (err) {
              res.send({"Error": "There was an error from images-request"})
            } else {
              console.log(body);
              var resToken = JSON.parse(body).token;

              console.log("Processing image information...".cyan);

              loopResponseCloud();
              function loopResponseCloud() {
                  request({url: "https://api.cloudsightapi.com/image_responses/"+resToken, headers: {'Authorization': 'CloudSight '+ process.env.CLOUDSIGHT_KEY}}, function (resError, resResponse, resBody) {
                      if (JSON.parse(resBody).status == "not completed") {
                        loopResponseCloud();
                      } else if (JSON.parse(resBody).status == "skipped") {
                        res.send({"Error": "Error reading the photo. Please try again."});
                      } else if (JSON.parse(resBody).status == "completed") { // if the image recognition occurred, start finding nutritional data

                        console.log(resBody);

                        if (typeof JSON.parse(resBody).name !== "undefined") {
                          console.log((JSON.parse(resBody).name).green);

                          // if ((JSON.parse(resBody).name).split(" ")[0] == "barcode") {
                          //
                          //   var chunks = (JSON.parse(resBody).name).split(" ");
                          //   for (var j = 0; j < chunks.length; j++) {
                          //     if ((chunks[j] > 3) && (isNaN(chunks[j]) == false)) { // we know its a UPC
                          //       console.log("WE FOUND UPC " + chunks[j]);
                          //     }
                          //   }
                          // }

                          // get nutritional data
                          var nutritionalParameters = {
                            "appId":process.env.NUTRITION_APP_ID,
                            "appKey":process.env.NUTRITION_API_KEY,
                            "phrase":JSON.parse(resBody).name,
                            "fields":"*",
                            "results":"0:50",
                            "cal_min":0,
                            "cal_max":50000

                          };

                          var nutritionData = querystring.stringify(nutritionalParameters);


                          request({
                              uri: 'https://api.nutritionix.com/v1_1/search/'+encodeURIComponent(nutritionalParameters.phrase)+"?results="+encodeURIComponent(nutritionalParameters.results)+"&cal_min="+nutritionalParameters.cal_min+"&cal_max="+nutritionalParameters.cal_max+"&fields="+encodeURIComponent(nutritionalParameters.fields)+"&appId="+nutritionalParameters.appId+"&appKey="+nutritionalParameters.appKey,
                              body: nutritionData,
                              method: 'GET'
                            }, function (nutriErr, nutriRes, nutriBody) {
                              if (nutriErr) {
                                var returnedData = {"imageB64":req.body.image, "Scan_Error": "There is no nutritional value in consuming a '" + JSON.parse(resBody).name+"'"};
                                res.send(returnedData);
                                fs.writeFile(__dirname+"/user_cache/"+generatePushID()+".json", JSON.stringify(returnedData), function(err) {
                                  if (err) throw err;

                                });
                              } else {
                                var parsedData = JSON.parse(nutriBody);
                                console.log(("NUTRITIONAL RELEVANCE SCORE: " + parsedData.max_score).magenta);
                                if (parsedData.max_score > 0.82) {
                                  var relevantNutrition = parsedData.hits[0];
                                  // console.log(relevantNutrition);
                                  console.log(relevantNutrition.fields.item_name);

                                  var easyDisplayName = toTitleCase(relevantNutrition.fields.item_name); // so it looks better on the iphone
                                  console.log("EVERYTHING WORKED".green);
                                  console.log(Math.round(parsedData.max_score * 100)/100);

                                  console.log(relevantNutrition.fields["nf_ingredient_statement"]);

                                  for (var key in relevantNutrition.fields) {

                                    if (key !== "item_name") {
                                      if (key !== "nf_calories") {
                                        if (key !== "nf_serving_size_qty") {
                                          if (key !== "nf_serving_size_unit") {

                                            if ((key.indexOf("allergen") > -1) == false) {
                                                  if (relevantNutrition.fields[key] == null) {
                                                    relevantNutrition.fields[key] = "0";
                                                  }

                                                  if (key == "nf_sodium") {
                                                    relevantNutrition.fields[key] += "mg";
                                                  } else if (key == "nf_cholesterol") {
                                                    relevantNutrition.fields[key] += "mg";
                                                  } else if (key == "nf_ingredient_statement") {
                                                    if (relevantNutrition.fields[key] == null) {
                                                      relevantNutrition.fields[key] = "No ingredients.";
                                                    }
                                                  } else {
                                                    relevantNutrition.fields[key] += "g";
                                                  }

                                            }
                                          }
                                        }
                                      }
                                    }



                                  }

                                  console.log(relevantNutrition.fields["nf_ingredient_statement"]);
                                  var awesomeData = {"imageB64":req.body.image, "result":{"object_name":toTitleCase(JSON.parse(resBody).name), "confidence": Math.round(parsedData.max_score * 100)/100, "easy_display_name": easyDisplayName, "data": relevantNutrition}};
                                  res.send(awesomeData);
                                  fs.writeFile(__dirname+"/user_cache/"+generatePushID()+".json", JSON.stringify(awesomeData), function(err) {
                                    if (err) throw err;

                                  });


                                } else {
                                  var returnData = {"imageB64":req.body.image, "Scan_Error": "There is no nutritional value in consuming a '" + JSON.parse(resBody).name+"'"};
                                  res.send(returnData);
                                  fs.writeFile(__dirname+"/user_cache/"+ generatePushID() +".json", JSON.stringify(returnData), function(err) {
                                    if (err) throw err;

                                  });
                                }

                              }


                          }); // end nutritoinix api

                        } else {
                          res.send({"Error": "There was an error."});
                        }
                      }


                  });
                }

            }

          });




    });


  }
});

app.get('/uploaded_img/:id', function (req, res) {
  res.set('Content-Type', 'application/jpeg');
  res.sendFile(__dirname + "/uploaded_data/" +req.param('id'));
});

// We really don't care about this for now
// UPC product scans
// app.post('/upc-analysis', function (req, res) {
//   res.setHeader('Content-Type', 'application/json');
//
//   if (req.body.upc) {
//     var upcData = {
//       code: req.body.upc,
//       appId: process.env.NUTRITION_APP_ID,
//       appKey: process.env.NUTRITION_API_KEY
//     };
//
//     request({
//         uri: "https://api.nutritionix.com/v1_1/item?upc="+ encodeURIComponent(upcData.code) +"&appId="+ encodeURIComponent(upcData.appId) +"&appKey="+encodeURIComponent(upcData.appKey),
//         method: 'GET'
//       }, function (nutriErr, nutriRes, nutriBody) {
//         if (nutriErr) {
//           res.send({"Scan_Error": "There is no nutritional value in consuming a '" + JSON.parse(resBody).name+"'"});
//         } else {
//           var parsedData = JSON.parse(nutriBody);
//           if (parsedData.max_score > 1) {
//             var relevantNutrition = parsedData;
//
//             var easyDisplayName = toTitleCase((JSON.parse(resBody).name).split(" ")[0]); // so it looks better on the iphone
//             console.log("EVERYTHING WORKED".green);
//
//             // send and save the data
//             var awesomeData = {"result":{"object_name":toTitleCase(JSON.parse(resBody).name), "easy_display_name": easyDisplayName, "data": relevantNutrition}};
//             res.send(awesomeData);
//             fs.writeFile(__dirname+"/user_cache/saved-data.json", awesomeData, function(err) {
//               if (err) throw err;
//
//             });
//
//           } else {
//
//             res.send({"Scan_Error": "There is no nutritional value in consuming a '" + JSON.parse(resBody).name+"'"});
//           }
//
//         }
//
//     }); // end nutritoinix api
//   }
// });


app.get("/saved-user-data", function (req, res) {
  res.setHeader('Content-Type', 'application/json');

  var finalJSON = [];
  var savedContents = ls(__dirname+'/user_cache');
  console.log(savedContents);

  if (savedContents.length > 0) {
    var fileIndex = 0;
    loopJSON();

    function loopJSON() {
      console.log(savedContents[fileIndex]);
      fs.readFile(__dirname+"/user_cache/"+savedContents[fileIndex], "utf-8", function (err, data) {
        if (err) throw err;

        finalJSON.push(JSON.parse(data));
        rm('-rf', __dirname+"/user_cache/"+savedContents[fileIndex]);

        if (fileIndex < savedContents.length-1) {
          fileIndex++;
          loopJSON();
        } else {
          res.send(JSON.stringify(finalJSON));
        }
      });

    }
  } else {
    res.setHeader('Content-Type', 'application/text');
    res.send("No new content.");
  }


});


// start the server
var server = app.listen(port, function () {
  Object.keys(ifaces).forEach(function (ifname) {
    var alias = 0;

    ifaces[ifname].forEach(function (iface) {
      if ('IPv4' !== iface.family || iface.internal !== false) {
        // skip over internal (i.e. 127.0.0.1) and non-ipv4 addresses
        return;
      }

      // this interface has only one ipv4 adress
      console.log(("Server running on "+iface.address+":"+port).blue);


    });
  });
});


// uuid generation
generatePushID = (function() {
  // Modeled after base64 web-safe chars, but ordered by ASCII.
  var PUSH_CHARS = '-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz';

  // Timestamp of last push, used to prevent local collisions if you push twice in one ms.
  var lastPushTime = 0;

  // We generate 72-bits of randomness which get turned into 12 characters and appended to the
  // timestamp to prevent collisions with other clients.  We store the last characters we
  // generated because in the event of a collision, we'll use those same characters except
  // "incremented" by one.
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
      // If the timestamp hasn't changed since last push, use the same random number, except incremented by 1.
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
  };
})();


function toTitleCase(str)
{
    return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
}
