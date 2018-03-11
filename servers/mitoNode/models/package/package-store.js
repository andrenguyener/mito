'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;

class PackageStore {

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

    // Get all incoming package
    getAll(id) {

    }

    // Update Accept/Deny incoming package
    update() {

    }

}

module.exports = PackageStore;