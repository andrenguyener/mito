'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;
class ImageStore {

    constructor(sql) {
        this.sql = sql;
    }


    // Get the profile image of the user uploaded
    get(userId) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcGetImage";
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

    // Upload an image for the user
    insert(userId, imageData) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcUploadNewProfileImage";
                var request = new Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err);
                    }
                    connection.release();
                });
                request.addParameter('UserId', TYPES.Int, userId);
                request.addParameter('ImageData', TYPES.VarBinary, imageData);

                request.on('doneProc', function (rowCount, more) {
                    resolve("Image Added");
                });

                connection.callProcedure(request)
            });
        })
            .then((message) => {
                return message;
            })
            .catch((err) => {
                console.log(err);
            });

    }

}

module.exports = ImageStore;