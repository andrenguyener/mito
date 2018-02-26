'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;
class AddressStore {

    constructor(sql) {
        // this.collection = db.collection(colName);
        // this should be a table
        this.sql = sql;
    }

    request(procedure) {
        return new Request(`${procedure}`), function (err) {
            if (err) {
                console.log(err);
            }
        }
    }


    // insert() creates a new address in SqlServer.
    insert(address) {
        // channel._id = new mongodb.ObjectID();
        // return this.collection.insertOne(channel).then(() => channel);
        let procedureName = "InsertUserAddress";
        var request = new Request(`${procedureName}`, function (err) {
            if (err) {
                console.log(err);
            }
        });
        var addressId;
        request.addParameter('userId', TYPES.VarChar, address.userId);
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
        this.sql.callProcedure(request)
    }

    // get() retrieves an address from SqlServer for a given ID.
    get(id) {
        // return this.collection.findOne({ _id: id });

    }

    // // getByName retrieves one channel from MongoDB for a given channel name.
    // getByName(name) {
    //     return this.collection.findOne({ name: name });
    // }

    // getAll() retrieves all addresses from SqlServer with the user ID.
    getAll(id, res) {
        let procedureName = "GetUserAddressById";
        var request = new Request(`${procedureName}`, function (err, rowCount, rows) {
            if (err) {
                console.log(err);
            }
            // return rowCount
        });
        
        request.addParameter('UserId', TYPES.VarChar, id);

        let jsonArray = []
        let rowKount = 0
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
            rowKount++;
        });

        request.on('doneProc', function (rowCount, more) {
            console.log(jsonArray);
            res.json(jsonArray);
            // return jsonArray
     
            
        });

        this.sql.callProcedure(request)
        

       
    }

    // update() updates a address for a given address ID.
    // It returns the updated address.
    update(id, updates) {
        // let updateDoc = {
        //     $set: updates
        // };
        // return this.collection
        //     .findOneAndUpdate({ _id: id }, updateDoc, { returnOriginal: false })
        //     .then(result => {
        //         return result.value;
        //     });

    }

    // delete() deletes an address for a given address ID.
    delete(id) {
        // return this.collection.deleteOne({ _id: id });

    }
}

module.exports = AddressStore;