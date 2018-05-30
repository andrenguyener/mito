// @ts-check
'use strict';

const express = require('express');
var nodemailer = require("nodemailer");

var transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'projectmitoteam@gmail.com',
        pass: 'JABS2018!'
    }
});


const EmailHandler = () => {


    // A signal indicating that the promise should break here.
    class BreakSignal { }
    const breakSignal = new BreakSignal();

    const router = express.Router();

    // Email to the user
    router.post('/v1/email', (req, res) => {
        var mailOptions = {
            from: "projectmitoteam@gmail.com",
            to: req.body.email,
            subject: "Project Mito Coming Soon",
            html: `<h1>Welcome ${req.body.firstName}</h1></br><p>We will notify you once our project launches!</p></br><p>Team Mito</p>`
        };
        transporter.sendMail(mailOptions, function (error, info) {
            if (error) {
                console.log(error);
            } else {
                console.log('Email sent: ' + info.response);
                res.send('Email Sent');
            }
        });
    });





    return router;
};

module.exports = EmailHandler;