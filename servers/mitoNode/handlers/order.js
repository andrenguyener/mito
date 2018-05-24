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

    // get all the products within an orderId
    router.post('/v1/order/products', (req, res) => {
        // let userJSON = JSON.parse(req.get('X-User'));
        // let userId = userJSON.userId;
        let orderId = req.body.orderId;
        orderStore
            .get(orderId)
            .then(order => {
                res.json(order);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            })
    });

    // ZINC get an order 
    // attach the the requestid
    router.post('', (req, res) => {


    });

    router.get('', (req, res) => {


    });


    router.post('', (req, res) => {

    });




    return router;
};

module.exports = OrderHandler;