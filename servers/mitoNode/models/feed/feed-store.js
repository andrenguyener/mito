'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;

class FeedStore {

    constructor(sql) {
        this.sql = sql;
    }

    request(procedure) {
        return new Request(`${procedure}`), function (err) {
            if (err) {
                console.log(err);
            }
        }
    }

    // Add User order to feed
    insert(feed) {

    }

    // Get all friends past orders (limited to only names and message)
    getAll(id) {

    }

}

module.exports = FeedStore;