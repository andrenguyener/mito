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
                var request = new Request(`${procedureName}`, (err, rowCount, rows) => {
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
                var request = new Request(`${procedureName}`, (err, rowCount, rows) => {
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

    // Get all users that are not your friends
    getNonFriends(userId) {
        return new Promise((resolve) => {
            this.sql.acquire(function (err, connection) {
                let procedureName = "uspcGetAllNonFriendUsers";
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
                var request = new Request(`${procedureName}`, (err, rowCount, rows) => {
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
                var request = new Request(`${procedureName}`, (err, rowCount, rows) => {
                    if (err) {
                        console.log(err)
                    }
                    connection.release();
                });
                var friendType;
                request.addParameter('User1Id', TYPES.Int, id);
                request.addParameter('User2Id', TYPES.Int, friendId);
                request.addOutputParameter('FriendType', TYPES.NVarChar, friendType);
                request.on('returnValue', function (parameterName, value, metadata) {
                    console.log(parameterName);
                    console.log(value);
                    console.log(metadata);
                    friendType = value;
                    console.log(friendType);

                });
                // request.addOutputParameter('Address_Id', addressId);

                // request.on('returnValue', function (parameterName, value, metadata) {
                //     console.log(parameterName);
                //     console.log(value);
                //     console.log(metadata);
                // });
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
                //     jsonArray.push(rowObject)
                // });

                request.on('doneProc', function (rowCount, more) {
                    // console.log(jsonArray);
                    // resolve(jsonArray);
                    resolve(friendType)
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
                var request = new Request(`${procedureName}`, (err, rowCount, rows) => {
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
                    if (friendType == "friend") {
                        resolve("Accept");
                    } else {
                        resolve("Action Completed");
                    }

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