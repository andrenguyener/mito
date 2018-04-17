// @ts-check
'use strict';

const express = require('express');

const Friend = require('./../models/friend/friend-class');
const sendToMQ = require('./rabbit-queue');

const FriendHandler = (friendStore) => {
    if (!friendStore) {
        throw new Error('no address table found');
    }

    // A signal indicating that the promise should break here.
    class BreakSignal { }
    const breakSignal = new BreakSignal();

    const router = express.Router();

    // Get information about a friend
    router.get('', (req, res) => {

    });

    // Get all the friends of a given UserId
    router.get('/v1/friend/:friendType', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        console.log(user);
        friendStore
            .getAll(user.userId, req.params.friendType)
            .then(friend => {
                console.log(friend);
                res.json(friend);
                const data = {
                    type: 'friend-get',
                    friend: friend,
                    userIdOut: user.userId
                };
                console.log(data);
                sendToMQ(req, data);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            });
    });

    // get the count of mutual friends
    router.get('/v1/friend/mutual/:friendUserId', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        console.log(user);
        friendStore
            .getMutualFriends(user.userId, req.params.friendUserId)
            .then(friend => {
                console.log(friend);
                res.json(friend);
                const data = {
                    type: 'friend-get',
                    friend: friend,
                    userIdOut: user.userId
                };
                console.log(data);
                sendToMQ(req, data);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            });
    });

    // Add a new friend
    router.post('/v1/friend', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        console.log(user);
        let friendId = req.body.friendId;
        friendStore
            .insert(user.userId, friendId)
            .then((message) => {
                res.send(message);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            });
    });

    // Get friend type of 2 users
    router.post('/v1/friend/type', (req, res) => {
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        let friendId = req.body.friendId;
        friendStore
            .getType(user.userId, friendId)
            .then((message) => {
                res.send(message);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            });
    });

    // Update (upgrade/downgrade) friend status
    router.patch('', (req, res) => {

    });

    // Update friend request (accept/decline)
    router.patch('/v1/friend/request', (req, res) => {
        // @User1Id INT,
        // @User2Id INT,
        // @FriendTypeToUpdate NVARCHAR(25), friend, unfriend, blocked
        // @FriendTypeRequestResponse NVARCHAR(25)
        const userJSON = req.get('X-User');
        const user = JSON.parse(userJSON);
        let friendId = req.body.friendId;
        let friendType = req.body.friendType;
        let notificationType = req.body.notificationType
        friendStore
            .updateFriendRequest(user.userId, friendId, friendType, notificationType)
            .then((message) => {
                res.send(message);
            })
            .catch(err => {
                if (err !== breakSignal) {
                    console.log(err);
                }
            });
    });

    // Delete a friend from the UserId
    router.delete('', (req, res) => {

    });


    return router;
};

module.exports = FriendHandler;