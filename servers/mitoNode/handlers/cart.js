// @ts-check
'use strict';

const express = require('express');

const Cart = require('./../models/cart/cart-class');
const sendToMQ = require('./rabbit-queue');

const CartHandler = (cartStore) => {
    if (!cartStore) {
        throw new Error('no address table found');
    }

    // A signal indicating that the promise should break here.
    class BreakSignal { }
    const breakSignal = new BreakSignal();

    const router = express.Router();

    // Get items in cart
    router.get('/v1/cart/retrieve', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        var userId = user.userId;
        cartStore
            .get(userId)
            .then(cart => {
                res.json(cart)
                const data = {
                    type: 'cart-get',
                    data: cart,
                    userIdOut: userId
                };
                sendToMQ(req, data);
            })
            .catch(error => {
                if (error != breakSignal) {
                    console.log(error)
                }
            })

    });

    // Add items to cart
    router.post('/v1/cart', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        let amazonASIN = req.body.amazonASIN;
        let productName = req.body.productName;
        let productImageUrl = req.body.productImageUrl;
        let amazonPrice = req.body.amazonPrice;
        let quantity = req.body.quantity;
        cartStore
            .insert(user.userId, amazonASIN, productName, productImageUrl, amazonPrice, quantity)
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
    router.post('/v1/cart/process', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        let senderAddressId = req.body.senderAddressId;
        let recipientId = req.body.recipientId;
        let cardId = req.body.cardId;
        let message = req.body.message;
        let giftOption = req.body.giftOption;
        cartStore
            .process(user.userId, senderAddressId, recipientId, cardId, message, giftOption)
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