// @ts-check
"use strict";


const express = require("express");
const morgan = require("morgan");
const app = express();
// var Curl = require('node-libcurl').Curl;
// var curl = new Curl();

// curl.setOpt('URL', 'www.google.com');
// curl.setOpt('FOLLOWLOCATION', true);

// curl.on('end', function (statusCode, body, headers) {

//     console.info(statusCode);
//     console.info('---');
//     console.info(body.length);
//     console.info('---');
//     console.info(this.getInfo('TOTAL_TIME'));

//     this.close();
// });

// curl.on('error', curl.close.bind(curl));
// curl.perform();
var Connection = require('tedious').Connection;
var ConnectionPool = require('tedious-connection-pool');

// var CONFIG = require('./config.json');

// config for your database
var config = {
    userName: "mitoteam",
    password: "JABS2018!",
    server: "projectmito.database.windows.net",
    options: {
        encrypt: true,
        database: "projectmito"
    }
};

var poolConfig = {
    min: 1,
    max: 20
};

var connectionConfig = {
    userName: "mitoteam",
    password: "JABS2018!",
    server: "projectmito.database.windows.net",
    options: {
        encrypt: true,
        database: "projectmito"
    }
}

const AddressStore = require("./models/address/address-store");
const Address = require('./models/address/address-class');
const AddressHandler = require('./handlers/address');

const FriendStore = require("./models/friend/friend-store");
const Friend = require('./models/friend/friend-class');
const FriendHandler = require('./handlers/friend');

const OrderStore = require('./models/order/order-store');
const Order = require('./models/order/order-class');
const OrderHandler = require('./handlers/order');

const FeedStore = require('./models/feed/feed-store');
const Feed = require('./models/feed/feed-class');
const FeedHandler = require('./handlers/feed');

const PackageStore = require('./models/package/package-store');
const Package = require('./models/package/package-class');
const PackageHandler = require('./handlers/package');

const CartStore = require('./models/cart/cart-store');
const Cart = require('./models/cart/cart-class');
const CartHandler = require('./handlers/cart');

const PaymentStore = require('./models/payment/payment-store');
const Payment = require('./models/payment/payment-class');
const PaymentHandler = require('./handlers/payment');

const ImageStore = require('./models/image/image-store');
const Image = require('./models/image/image-class');
const ImageHandler = require('./handlers/image');

const NotificationStore = require('./models/notification/notification-store');
const Notification = require('./models/notification/notification-class');
const NotificationHandler = require('./handlers/notification');

const AmazonHashHandler = require('./handlers/amazon');


const addr = process.env.ADDR || "localhost:4004";
const [host, port] = addr.split(":");
const portNum = parseInt(port);

const amqp = require("amqplib");
const qName = "testQ";
const mqAddr = process.env.MQADDR || "rabbit:5672";
// const mqAddr = process.env.MQADDR || "localhost:5672"
const mqURL = `amqp://${mqAddr}`;
var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;

var test = process.env.TEST;
console.log(test);

(async () => {
    try {
        // TODO make connection a Promise 
        // let sql = await new Connection(config);
        // sql.on('connect', function (err) {
        //     // If no error, then good to proceed. 
        //     if (err) {
        //         console.log(err)
        //     } else {
        //         console.log("Connected");
        //         // executeStatement(connection);
        //     }
        // });

        var sql = new ConnectionPool(poolConfig, connectionConfig);
        sql.on('error', function (err) {
            console.error(err);
        });


        // Add global middlewares.
        app.use(morgan('dev'));
        // Parses posted JSON and makes
        // it available from req.body.
        app.use(express.json());

        // All of the following APIs require the user to be authenticated.
        // If the user is not authenticated,
        // respond immediately with the status code 401 (Unauthorized).
        app.use((req, res, next) => {
            const userJSON = req.get('X-User');
            if (!userJSON) {
                res.set('Content-Type', 'text/plain');
                res.status(401).send('no X-User header found in the request');
                // Stop continuing.
                return;
            }
            // Invoke next chained handler if the user is authenticated.
            next();
        });

        // Connect to RabbitMQ.
        let connection = await amqp.connect(mqURL);
        let mqChannel = await connection.createChannel();
        // Durable queue writes messages to disk.
        // So even our MQ server dies,
        // the information is saved on disk and not lost.
        let qConf = await mqChannel.assertQueue(qName, { durable: false });
        app.set('mqChannel', mqChannel);
        app.set('qName', qName);




        // Initialize table stores.
        let addressStore = new AddressStore(sql);
        let friendStore = new FriendStore(sql);
        let orderStore = new OrderStore(sql);
        let feedStore = new FeedStore(sql);
        let packageStore = new PackageStore(sql);
        let cartStore = new CartStore(sql);
        let paymentStore = new PaymentStore(sql);
        let imageStore = new ImageStore(sql);
        let notificationStore = new NotificationStore(sql);

        // API resource handlers.
        app.use(AddressHandler(addressStore));
        app.use(FriendHandler(friendStore));
        app.use(OrderHandler(orderStore));
        app.use(FeedHandler(feedStore));
        app.use(PackageHandler(packageStore));
        app.use(CartHandler(cartStore));
        app.use(PaymentHandler(paymentStore));
        app.use(ImageHandler(imageStore));
        app.use(NotificationHandler(notificationStore));

        app.use(AmazonHashHandler());
        app.listen(portNum, host, () => {
            console.log(`server is listening at http://${addr}`);
        });
    } catch (err) {
        console.log(err);
    }
})();



