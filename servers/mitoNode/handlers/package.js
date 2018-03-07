// @ts-check
'use strict';

const express = require('express');

const Address = require('./../models/address/address-class');
const sendToMQ = require('./message-queue');

const PackageHandler = (packageStore) => {
    if (!packageStore) {
        throw new Error('no address table found');
    }

    // A signal indicating that the promise should break here.
    class BreakSignal { }
    const breakSignal = new BreakSignal();

    const router = express.Router();

    // Get all incoming package
    router.get('', (req, res) => {

    });

    // Accept/Deny incoming package
    router.post('', (req, res) => {

    });


    return router;
};

module.exports = PackageHandler;