// @ts-check
'use strict';

const express = require('express');

const Address = require('./../models/address/address-class');
const sendToMQ = require('./message-queue');

const AddressHandler = (addressStore) => {
    if (!addressStore) {
        throw new Error('no address table found');
    }

    // A signal indicating that the promise should break here.
    class BreakSignal { }
    const breakSignal = new BreakSignal();

    const router = express.Router();

    // Get all the addresses of the User
    router.get('/v1/address/:userId', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        let userAddressId = req.body.userAddressId;
        addressStore
            .getAll(req.params.userId, userAddressId)
            .then(address => {
                console.log(address)
                res.json(address)
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            });
    });

    // Insert an address for the User
    router.post('/v1/address', (req, res) => {
        let streetAddress1 = req.body.streetAddress1;
        let streetAddress2 = req.body.streetAddress2;
        let cityName = req.body.cityName;
        let zipCode = req.body.zipCode;
        let stateName = req.body.stateName;
        // let userJSON = JSON.parse(req.get('X-User'));
        // let userId = userJSON.userId;
        let userId = req.body.userId;
        let aliasName = req.body.aliasName;
        let address = new Address(userId, streetAddress1, streetAddress2, cityName, zipCode, stateName, aliasName);

        addressStore
            .insert(address)
            .then(address => {
                res.json(address);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            })
    });

    // Delete an address from the User
    router.delete('', (req, res) => {


    });

    // Update an address from the User
    router.patch('', (req, res) => {


    });



    return router;
};

module.exports = AddressHandler;