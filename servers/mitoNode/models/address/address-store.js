'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;

class AddressStore {

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


    // insert() creates a new address in SqlServer.
    insert(address) {
        return new Promise((resolve) => {
            let procedureName = "uspcInsertUserAddress";
            var request = this.request(procedureName);
            var addressId;
            request.addParameter('userId', TYPES.Int, address.userId);
            request.addParameter('streetAddress1', TYPES.VarChar, address.streetAddress1);
            request.addParameter('streetAddress2', TYPES.VarChar, address.streetAddress2);
            request.addParameter('cityName', TYPES.VarChar, address.cityName);
            request.addParameter('zipCode', TYPES.VarChar, address.zipCode);
            request.addParameter('stateName', TYPES.VarChar, address.stateName);
            request.addParameter('aliasName', TYPES.VarChar, "test");
            // request.addOutputParameter('Address_Id', addressId);

            // request.on('returnValue', function (parameterName, value, metadata) { 
            //     console.log(parameterName);
            //     console.log(value);
            //     console.log(metadata);
            // });
            request.on('doneProc', function (rowCount, more) {
                resolve(address);
            });

            this.sql.callProcedure(request)
        })
            .then((address) => {
                return address;
            })
            .catch((err) => {
                console.log(err);
            });
    }

    // get() retrieves an address from SqlServer for a given ID.
    get(id) {


    }

    // getAll() retrieves all addresses from SqlServer with the user ID.
    getAll(id) {
        return new Promise((resolve) => {
            let procedureName = "uspcGetUserAddressById";
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

    // update() updates a address for a given address ID.
    // It returns the updated address.
    update(id, updates) {

    }

    // delete() deletes an address for a given address ID.
    delete(id) {

    }
}

module.exports = AddressStore;