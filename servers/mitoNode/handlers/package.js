

const express = require('express');
const axios = require('axios');
const Package = require('./../models/package/package-class');
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

    // Get all sent packages
    router.get('/v1/package', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        var userId = user.userId;
        packageStore
            .getSentPackages(userId)
            .then(packages => {
                res.json(packages)

            })
            .catch(error => {
                if (error != breakSignal) {
                    console.log(error)
                }
            });
    });

    // Get pending/accepted/denied packages of user
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
                if (packages == "User denied package") {
                    axios({
                        method: 'get',
                        url: `https://api.projectmito.io/v1/users/id?id=${user.userId}`
                    })
                        .then(function (response) {
                            // console.log(response);
                            const data = {
                                type: 'package-denied',
                                data: response.data,
                                userIdOut: senderId
                            };
                            sendToMQ(req, data);
                        })
                        .catch(function (error) {
                            console.log(error);
                        });

                } else {
                    axios({
                        method: 'get',
                        url: `https://api.projectmito.io/v1/users/id?id=${user.userId}`
                    })
                        .then(function (response) {
                            // console.log(response);
                            const data = {
                                type: 'package-accept',
                                data: response.data,
                                userIdOut: senderId
                            };
                            sendToMQ(req, data);
                        })
                        .catch(function (error) {
                            console.log(error);
                        });

                    // axios({
                    //     method: 'post',
                    //     url: 'https://api.zinc.io/v1/orders',
                    //     auth: {
                    //         username: 'janedoe',
                    //     },
                    //     data: {
                    //         firstName: 'Fred',
                    //         lastName: 'Flintstone'
                    //     }
                    // })
                    //     .then(function (response) {
                    //         console.log(response)
                    //     })
                    //     .catch(function (error) {

                    //     });
                }



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