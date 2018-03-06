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



    getAll(id) {
        return new Promise((resolve) => {
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

    update(id, updates) {


    }


    delete(id) {


    }
}

module.exports = FriendStore;