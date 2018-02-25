'use strict';


class AddressStore {
    constructor(sql, tableName) {
        // this.collection = db.collection(colName);
        // this should be a table
        this.sql = sql;
        this.table = `[${tableName}]`;

    }

    request(procedure) {
        return new Request(`${procedure}`), function(err) {
            if (err) {  
                console.log(err);
            }  
        }
    }

    // insert() creates a new address in SqlServer.
    insert(address) {
        // channel._id = new mongodb.ObjectID();
        // return this.collection.insertOne(channel).then(() => channel);
        let procedureName = "AddressProcedure";
        var request = request(`${procedureName}`);
        var addressId;
        request.addParameter('userId', TYPES.VarChar, address.userId);
        request.addParameter('streetAddress1', TYPES.VarChar, address.streetAddress1);
        request.addParameter('streetAddress2', TYPES.VarChar, address.streetAddress2);
        request.addParameter('cityName', TYPES.VarChar, address.cityName);
        request.addParameter('zipCode', TYPES.Int, address.zipCode);
        request.addParameter('stateName', TYPES.VarChar, address.stateName);
        request.addOutputParameter('id', addressId);
        
        this.sql.callProcedure(request)
    }

    // get() retrieves an address from SqlServer for a given address ID.
    get(id) {
        // return this.collection.findOne({ _id: id });
    }

    // // getByName retrieves one channel from MongoDB for a given channel name.
    // getByName(name) {
    //     return this.collection.findOne({ name: name });
    // }

    // getAll() retrieves all addresses from SqlServer.
    getAll() {
        // return this.collection
        //     .find({})
        //     .limit(100)
        //     .toArray();
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