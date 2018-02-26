// @ts-check
'use strict';

const mongodb = require('mongodb');
const express = require('express');

const Message = require('./../../models/messages/message');
const sendToMQ = require('./../message-queue');

const MessageHandler = messageStore => {
    if (!messageStore) {
        throw new Error('no channel and/or message store found');
    }

    class BreakSignal {}
    const breakSignal = new BreakSignal();

    const router = express.Router();

    // Allow message creator to modify this message.
    router.patch('/v1/messages/:messageID', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        const messageID = new mongodb.ObjectID(req.params.messageID);

        messageStore
            .get(messageID)
            .then(message => {
                if (message.creator.id !== user.id) {
                    res.set('Content-Type', 'text/plain');
                    res.status(403).send('only message creator can modify this message');
                    throw breakSignal;
                }
                return;
            })
            .then(() => {
                const updates = {
                    body: req.body.body,
                    editedAt: Date.now()
                };
                return messageStore.update(messageID, updates);
            })
            .then(updatedMessage => {
                res.json(updatedMessage);
                const data = {
                    type: 'message-update',
                    message: updatedMessage
                };
                sendToMQ(req, data);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            });
    });

    // Allow message creator to delete this message.
    router.delete('/v1/messages/:messageID', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        const messageID = new mongodb.ObjectID(req.params.messageID);

        messageStore
            .get(messageID)
            .then(message => {
                if (message.creator.id !== user.id) {
                    res.set('Content-Type', 'text/plain');
                    res.status(403).send('only message creator can delete this message');
                    throw breakSignal;
                }
                return;
            })
            .then(() => {
                return messageStore.delete(messageID);
            })
            .then(deletedMessage => {
                res.set('Content-Type', 'text/plain');
                res.status(200).send('message deleted');
                const data = {
                    type: 'message-delete',
                    messageID: messageID
                };
                sendToMQ(req, data);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            });
    });

    return router;
};

module.exports = MessageHandler;