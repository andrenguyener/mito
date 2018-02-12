'use strict';

class Address {
    constructor(channelID, body, creator) {
        // ObjectId of channel to which this message belongs.
        this.channelID = channelID;

        // The body of the message (text).
        this.body = body;

        // Date/time the message was created.
        this.createdAt = Date.now();

        // Copy of the entire profile of the user who created this message.
        this.creator = creator;

        // Date/time the message body was last edited.
        this.editedAt = Date.now();

        this.summaries = [];

        // Note: message object has another property _id, which will be created
        // when we insert it to MongoDB.
    }
}

module.exports = Address;