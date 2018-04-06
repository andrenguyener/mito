'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;
class FriendStore {

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

    // Request a friend into SqlServer
    insert(userId, friendId) {
        return new Promise((resolve) => {
            let procedureName = "uspcRequestFriend";
            var request = this.request(procedureName);
            request.addParameter('User1Id', TYPES.Int, userId);
            request.addParameter('User2Id', TYPES.Int, friendId);

            request.on('doneProc', function (rowCount, more) {
                resolve("Friend Request Sent");
            });

            this.sql.callProcedure(request)
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

    // Get all friends of a UserId
    getAll(id, friendType) {
        return new Promise((resolve) => {
            let procedureName = "uspcGetUserFriendsById";
            var request = new Request(`${procedureName}`, function (err, rowCount, rows) {
                if (err) {
                    console.log(err);
                }
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

            this.sql.callProcedure(request)
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
            let procedureName = "uspcUpdateFriend";
            var request = this.request(procedureName);
            request.addParameter('user1Id', TYPES.Int, userId);
            request.addParameter('user2Id', TYPES.Int, friendId);
            request.addParameter('user1Id', TYPES.NVarChar, friendType);
            request.addParameter('user2Id', TYPES.NVarChar, notificationType);
            request.on('doneProc', function (rowCount, more) {
                resolve("Friend Request Sent");
            });

            this.sql.callProcedure(request)
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