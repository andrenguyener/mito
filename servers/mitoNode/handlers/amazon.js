'use strict';

const express = require('express');
const axios = require('axios');
var _ = require('lodash');
var config = require('config')
// var parser = require('xml2json');
var parseString = require('xml2js').parseString;
const Address = require('./../models/amazon/amazon');
const sendToMQ = require('./message-queue');

const sha256hash = require('./amazonhash');
const publicKeyAmazon = config.get('API.Amazon.publicKeyAmazon');
const secretKeyAmazon = config.get('API.Amazon.secretKeyAmazon');
var chrsz = 8;
// invokeRequest("harry+potter", "All", "");
function invokeRequest(type, keyword, pageNumber) {

    // if (getAccessKeyId() == "AWS Access Key ID") {
    //     alert("Please provide an AWS Access Key ID");
    //     return;
    // }

    // if (getSecretAccessKey() == "AWS Secret Access Key") {
    //     alert("Please provide an AWS Secret Access Key");
    //     return;
    // }
    // keyword = keyword.replace(/ /g,"+");

    // var unsignedUrl = `http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&Operation=ItemSearch&SubscriptionId=AKIAJSRYKM2YU35LEDSQ&AssociateTag=mitoteam-20&SearchIndex=All&Keywords=${keyword}&ResponseGroup=Images,ItemAttributes,Offers,Reviews`
    var unsignedUrl = "";
    switch (type) {
        case "keyword":
            unsignedUrl = `http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&Operation=ItemSearch&SubscriptionId=AKIAJSRYKM2YU35LEDSQ&AssociateTag=mitoteam-20&SearchIndex=All&Keywords=${keyword}&ResponseGroup=Images,ItemAttributes,Offers,Reviews`

            break;
        case "page":
            unsignedUrl = `http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&Operation=ItemSearch&SubscriptionId=AKIAJSRYKM2YU35LEDSQ&AssociateTag=mitoteam-20&SearchIndex=All&Keywords=${keyword}&ItemPage=${pageNumber}&ResponseGroup=Images,ItemAttributes,Offers,Reviews`

            break;
        default:
            unsignedURL = `http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&Operation=ItemSearch&SubscriptionId=AKIAJSRYKM2YU35LEDSQ&AssociateTag=mitoteam-20&SearchIndex=All&Keywords=${keyword}&ResponseGroup=Images,ItemAttributes,Offers,Reviews`
    }
    // var unsignedUrl = document.getElementById("UnsignedURL").value;
    if (unsignedUrl == "") {
        alert("Please provide a URL");
        return;
    }

    var lines = unsignedUrl.split("\n");
    unsignedUrl = "";
    for (var i in lines) { unsignedUrl += lines[i]; }

    // find host and query portions
    var urlregex = new RegExp("^http:\\/\\/(.*)\\/onca\\/xml\\?(.*)$");
    var matches = urlregex.exec(unsignedUrl);

    if (matches == null) {
        alert("Could not find PA-API end-point in the URL. Please ensure the URL looks like the example provided.");
        return;
    }

    var host = matches[1].toLowerCase();
    var query = matches[2];

    // split the query into its constituent parts
    var pairs = query.split("&");

    // remove signature if already there
    // remove access key id if already present 
    //  and replace with the one user provided above
    // add timestamp if not already present
    pairs = cleanupRequest(pairs);

    // show it
    // document.getElementById("NameValuePairs").value = pairs.join("\n");

    // encode the name and value in each pair
    pairs = encodeNameValuePairs(pairs);

    // sort them and put them back together to get the canonical query string
    pairs.sort();
    // document.getElementById("OrderedPairs").value = pairs.join("\n");

    var canonicalQuery = pairs.join("&");
    var stringToSign = "GET\n" + host + "\n/onca/xml\n" + canonicalQuery;

    // calculate the signature

    var secret = secretKeyAmazon;
    var signature = sign(secret, stringToSign);

    // assemble the signed url
    var signedUrl = "http://" + host + "/onca/xml?" + canonicalQuery + "&Signature=" + signature;
    // console.log(signedUrl);
    return signedUrl;
    // update the UI
    // var stringToSignArea = document.getElementById("StringToSign");
    // stringToSignArea.value = stringToSign;

    // var signedURLArea = document.getElementById("SignedURL");
    // signedURLArea.value = signedUrl;
}

