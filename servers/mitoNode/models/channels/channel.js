'use strict';

class Channel {
    constructor(name, description, creator) {
        // Unique channel name.
        this.name = name;

        // Description: a short description of the channel.
        this.description = description;

        // Copy of the entire profile of the user who created this channel.
        this.creator = creator;

        // Date/time the channel was created.
        this.createdAt = Date.now();

        // Date/time the channel's properties were last edited.
        this.editedAt = Date.now();

        // Note: channel object has another property _id, which will be created
        // when we insert it to MongoDB.
    }
}

module.exports = Channel;
