"use strict";



const mongodb = require("mongodb");

class MessageStore {

    constructor(db, colName) {
        this.collection = db.collection(colName);
    }

    insert(message) {
        message._id = new mongodb.ObjectID();
        return this.collection.insertOne(message)
            .then(() => message);
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

    getAll(chanID) {
        return this.collection.find({channelID: chanID})
            .limit(50)
            .toArray();
    }

    delete(id) {
        return this.collection.deleteOne({_id: id});
    }

    deleteAll(id) {
        return this.collection.deleteMany({channelID: id});
    }

}

module.exports = MessageStore;