// @ts-check
'use strict';

const express = require('express');

const Address = require('./../models/address/address');
const sendToMQ = require('./message-queue');

const AddressHandler = (addressStore) => {
    if (!addressStore) {
        throw new Error('no address table found');
    }

    // A signal indicating that the promise should break here.
    class BreakSignal {}
    const breakSignal = new BreakSignal();

    const router = express.Router();

    router.get('/v1/address', (req, res) => {
        console.log("hi")
    });

    router.post('/v1/address', (req, res) => {
        let streetAddress1 = req.body.streetAddress1;
        let streetAddress2 = req.body.streetAddress2;
        let cityName = req.body.cityName;
        let zipCode = req.body.zipCode;
        let stateName = req.body.stateName;
        let userJSON = JSON.parse(req.get('X-User'));
        let userId = userJSON.userId;
        const address = new Address(userId, streetAddress1, streetAddress2, cityName, zipCode, stateName);

    });
    
    
  

    return router;
};

module.exports = AddressHandler;