// @ts-check
'use strict';

const express = require('express');

const Address = require('./../models/address/address-class');
const sendToMQ = require('./message-queue');

const FeedHandler = (feedStore) => {
    if (!feedStore) {
        throw new Error('no address table found');
    }

    // A signal indicating that the promise should break here.
    class BreakSignal { }
    const breakSignal = new BreakSignal();

    const router = express.Router();

    // Get all friends past orders (limited to only names and message)
    router.get('', (req, res) => {

    });

    // Add User to feed
    router.post('', (req, res) => {

    });


    return router;
};

module.exports = FeedHandler;