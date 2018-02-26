// @ts-check
'use strict';

const express = require('express');

const Friend = require('./../models/friend/friend-class');
const sendToMQ = require('./message-queue');

const FriendHandler = (friendStore) => {
    if (!friendStore) {
        throw new Error('no address table found');
    }

    // A signal indicating that the promise should break here.
    class BreakSignal {}
    const breakSignal = new BreakSignal();

    const router = express.Router();

    router.get('/v1/friend/:userId', (req, res) => {
        let userId = req.params.userId;
        friendStore.getAll(userId, res);
          
    });


    router.post('', (req, res) => {

    });
    
    
  

    return router;
};

module.exports = FriendHandler;