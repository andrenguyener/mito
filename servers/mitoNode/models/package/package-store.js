'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;

class PackageStore {

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

    //get all the users incoming packages
    getPending(id) {
        return new Promise((resolve) => {
            let procedureName = "uspcGetMyPendingPackages";
            // var request = new Request(`${procedureName}`, function (err, rowCount, rows) {
            //     if (err) {
            //         console.log(err);
            //     }
            // });
            var request = this.request(procedureName);
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

            this.sql.callProcedure(request)
        })
            .then((jsonArray) => {
                return jsonArray
            })
            .catch((err) => {
                console.log(err);
            });
    }

    //
    getIncoming(id) {
        return new Promise((resolve) => {
            let procedureName = "uspcGetUserFriendsById";
            var request = this.request(procedureName);

            request.addParameter('UserId', TYPES.Int, id);
            request.addParameter('isFriend', TYPES.Int, friendType)
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

    // Update Accept/Deny incoming package
    update(userId, senderId, orderId, response, shippingAddressId) {
        return new Promise((resolve) => {
            let procedureName = "uspcConfirmPackage";
            var request = this.request(procedureName);

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
                console.log(jsonArray);
                resolve(jsonArray);
            });

            this.sql.callProcedure(request)
        })
            .then((jsonArray) => {
                // user accpeted package
                if (jsonArray.length > 0) {
                    return jsonArray
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