'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;

class PaymentStore {

    constructor(sql) {
        this.sql = sql;
    }

    //get all the users payment methods
    getPayments(id) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcGetAllPaymentCards";
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
                            if (column.metadata.colName == 'ProfileImage' || column.metadata.colName == 'SenderProfileImage') {
                                column.value = Buffer.from(column.value).toString('base64');
                            }
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

    //delete a payment method
    delete(id, cardId, isDelete) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcDeletePaymentCard";
                var request = new Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err)
                    }
                    connection.release();
                });
                request.addParameter('UserId', TYPES.Int, id);
                request.addParameter('CardId', TYPES.Int, cardId);
                request.addParameter('IsDelete', TYPES.Bit, isDelete);
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
                    resolve("Card has been deleted")
                });

                connection.callProcedure(request)
            });
        })
            .then((message) => {
                return message
            })
            .catch((err) => {
                console.log(err);
            });
    }


    //sets the default payment for a user
    setDefault(id, existingCardId) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcUpdateUserDefaultPaymentCard";
                var request = new Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err)
                    }
                    connection.release();
                });
                request.addParameter('UserId', TYPES.Int, id);
                request.addParameter('ExistingCardId', TYPES.Int, existingCardId);
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
                    resolve("Card has been set to default")
                });

                connection.callProcedure(request)
            });
        })
            .then((message) => {
                return message
            })
            .catch((err) => {
                console.log(err);
            });
    }


    //inserts a payment method for a user
    insert(id, cardTypeName, cardNumber, expMonth, expYear, cardCVV, firstName, lastName) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcAddNewPaymentMethod";
                var request = new Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err)
                    }
                    connection.release();
                });
                request.addParameter('UserId', TYPES.Int, id);
                request.addParameter('CardTypeName', TYPES.NVarChar, cardTypeName);
                request.addParameter('CardNumber', TYPES.NVarChar, cardNumber);
                request.addParameter('ExpMonth', TYPES.TinyInt, expMonth);
                request.addParameter('ExpYear', TYPES.SmallInt, expYear);
                request.addParameter('CardCVV', TYPES.SmallInt, cardCVV);
                request.addParameter('FirstName', TYPES.NVarChar, firstName);
                request.addParameter('LastName', TYPES.NVarChar, lastName);
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
                    resolve("Card has been inserted")
                });

                connection.callProcedure(request)
            });
        })
            .then((message) => {
                return message
            })
            .catch((err) => {
                console.log(err);
            });
    }
}

module.exports = PaymentStore;







