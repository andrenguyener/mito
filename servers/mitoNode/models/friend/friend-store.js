'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;
class FriendStore {

    constructor(sql) {
        this.sql = sql;
    }



    insert(address) {

    }


    get(id) {

    }



    getAll(id, res) {
        let procedureName = "GetUserFriendsById";
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
            // let returnArray = [];
            // for (object in jsonArray) {
            //     let returnObject = {};
            //     returnObject.UserId = object.UserId;
            //     returnObject.Username = object.Username;
            //     returnArray.push(returnObject);
            // }
            res.json(jsonArray);
        });

        this.sql.callProcedure(request)
    }

    update(id, updates) {


    }


    delete(id) {


    }
}

module.exports = FriendStore;