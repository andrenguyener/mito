// @ts-check
'use strict';

const express = require('express');

const Order = require('./../models/order/order-class');
const sendToMQ = require('./message-queue');

const CartHandler = (cartStore) => {
    if (!cartStore) {
        throw new Error('no address table found');
    }

    // A signal indicating that the promise should break here.
    class BreakSignal { }
    const breakSignal = new BreakSignal();

    const router = express.Router();

    // Get items in cart
    router.get('', (req, res) => {


    });

    // Add items to cart
    router.post('', (req, res) => {

    });

    // Deletes items from cart
    router.delete('', (req, res) => {

    });

    // Update the quantity of an item
    router.patch('', (req, res) => {

    });




    return router;
};

module.exports = CartHandler;