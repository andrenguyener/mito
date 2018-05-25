// @ts-check
'use strict';

const express = require('express');

const Payment = require('./../models/payment/payment-class');
const sendToMQ = require('./message-queue');

const PaymentHandler = (paymentStore) => {
    if (!paymentStore) {
        throw new Error('no address table found');
    }

    // A signal indicating that the promise should break here.
    class BreakSignal { }
    const breakSignal = new BreakSignal();

    const router = express.Router();

    // Get all payments
    router.get('/v1/payment', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        var userId = user.userId;
        paymentStore
            .getPayments(userId)
            .then(payment => {
                res.json(payment)
            })
            .catch(error => {
                if (error != breakSignal) {
                    console.log(error)
                }
            });
    });

    // insert a payment method
    //cardTypeName, cardNumber, expMonth, expYear, cardCVV
    //@CardTypeName is the determine by client-side; i.e. Visa, Mastercard, AMEX
    router.post('/v1/payment', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        var userId = user.userId;
        let cardTypeName = req.body.cardTypeName;
        let cardNumber = req.body.cardNumber;
        let expMonth = req.body.expMonth;
        let expYear = req.body.expYear;
        let cardCVV = req.body.cardCVV;
        let firstName = req.body.firstName;
        let lastName = req.body.lastName;
        paymentStore
            .insert(userId, cardTypeName, cardNumber, expMonth, expYear, cardCVV, firstName, lastName)
            .then(payment => {
                res.json(payment)
            })
            .catch(error => {
                if (error != breakSignal) {
                    console.log(error)
                }
            });
    });

    // Update payment method to be default
    router.patch('/v1/payment', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        var userId = user.userId;
        let existingCardId = req.body.existingCardId;
        paymentStore
            .setDefault(userId, existingCardId)
            .then(payment => {
                res.json(payment)
            })
            .catch(error => {
                if (error != breakSignal) {
                    console.log(error)
                }
            })
    });


    // delete payment method 
    //@IsDelete: 1 = delete; 0 = not delete
    router.delete('/v1/payment', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        var userId = user.userId;
        let cardId = req.body.cardId;
        let isDelete = req.body.isDelete;
        paymentStore
            .delete(userId, cardId, isDelete)
            .then(payment => {
                res.json(payment)

            })
            .catch(error => {
                if (error != breakSignal) {
                    console.log(error)
                }
            })
    });


    return router;
};

module.exports = PaymentHandler;