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
    class BreakSignal { }
    const breakSignal = new BreakSignal();

    const router = express.Router();

    // Get information about a friend
    router.get('', (req, res) => {

    });

    // Get all the friends of a given UserId
    router.get('/v1/friend/:userId/:friendType', (req, res) => {

        friendStore
            .getAll(req.params.userId, req.params.friendType)
            .then(friend => {
                console.log(friend);
                res.json(friend);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            });
    });

    // Add a new friend
    router.post('/v1/friend', (req, res) => {
        let userId = req.body.userId;
        let friendId = req.body.friendId;
        friendStore
            .insert(userId, friendId)
            .then((message) => {
                res.send(message);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            });
    });

    // Get all pending requests of given User
    router.post('v1/friend/pendingrequest', (req, res) => {
        // Userid
        // bit 0 or 1 // 0 = all non friends (pending) 1 = all friends except pending
        let userId = req.body.userId;
        let bit = req
    })

    // Update (upgrade/downgrade) friend status
    router.patch('', (req, res) => {

    });

    // Update friend request (accept/decline)
    router.patch('', (req, res) => {

    });

    // Delete a friend from the UserId
    router.delete('', (req, res) => {

    });


    return router;
};

module.exports = FriendHandler;