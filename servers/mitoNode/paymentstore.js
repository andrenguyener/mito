"use strict";



const mongodb = require("mongodb");

class PaymentStore {

    constructor(db, colName) {
        this.collection = db.collection(colName);
    }

    insert(user) {
        user._id = new mongodb.ObjectID();
        return this.collection.insertOne(user)
            .then(() => user);
    }
        update(id, updates) {
        let updateDoc = {
            "$set": updates
        }

        return this.collection.findOneAndUpdate(
            {_id: id}, 
            updateDoc, 
            {returnOriginal: false})
            .then(result => result.value);
    }
    get(id) {
        return this.collection.findOne({_id: id});
    }

    getAll(userID) {
        return this.collection.find({payerID: userID})
            .limit(50)
            .toArray();
    }

    delete(id) {
        return this.collection.deleteOne({_id: id});
    }

    deleteAll(id) {
        return this.collection.deleteMany({payerlID: id});
    }

}

module.exports = PaymentStore;