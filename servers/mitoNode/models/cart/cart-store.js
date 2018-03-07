'use strict';

var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;
class CartStore {

    constructor(sql) {
        this.sql = sql;
    }

    // Get items in cart
    get() {

    }

    // Add items to cart
    insert() {

    }

    // Deletes items from cart
    delete() {

    }

    // Update the quantity of an item
    update() {

    }

}

module.exports = CartStore;