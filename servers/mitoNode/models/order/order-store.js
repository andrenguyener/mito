'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;

class OrderStore {

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

    // Make an order (not to zinc yet until there is an address) - Add order to Order page
    insert() {

    }

    // Get information and products about order
    get(orderId) {
        return new Promise((resolve) => {
            let procedureName = "uspcGetOrderDetails";
            var request = this.request(procedureName);

            request.addParameter('OrderId', TYPES.Int, orderId);
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

    // Get all complete orders
    getComplete() {

    }

    // Get all pending orders
    getPending() {

    }

    // Get all past transaction/order
    getAll() {

    }

    // Update order (when a party provide an address)
    update() {


    }


    delete() {


    }
}

module.exports = OrderStore;