'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;
class FriendStore {

    constructor(sql) {
        this.sql = sql;
    }

    // Request a friend into SqlServer
    insert(userId, friendId) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcRequestFriend";
                var request = Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err);
                    }
                    connection.release();
                });
                request.addParameter('User1Id', TYPES.Int, userId);
                request.addParameter('User2Id', TYPES.Int, friendId);

                request.on('doneProc', function (rowCount, more) {
                    resolve("Friend Request Sent");
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

    // Get information about a friend from their UserId
    get(id) {

    }

    // Get the number of mutual friend
    getMutualFriends(id1, id2) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcGetMutualFriendCount";
                var request = Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err)
                    }
                    connection.release();
                });
                request.addParameter('UserId1', TYPES.Int, id1);
                request.addParameter('UserId2', TYPES.Int, id2);
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

    // Get all friends of a UserId
    getAll(id, friendType) {

        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcGetUserFriendsById";
                var request = Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err)
                    }
                    connection.release();
                });
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

    // Get status type of another user
    getType(id, friendId) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcGetUserFriendTypeByUserId";
                var request = Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err)
                    }
                    connection.release();
                });
                request.addParameter('UserId1', TYPES.Int, id);
                request.addParameter('UserId2', TYPES.Int, friendId);
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

    // Update (downgrade/upgrade) friend status
    updateFriendStatus(id, updates) {

    }

    // Accept/Decline friend request
    updateFriendRequest(userId, friendId, friendType, notificationType) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcUpdateFriend";
                var request = Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err)
                    }
                    connection.release();
                });
                request.addParameter('user1Id', TYPES.Int, userId);
                request.addParameter('user2Id', TYPES.Int, friendId);
                request.addParameter('friendTypeToUpdate', TYPES.NVarChar, friendType);
                request.addParameter('friendTypeRequestResponse', TYPES.NVarChar, notificationType);
                request.on('doneProc', function (rowCount, more) {
                    resolve("Action Completed");
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

    // Delete a friend from the User  
    delete(userId, deletedId) {


    }
}

module.exports = FriendStore;