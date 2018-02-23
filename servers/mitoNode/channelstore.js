"use strict";



const mongodb = require("mongodb");

class ChannelStore {

    constructor(db, colName) {
        this.collection = db.collection(colName);
    }

    insert(channel) {
        channel._id = new mongodb.ObjectID();
        return this.collection.insertOne(channel)
            .then(() => channel);
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

    delete(id) {
        return this.collection.deleteOne({_id: id});
    }

    getAll() {
        return this.collection.find({}).toArray();
    }

    
}


module.exports = ChannelStore;