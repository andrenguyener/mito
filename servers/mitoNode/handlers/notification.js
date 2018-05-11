// @ts-check
'use strict';

const express = require('express');

const Notification = require('./../models/notification/notification-class');
const sendToMQ = require('./message-queue');

const NotificationHandler = (notificationStore) => {
    if (!notificationStore) {
        throw new Error('no address table found');
    }

    // A signal indicating that the promise should break here.
    class BreakSignal { }
    const breakSignal = new BreakSignal();

    const router = express.Router();

    // Get all notifications that will be sent to you (friend request, incoming packages)
    router.get('/v1/notification', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        notificationStore
            .get(user.userId)
            .then((notification) => {
                res.send(notification);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            });
    });

    return router;
};

module.exports = NotificationHandler;