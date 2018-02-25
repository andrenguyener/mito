// @ts-check
'use strict';

const mongodb = require('mongodb');
const express = require('express');

const Message = require('./../models/messages/message');
const sendToMQ = require('./message-queue');

