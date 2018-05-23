'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;
class NotificationStore {

    constructor(sql) {
        this.sql = sql;
    }


    // Get all notifications that will be sent to you (friend request, incoming packages)
    get(userId) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcGetMyNotification";
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
                            if (column.metadata.colName == 'ProfileImage' || column.metadata.colName == 'SenderProfileImage') {
                                column.value = Buffer.from(column.value).toString('base64');
                            }
                            rowObject[column.metadata.colName] = column.value;
                        }
                    });
                    jsonArray.push(rowObject)
                });

                request.on('doneProc', function (rowCount, more) {
                    console.log(jsonArray);
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



}

module.exports = NotificationStore;