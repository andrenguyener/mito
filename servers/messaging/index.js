// @ts-check
"use strict";



const express = require("express");
const morgan = require("morgan");
const app = express();


// const PaymentStore = require("./paymentstore");
// const PaymentHandler = require("./payment");

// const ChannelStore = require("./models/channels/channel-store");
// const MessageStore = require("./models/messages/message-store");
// const Channel = require('./models/channels/channel');
// const ChannelHandler = require('./handlers/channel');
// const MessageHandler = require('./handlers/message');



// const addr = process.env.ADDR || ":80";
const addr = process.env.ADDR || "localhost:4004";
const [host, port] = addr.split(":");
const portNum = parseInt(port);


// const mongodb = require("mongodb");
// const mongoAddr = process.env.DBADDR || "mongos:27017";
const mongoAddr = process.env.DBADDR || "localhost:27017"
const mongoURL = `mongodb://${mongoAddr}/mongo`;


// const amqp = require("amqplib");
const qName = "testQ";
// const mqAddr = process.env.MQADDR || "rabbit:5672";
const mqAddr = process.env.MQADDR || "localhost:5672"
const mqURL = `amqp://${mqAddr}`;




(async () => {
    try {
        // Guarantee our MongoDB is started before clients can make any connections.
        // const db = await mongodb.MongoClient.connect(mongoURL);

        // Add global middlewares.
        app.use(morgan('dev'));
        // Parses posted JSON and makes
        // it available from req.body.
        app.use(express.json());

        // All of the following APIs require the user to be authenticated.
        // If the user is not authenticated,
        // respond immediately with the status code 401 (Unauthorized).
        // app.use((req, res, next) => {
        //     const userJSON = req.get('X-User');
        //     if (!userJSON) {
        //         res.set('Content-Type', 'text/plain');
        //         res.status(401).send('no X-User header found in the request');
        //         // Stop continuing.
        //         return;
        //     }
        //     // Invoke next chained handler if the user is authenticated.
        //     next();
        // });

        // Connect to RabbitMQ.
        // let connection = await amqp.connect(mqURL);
        // let mqChannel = await connection.createChannel();
        // Durable queue writes messages to disk.
        // So even our MQ server dies,
        // the information is saved on disk and not lost.
        // let qConf = await mqChannel.assertQueue(qName, { durable: false });
        // app.set('mqChannel', mqChannel);
        // app.set('qName', qName);

        // Initialize Mongo stores.
        // let channelStore = new ChannelStore(db, 'channels');
        // let messageStore = new MessageStore(db, 'messages');
        // let payStore = new PaymentStore(db, "payments");

        // const defaultChannel = new Channel('general', '');
        // const fetchedChannel = await channelStore.getByName(defaultChannel.name);
        // Add the default channel if not found.
        // if (!fetchedChannel) {
        //     const channel = await channelStore.insert(defaultChannel);
        // }

        // API resource handlers.
        // app.use(ChannelHandler(channelStore, messageStore));
        // app.use(MessageHandler(messageStore));
        // app.use(PaymentHandler(payStore));

        app.listen(portNum, host, () => {
            console.log(`server is listening at http://${addr}`);
        });
    } catch (err) {
        console.log(err);
    }
})();



