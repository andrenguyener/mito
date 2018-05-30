// @ts-check
'use strict';

const express = require('express');
var nodemailer = require("nodemailer");
// var pug = require('pug');

// const compiledFunction = pug.compileFile('./welcome.pug');

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
            // html: `<h1>Welcome ${req.body.firstName}</h1></br><p>We will notify you once our project launches!</p></br><p>Team Mito</p>`
            html: `<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">

            <head>
                <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
                <style type="text/css"></style>
            </head>
            
                <body style="padding: 0; width: 100% !important; -webkit-text-size-adjust: 100%; margin: 0; -ms-text-size-adjust: 100%" marginheight="0"
                    marginwidth="0">
                    <center>
                        <table cellpadding="8" cellspacing="0" style="*width: 540px; padding: 0; width: 100% !important; background: #ffffff; margin: 0; background-color: #ffffff"
                            border="0">
                            <tr>
                                <td valign="top">
                                    <table cellpadding="0" cellspacing="0" style="border-radius: 6px; -webkit-border-radius: 6px; border: 1px #c0c0c0 solid; -moz-border-radius: 6px"
                                        border="0" align="center">
                                        <tr>
                                            <td colspan="3" height="6"></td>
                                        </tr>
                                        <tr style="line-height: 0px">
                                            <td width="100%" style="font-size: 0px" align="center" height="1">
                                                <!-- <img width="40px" style="max-height: 110px; width: 70px; *width: 70px; *height: 110px" alt="" src="cid:MitoLogo" /> -->
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <table cellpadding="0" cellspacing="0" style="line-height: 25px" border="0" align="center">
                                                    <tr>
                                                        <td colspan="3" height="30"></td>
                                                    </tr>
                                                    <tr>
                                                        <td width="36"></td>
                                                        <td width="454" align="left" style="color: #444444; border-collapse: collapse; font-size: 11pt; font-family: proxima_nova, 'Open Sans', 'Lucida Grande', 'Segoe UI', Arial, Verdana, 'Lucida Sans Unicode', Tahoma, 'Sans Serif'; max-width: 454px"
                                                            valign="top">
                                                            <p>Hello ${req.body.firstName}!</p>
                                                            <p>We would like to welcome you as our newest member!</p>
                                                            <p>Thank you very much for your interest and we will notify you once our application
                                                                launches! If you have any questions, or suggestions, please feel free
                                                                to email us.
                                                                <p> - The Mito team</p>
                                                        </td>
                                                        <td width="36"></td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="3" height="36"></td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                    <table cellpadding="0" cellspacing="0" align="center" border="0">
                                        <tr>
                                            <td height="10"></td>
                                        </tr>
                                        <tr>
                                            <td style="padding: 0; border-collapse: collapse">
                                                <table cellpadding="0" cellspacing="0" align="center" border="0">
                                                    <tr style="color: #c0c0c0; font-size: 11px; font-family: proxima_nova, 'Open Sans', 'Lucida Grande', 'Segoe UI', Arial, Verdana, 'Lucida Sans Unicode', Tahoma, 'Sans Serif'; -webkit-text-size-adjust: none">
                                                        <td width="400" align="left"></td>
                                                        <td width="128" align="right">© </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </center>
                </body>`
            // ,
            // attachments: [{
            //     filename: 'GiftGreen.png',
            //     path: '/handlers/GiftGreen.png',
            //     cid: 'MitoLogo' 
            // }]
        };
        transporter.sendMail(mailOptions, function (error, info) {
            if (error) {
                console.log(error);

            } else {
                var mailOptions2 = {
                    from: "projectmitoteam@gmail.com",
                    to: "projectmitotest@gmail.com",
                    subject: "Mito Newsletter",
                    html: `<h1> ${req.body.email} ${req.body.firstName}} </h1>`
                }
                transporter.sendMail(mailOptions2, function (error, info) {
                    if (error) {
                        console.log(error);
                        var mailOptions2 = {
                            from: "projectmitoteam@gmail.com",
                            to: "projectmitotest@gmail.com",
                            subject: "Mito Newsletter",
                            body: `${req.body.email} ${req.body.firstName}`
                        }
                    } else {

                    }
                });
                console.log('Email sent: ' + info.response);
                res.send('Email Sent');
            }
        });

    });



    return router;
}


module.exports = EmailHandler;