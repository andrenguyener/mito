// @ts-check
'use strict';

const express = require('express');

const Image = require('./../models/image/image-class');
const sendToMQ = require('./message-queue');

const ImageHandler = (imageStore) => {
    if (!imageStore) {
        throw new Error('no address table found');
    }

    // A signal indicating that the promise should break here.
    class BreakSignal { }
    const breakSignal = new BreakSignal();

    const router = express.Router();

    // Get the profile image of the user uploaded
    router.get('/v1/image', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        imageStore
            .get(user.userId)
            .then((image) => {
                res.send(image);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            });
    });

    // Upload an image for the user
    router.post('/v1/image', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        let imageData = req.body.imageData;
        let buff = new Buffer(imageData, 'base64');
        imageStore
            .insert(user.userId, buff)
            .then((message) => {
                res.send(message);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            });
    });





    return router;
};

module.exports = ImageHandler;