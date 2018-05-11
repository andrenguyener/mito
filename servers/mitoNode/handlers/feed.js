// @ts-check
'use strict';

const express = require('express');

const Feed = require('./../models/feed/feed-class');
const sendToMQ = require('./message-queue');

const FeedHandler = (feedStore) => {
    if (!feedStore) {
        throw new Error('no address table found');
    }

    // A signal indicating that the promise should break here.
    class BreakSignal { }
    const breakSignal = new BreakSignal();

    const router = express.Router();

    // Get all orders that another users has sent and received between friends
    router.post('v1/feed', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        var userId = user.userId;
        let friendId = req.body.friendId;
        feedStore
            .get(friendId)
            .then(feed => {
                res.json(feed)
            })
            .catch(error => {
                if (error != breakSignal) {
                    console.log(error)
                }
            })
    });

    // Get all orders that users has sent and received between friends
    router.get('v1/feed', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        var userId = user.userId;
        feedStore
            .get(userId)
            .then(feed => {
                res.json(feed)
            })
            .catch(error => {
                if (error != breakSignal) {
                    console.log(error)
                }
            })
    });

    // Get all orders that relevant friends has sent or received
    router.get('v1/feed/friends', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        var userId = user.userId;
        feedStore
            .getFriendsFeed(userId)
            .then(feed => {
                res.json(feed)
            })
            .catch(error => {
                if (error != breakSignal) {
                    console.log(error)
                }
            })
    });


    return router;
};

module.exports = FeedHandler;