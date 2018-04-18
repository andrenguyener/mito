'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;
class CartStore {

    constructor(sql) {
        this.sql = sql;
    }

    request(procedure) {
        return new Request((`${procedure}`), function (err) {
            if (err) {
                console.log(err);
            }
        });
    }
    // Get items in cart based on a given userId
    get(id) {
        return new Promise((resolve) => {
            let procedureName = "uspcGetUserCartItemList";
            var request = new Request(`${procedureName}`, function (err, rowCount, rows) {
                if (err) {
                    console.log(err);
                }
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
                console.log(jsonArray);
                resolve(jsonArray);
            });

            this.sql.callProcedure(request)
        })
            .then((jsonArray) => {
                return jsonArray
            })
            .catch((err) => {
                console.log(err);
            });
    }

    // Add items to cart
    insert(userId, amazonASIN, amazonPrice, quantity) {
        return new Promise((resolve) => {
            let procedureName = "uspcInsertIntoCart";
            var request = this.request(procedureName);
            request.addParameter('UserId', TYPES.Int, userId);
            request.addParameter('AmazonASIN', TYPES.VarChar, amazonASIN);
            request.addParameter('AmazonPrice', TYPES.Numeric, amazonPrice);
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

            this.sql.callProcedure(request)
        })
            .then((jsonArray) => {
                return jsonArray;
            })
            .catch((err) => {
                console.log(err);
            });


    }

    // process cart items for checkout
    process(userId, userAddressId, recipientId, message, giftOption) {
        return new Promise((resolve) => {
            let procedureName = "uspcProcessCheckout";
            var request = this.request(procedureName);
            request.addParameter('UserId', TYPES.Int, userId);
            request.addParameter('SenderAddressId', TYPES.Int, userAddressId);
            request.addParameter('RecipientId', TYPES.Int, recipientId);
            request.addParameter('Message', TYPES.NVarChar, message);
            request.addParameter('GiftOption', TYPES.Int, giftOption);

            request.on('doneProc', function (rowCount, more) {
                resolve("Checkout completed");
            })

            this.sql.callProcedure(request);
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