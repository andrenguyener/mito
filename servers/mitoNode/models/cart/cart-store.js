'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;
class CartStore {

    constructor(sql) {
        this.sql = sql;
    }

    // Get items in cart based on a given userId
    get(id) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcGetUserCartItemList";
                var request = new Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err)
                    }
                    connection.release();
                });

                request.addParameter('UserId', TYPES.Int, id);
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

    // Add items to cart
    insert(userId, amazonASIN, productName, productImageUrl, amazonPrice, quantity) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcInsertIntoCart";
                var request = new Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err)
                    }
                    connection.release();
                });
                request.addParameter('UserId', TYPES.Int, userId);
                request.addParameter('AmazonASIN', TYPES.VarChar, amazonASIN);
                request.addParameter('Name', TYPES.VarChar, productName);
                request.addParameter('ImageUrl', TYPES.VarChar, productImageUrl);
                request.addParameter('AmazonPrice', TYPES.Money, amazonPrice);
                request.addParameter('Qty', TYPES.Int, quantity);

                // let jsonArray = []
                // request.on('row', function (columns) {
                //     var rowObject = {};
                //     columns.forEach(function (column) {
                //         if (column.value === null) {
                //             console.log('NULL');
                //         } else {
                //             rowObject[column.metadata.colName] = column.value;
                //         }
                //     });
                //     jsonArray.push(rowObject);
                // });

                request.on('doneProc', function (rowCount, more) {
                    // console.log(jsonArray);
                    // resolve(jsonArray);
                    resolve("items added to cart")
                });

                connection.callProcedure(request)
            });
        })
            .then((jsonArray) => {
                return jsonArray;
            })
            .catch((err) => {
                console.log(err);
            });


    }

    // process cart items for checkout
    process(userId, userAddressId, recipientId, cardId, message, giftOption) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcProcessCheckout";
                var request = new Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err)
                    }
                    connection.release();
                });
                request.addParameter('UserId', TYPES.Int, userId);
                request.addParameter('SenderAddressId', TYPES.Int, userAddressId);
                request.addParameter('RecipientId', TYPES.Int, recipientId);
                request.addParameter('CardId', TYPES.Int, cardId);
                request.addParameter('Message', TYPES.NVarChar, message);
                request.addParameter('GiftOption', TYPES.Int, giftOption);

                request.on('doneProc', function (rowCount, more) {
                    resolve("Checkout completed");
                })

                connection.callProcedure(request);
            });
        })
            .then((message) => {
                return message
            })
            .catch((err) => {
                console.log(err);
            })
    }



    // Deletes items from cart
    delete() {

    }

    // Update the quantity of an item
    update() {

    }

}

module.exports = CartStore;