function invokeParentRequest(parentASIN) {

    // if (getAccessKeyId() == "AWS Access Key ID") {
    //     alert("Please provide an AWS Access Key ID");
    //     return;
    // }

    // if (getSecretAccessKey() == "AWS Secret Access Key") {
    //     alert("Please provide an AWS Secret Access Key");
    //     return;
    // }
    // keyword = keyword.replace(/ /g,"+");

    // var unsignedUrl = `http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&Operation=ItemSearch&SubscriptionId=AKIAJSRYKM2YU35LEDSQ&AssociateTag=mitoteam-20&SearchIndex=All&Keywords=${keyword}&ResponseGroup=Images,ItemAttributes,Offers,Reviews`
    var unsignedUrl = `http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&Operation=ItemLookup&SubscriptionId=AKIAJSRYKM2YU35LEDSQ&AssociateTag=mitoteam-20&ItemId=${parentASIN}&IdType=ASIN&ResponseGroup=Images,ItemAttributes,OfferListings,Offers,Similarities,VariationImages,VariationMatrix,VariationOffers`;
    // switch (type) {
    //     case "keyword":
    //         unsignedUrl = `http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&Operation=ItemSearch&SubscriptionId=AKIAJSRYKM2YU35LEDSQ&AssociateTag=mitoteam-20&SearchIndex=All&Keywords=${keyword}&ResponseGroup=Images,ItemAttributes,Offers,Reviews`

    //         break;
    //     case "page":
    //         unsignedUrl = `http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&Operation=ItemSearch&SubscriptionId=AKIAJSRYKM2YU35LEDSQ&AssociateTag=mitoteam-20&SearchIndex=All&Keywords=${keyword}&ItemPage=${pageNumber}&ResponseGroup=Images,ItemAttributes,Offers,Reviews`

    //         break;
    //     default:
    //         unsignedURL = `http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&Operation=ItemSearch&SubscriptionId=AKIAJSRYKM2YU35LEDSQ&AssociateTag=mitoteam-20&SearchIndex=All&Keywords=${keyword}&ResponseGroup=Images,ItemAttributes,Offers,Reviews`
    // }
    // // var unsignedUrl = document.getElementById("UnsignedURL").value;
    if (unsignedUrl == "") {
        alert("Please provide a URL");
        return;
    }

    var lines = unsignedUrl.split("\n");
    unsignedUrl = "";
    for (var i in lines) { unsignedUrl += lines[i]; }

    // find host and query portions
    var urlregex = new RegExp("^http:\\/\\/(.*)\\/onca\\/xml\\?(.*)$");
    var matches = urlregex.exec(unsignedUrl);

    if (matches == null) {
        alert("Could not find PA-API end-point in the URL. Please ensure the URL looks like the example provided.");
        return;
    }

    var host = matches[1].toLowerCase();
    var query = matches[2];

    // split the query into its constituent parts
    var pairs = query.split("&");

    // remove signature if already there
    // remove access key id if already present 
    //  and replace with the one user provided above
    // add timestamp if not already present
    pairs = cleanupRequest(pairs);

    // show it
    // document.getElementById("NameValuePairs").value = pairs.join("\n");

    // encode the name and value in each pair
    pairs = encodeNameValuePairs(pairs);

    // sort them and put them back together to get the canonical query string
    pairs.sort();
    // document.getElementById("OrderedPairs").value = pairs.join("\n");

    var canonicalQuery = pairs.join("&");
    var stringToSign = "GET\n" + host + "\n/onca/xml\n" + canonicalQuery;

    // calculate the signature

    var secret = secretKeyAmazon;
    var signature = sign(secret, stringToSign);

    // assemble the signed url
    var signedUrl = "http://" + host + "/onca/xml?" + canonicalQuery + "&Signature=" + signature;
    // console.log(signedUrl);
    return signedUrl;
    // update the UI
    // var stringToSignArea = document.getElementById("StringToSign");
    // stringToSignArea.value = stringToSign;

    // var signedURLArea = document.getElementById("SignedURL");
    // signedURLArea.value = signedUrl;
}

function encodeNameValuePairs(pairs) {
    for (var i = 0; i < pairs.length; i++) {
        var name = "";
        var value = "";

        var pair = pairs[i];
        var index = pair.indexOf("=");

        // take care of special cases like "&foo&", "&foo=&" and "&=foo&" 
        if (index == -1) {
            name = pair;
        } else if (index == 0) {
            value = pair;
        } else {
            name = pair.substring(0, index);
            if (index < pair.length - 1) {
                value = pair.substring(index + 1);
            }
        }

        // decode and encode to make sure we undo any incorrect encoding
        name = encodeURIComponent(decodeURIComponent(name));

        value = value.replace(/\+/g, "%20");
        value = encodeURIComponent(decodeURIComponent(value));

        pairs[i] = name + "=" + value;
    }

    return pairs;
}

function cleanupRequest(pairs) {
    var haveTimestamp = false;
    var haveAwsId = false;
    var accessKeyId = publicKeyAmazon;

    var nPairs = pairs.length;
    var i = 0;
    while (i < nPairs) {
        var p = pairs[i];
        if (p.search(/^Timestamp=/) != -1) {
            haveTimestamp = true;
        } else if (p.search(/^(AWSAccessKeyId|SubscriptionId)=/) != -1) {
            pairs.splice(i, 1, "AWSAccessKeyId=" + accessKeyId);
            haveAwsId = true;
        } else if (p.search(/^Signature=/) != -1) {
            pairs.splice(i, 1);
            i--;
            nPairs--;
        }
        i++;
    }

    if (!haveTimestamp) {
        pairs.push("Timestamp=" + getNowTimeStamp());
    }

    if (!haveAwsId) {
        pairs.push("AWSAccessKeyId=" + accessKeyId);
    }
    return pairs;
}

