// @ts-check
'use strict';

const express = require('express');

const Order = require('./../models/order/order-class');
const sendToMQ = require('./message-queue');

const OrderHandler = (orderStore) => {
    if (!orderStore) {
        throw new Error('no address table found');
    }

    // A signal indicating that the promise should break here.
    class BreakSignal { }
    const breakSignal = new BreakSignal();

    const router = express.Router();

    // TODO: Talk to Sopheak to decide how to handle pending/incoming packages

    router.get('/v1/order/:orderId', (req, res) => {


    });

    router.get('', (req, res) => {


    });

    router.get('', (req, res) => {


    });


    router.post('', (req, res) => {

    });




    return router;
};

module.exports = OrderHandler;