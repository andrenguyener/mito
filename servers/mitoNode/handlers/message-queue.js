// Send the data to RabbitMQ channel.
// Our gateway will listen to this channel,
// and then broadcast the data to all connected clients.
module.exports = function sendToMQ(req, data) {
    const mqChannel = req.app.get('mqChannel');
    const qName = req.app.get('qName');
    mqChannel.sendToQueue(qName, Buffer.from(JSON.stringify(data)));
};