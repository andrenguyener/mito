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
    router.post('v1/cart', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        let amazonASIN = req.body.amazonASIN;
        let amazonPrice = req.body.amazonPrice;
        let quantity = req.body.quantity;
        cartStore
            .insert(user.userId, amazonASIN, amazonPrice, quantity)
            .then((cart) => {
                res.send(cart);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            });
    });

    // Process checkout of cart
    router.post('v1/cart/process', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        let userAddressId = req.body.userAddressId;
        let recipientId = req.body.recipientId;
        let message = req.body.message;
        let giftOption = req.body.giftOption;
        cartStore
            .insert(user.userId, userAddressId, recipientId, message, giftOption)
            .then((cart) => {
                res.send(cart);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            });
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