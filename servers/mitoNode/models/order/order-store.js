'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;
class OrderStore {

    constructor(sql) {
        this.sql = sql;
    }

    // Make an order (not to zinc yet until there is an address) - Add order to Order page
    insert() {

    }

    // Get information about order
    get() {

    }

    // Get all complete orders
    getComplete() {

    }

    // Get all pending orders
    getPending() {

    }

    // Get all past transaction/order
    getAll() {

    }

    // Update order (when a party provide an address)
    update() {


    }


    delete() {


    }
}

module.exports = OrderStore;