'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;
var Curl = require('node-libcurl').Curl;

class PackageStore {

    constructor(sql) {
        this.sql = sql;
    }

    //get all the users incoming packages
    getPackages(id, type) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcGetMyPackages";
                // var request = Request(`${procedureName}`, function (err, rowCount, rows) {
                //     if (err) {
                //         console.log(err);
                //     }
                // });
                var request = new Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err)
                    }
                    connection.release();
                });
                request.addParameter('UserId', TYPES.Int, id);
                request.addParameter('Type', TYPES.NVarChar, type); //Pending, Accepted, Denied
                let jsonArray = []
                request.on('row', function (columns) {
                    var rowObject = {};
                    columns.forEach(function (column) {
                        if (column.value === null) {
                            console.log('NULL');
                        } else {
                            rowObject[column.metadata.colName] = column.value;
                        }
                    });
                    jsonArray.push(rowObject)
                });

                request.on('doneProc', function (rowCount, more) {
                    resolve(jsonArray);
                });

                connection.callProcedure(request)
            });
        })
            .then((jsonArray) => {
                return jsonArray
            })
            .catch((err) => {
                console.log(err);
            });
    }

    // Get all orders that user has sent to friends
    getSentPackages(userId) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcGetMySentPackages";
                var request = new Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err)
                    }
                    connection.release();
                });
                request.addParameter('UserId', TYPES.Int, userId);
                let jsonArray = []
                request.on('row', function (columns) {
                    var rowObject = {};
                    columns.forEach(function (column) {
                        if (column.value === null) {
                            console.log('NULL');
                        } else {
                            rowObject[column.metadata.colName] = column.value;
                        }
                    });
                    jsonArray.push(rowObject)
                });

                request.on('doneProc', function (rowCount, more) {
                    resolve(jsonArray);
                });

                connection.callProcedure(request)
            });
        })
            .then((jsonArray) => {
                return jsonArray
            })
            .catch((err) => {
                console.log(err);
            });
    }

    //NOTI
    // Update Accept/Deny incoming package
    update(userId, senderId, orderId, response, shippingAddressId) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcConfirmPackage";
                var request = new Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err)
                    }
                    connection.release();
                });

                request.addParameter('UserId', TYPES.Int, userId);
                request.addParameter('SenderId', TYPES.Int, senderId);
                request.addParameter('OrderId', TYPES.Int, orderId);
                request.addParameter('Response', TYPES.NVarChar, response);
                request.addParameter('ShippingAddressId', TYPES.Int, shippingAddressId);
                let jsonArray = []
                request.on('row', function (columns) {
                    var rowObject = {};
                    columns.forEach(function (column) {
                        if (column.value === null) {
                            console.log('NULL');
                        } else {
                            rowObject[column.metadata.colName] = column.value;
                        }
                    });
                    jsonArray.push(rowObject)
                });

                request.on('doneProc', function (rowCount, more) {
                    // console.log(jsonArray);
                    resolve(jsonArray);
                });

                connection.callProcedure(request)
            });
        })
            .then((jsonArray) => {
                // user accpeted package
                if (jsonArray.length > 0) {
                    var parsedJsonArray = {};
                    var amazonProducts = [];

                    for (var i = 0; i < jsonArray.length; i++) {
                        if (i == 0) {
                            for (let key in jsonArray[i]) {

                                console.log(`Key = ${key} Value = ${jsonArray[0][key]}`);

                                if (key != "AmazonItemId" && key != "Quantity") {
                                    parsedJsonArray[key] = jsonArray[0][key];
                                }

                            }
                        }
                        var product = {};
                        product["AmazonItemId"] = jsonArray[i]["AmazonItemId"];
                        product["Quantity"] = jsonArray[i]["Quantity"];
                        amazonProducts.push(product);
                    }

                    parsedJsonArray["AmazonProducts"] = amazonProducts;
                    console.log(`Parsed JSON array = ${JSON.stringify(parsedJsonArray, null, 4)}`)
                    // console.log(jsonArray[0]);
                    return parsedJsonArray
                } else { // user denied package
                    return "User denied package"
                }

            })
            .catch((err) => {
                console.log(err);
            });
    }

}

module.exports = PackageStore;


