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

    // Deals with anything we are receving, incoming packgages, updating packaging (yes/no), get pending

    // Get all incoming package
    router.get('/v1/package/incoming', (req, res) => {

    });

    // Get pending packages of user
    router.post('/v1/package', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        var userId = user.userId;
        let type = req.body.type;
        packageStore
            .getPackages(userId, type)
            .then(packages => {
                res.json(packages)
                // const data = {
                //     type: 'cart-get',
                //     cart: cart,
                //     userIdOut: userId
                // };
                // sendToMQ(req, data);
            })
            .catch(error => {
                if (error != breakSignal) {
                    console.log(error)
                }
            });
    });

    // Accept/Deny incoming package
    router.patch('/v1/package', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        var userId = user.userId;
        let senderId = req.body.senderId;
        let orderId = req.body.orderId;
        let response = req.body.response;
        let shippingAddressId = req.body.shippingAddressId;
        packageStore
            .update(userId, senderId, orderId, response, shippingAddressId)
            .then(packages => {
                res.json(packages)
                // const data = {
                //     type: 'cart-get',
                //     cart: cart,
                //     userIdOut: userId
                // };
                // sendToMQ(req, data);
            })
            .catch(error => {
                if (error != breakSignal) {
                    console.log(error)
                }
            })
    });


    // get incoming package
    //

    // get pending package
    // uspcGetMyPendingPackages
    // UserId param int

    // updating package
    // uspcConfirmPackage
    // UserId param int
    // SenderId param int
    // OrderId param int
    // Response param nvarchar  "Accepted/Pending/Denied"
    // ShippingAddressId param int (Receievers default or one they choose)


    return router;
};

module.exports = PackageHandler;