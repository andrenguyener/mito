// @ts-check
'use strict';
const mongodb = require("mongodb");
const express = require('express');
var nodemailer = require("nodemailer");

var transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'p2pgoddex@gmail.com',
      pass: 'vietnam.123'
    }
});

const PaymentHandler = payStore => {
    if (!payStore) {
        throw new Error('no payment store found');
    }
    const router = express.Router();


    router.post("/v1/payments", (req, res) => {
        // let user = JSON.parse(req.get("X-user"));
        if (req.body.firstName != "") {
            let payment = {
                firstName: req.body.firstName,
                lastName: req.body.lastName,
                email: req.body.email,
                streetAddressBilling: req.body.streetAddressBilling,
                cityBilling: req.body.cityBilling,
                stateBilling: req.body.stateBilling,
                zipcodeBilling: req.body.zipcodeBilling,
                countryBilling: req.body.countryBilling,
                firstNameShipping: req.body.firstNameShipping,
                lastNameShipping: req.body.lastNameShipping,
                streetAddressShipping: req.body.streetAddressShipping,
                cityShipping: req.body.cityShipping,
                stateShipping: req.body.stateShipping,
                zipcodeShipping: req.body.zipcodeShipping,
                countryShipping: req.body.countryShipping,
                recipientEmail: req.body.recipientEmail,
                creditcard: req.body.creditcard,
                expiration: req.body.expiration,
                ccv: req.body.ccv,
                item: req.body.item,
                price: req.body.price,
                createdAt: new Date(),
                accept: true
                // payer: user
            }
            payStore.insert(payment)
                .then(payment => {
                    res.json(payment);
                    var mailOptions = {
                        from: "p2pgoddex@gmail.com",
                        to: payment.recipientEmail,
                        subject: "New Package Request",
                        html: '<h1>Welcome</h1><p>' + payment.firstName + ' is trying to send you a package, a ' + payment.item + '. Please complete your shipping information <a href="http://localhost:3000/#/confirm/' + payment._id + '" target="_blank">Here</a>'   
                    };
                    transporter.sendMail(mailOptions, function(error, info){
                        if (error) {
                        console.log(error);
                        } else {
                        console.log('Email sent: ' + info.response);
                        }
                    });
                })
                .catch(err => {
                    throw err;
                });
            
    } else {
            res.send("invalid name");
        }
    });

    router.patch("/v1/payments/:userID", (req, res) => {
        // let user = JSON.parse(req.get("X-User"));
        let userToGet = new mongodb.ObjectID(req.params.userID);
        let updates;
        updates = {
            firstNameShipping: req.body.firstNameShipping,
            lastNameShipping: req.body.lastNameShipping,
            streetAddressShipping: req.body.streetAddressShipping,
            cityShipping: req.body.cityShipping,
            stateShipping: req.body.stateShipping,
            zipcodeShipping: req.body.zipcodeShipping,
            countryShipping: req.body.countryShipping
        };
        
        payStore.get(userToGet)
            .then(payUser => {
                if (payUser != null) {
                    payStore.update(userToGet, updates)
                        .then(pay => {
                            res.json(pay);
                            var mailOptions = {
                                from: 'p2pgoddex@gmail.com',
                                to: payUser.email,
                                subject: 'Package Request Accepeted!',
                                html: '<h1>That was easy!</h1><p>Shipping address to ' + updates.streetAddressShipping + ' ' + updates.cityShipping + ' ' + updates.stateShipping + ' ' + updates.zipcodeShipping + ' has been completed</p>'
                            };
                            transporter.sendMail(mailOptions, function(error, info){
                                if (error) {
                                console.log(error);
                                } else {
                                console.log('Email sent: ' + info.response);
                                }
                            });
                        })
                        .catch(err => {
                            throw err;
                        });
                } else {
                    res.status(403).send("User did not create this channel");
                }
            })
            .catch(err => {
                throw err;
            });
    });


    router.post("/v1/email", (req, res) => {
        // let user = JSON.parse(req.get("X-user"));
        if (req.body.name != "" && req.body.email != "" && req.body.subject != "" && req.body.message != "") {
            let email = {
                name: req.body.name,
                email: req.body.email,
                subject: req.body.subject,
                message: req.body.message
            }
            var mailOptions = {
                from: "p2pgoddex@gmail.com",
                to: "andrenguyenp@gmail.com",
                subject: "Andren.io New Message",
                html: `name: ${email.name} email: ${email.email} subject: ${email.subject} message: ${email.message}` 
            };
            transporter.sendMail(mailOptions, function(error, info) {
                if (error) {
                    res.status(503).send("Error sending email");
                    console.log(error);
                } else {
                    res.json(email);
                    console.log('Email sent: ' + info.response);
                }
            });
        }
    });

    return router;
};



                        

module.exports = PaymentHandler;