function sign(secret, message) {
    var messageBytes = sha256hash.str2binb(message);
    var secretBytes = sha256hash.str2binb(secret);

    if (secretBytes.length > 16) {
        secretBytes = sha256hash.core_sha256(secretBytes, secret.length * chrsz);
    }

    var ipad = Array(16), opad = Array(16);
    for (var i = 0; i < 16; i++) {
        ipad[i] = secretBytes[i] ^ 0x36363636;
        opad[i] = secretBytes[i] ^ 0x5C5C5C5C;
    }

    var imsg = ipad.concat(messageBytes);
    var ihash = sha256hash.core_sha256(imsg, 512 + message.length * chrsz);
    var omsg = opad.concat(ihash);
    var ohash = sha256hash.core_sha256(omsg, 512 + 256);

    var b64hash = sha256hash.binb2b64(ohash);
    var urlhash = encodeURIComponent(b64hash);

    return urlhash;
}

// Date.prototype.toISODate =
//     new Function("with (this)\n    return " +
//         "getFullYear()+'-'+addZero(getMonth()+1)+'-'" +
//         "+addZero(getDate())+'T'+addZero(getHours())+':'" +
//         "+addZero(getMinutes())+':'+addZero(getSeconds())+'.000Z'");

function addZero(n) {
    return (n < 0 || n > 9 ? "" : "0") + n;
}

function getNowTimeStamp() {
    var time = new Date();
    var gmtTime = new Date(time.getTime() + (time.getTimezoneOffset() * 60000));
    return gmtTime.toISOString();
}

// function getAccessKeyId() {
//     return document.getElementById('AWSAccessKeyId').value;
// }

// function getSecretAccessKey() {
//     return document.getElementById('AWSSecretAccessKey').value;
// }

const AmazonHashHandler = () => {


    // A signal indicating that the promise should break here.
    class BreakSignal { }
    const breakSignal = new BreakSignal();

    const router = express.Router();

    router.post('/v1/amazonsearch', (req, res) => {

        let urlString = req.body.data;

        axios.get(urlString)
            .then(function (response) {
                var xml = response.data
                parseString(xml, function (err, result) {
                    console.log(result);
                    res.json(result);
                });

            })
            .catch(function (error) {
                console.log(error); docker
            });


    });

    router.post('/v1/amazonhash', (req, res) => {

        let keyword = req.body.keyword;
        let type = "keyword";
        console.log(req.body);
        let urlString = invokeRequest(type, keyword, 2);
        console.log(urlString);
        axios.get(urlString)
            .then(function (response) {
                var xml = response.data
                parseString(xml, function (err, result) {
                    console.log(result);
                    res.json(result);
                });

            })
            .catch(function (error) {
                console.log(error);
            });

    });

    router.post('/v1/amazonhashtest', (req, res) => {

        let keyword = req.body.keyword;
        let pageNumber = req.body.pageNumber;
        let type = "page";
        let urlString = invokeRequest(type, keyword, pageNumber);
        console.log(`pagenumber: ${pageNumber} keyword: ${keyword}`)
        console.log(urlString);
        axios.get(urlString)
            .then(function (response) {
                var xml = response.data
                parseString(xml, function (err, result) {
                    console.log(result);
                    res.json(result);
                });

            })
            .catch(function (error) {
                console.log(error);
            });
        // res.json(urlString);
    });

    router.post('/v1/amazonproductvariety', (req, res) => {
        let asin = req.body.parentASIN;
        let urlString = invokeParentRequest(asin);
        axios.get(urlString)
            .then(function (response) {
                var xml = response.data
                parseString(xml, function (err, result) {
                    console.log(result);
                    let variationArray = result.ItemLookupResponse.Items[0].Item[0].Variations[0].Item;
                    let productsObject = _.groupBy(variationArray, (o) => {
                        return o.ItemAttributes[0].Color;
                    })
                    console.log("products: ", productsObject);
                    res.json(productsObject);
                });

            })
            .catch(function (error) {
                console.log(error);
            });
    });

    router.get('/v1/amazonitem', (req, res) => {
        let itemASIN = req.body.itemASIN;
        // let pageItem = req.params.pageItem
        let urlString = invokeRequest(keyword);

        axios.get(urlString)
            .then(function (response) {
                var xml = response.data
                parseString(xml, function (err, result) {
                    console.log(result);
                    res.json(result);
                });

            })
            .catch(function (error) {
                console.log(error);
            });
    });



    return router;
};

module.exports = AmazonHashHandler;