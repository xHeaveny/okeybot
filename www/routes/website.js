const express = require("express");
const router = express.Router();
const utils = require("../../lib/utils/utils.js");
const { client } = require("../../lib/misc/connections.js");
const commands = require("../../lib/misc/commands.js");

router.get('/', (req, res) => {
    res.render('index')
})

router.get('/commands', async (req, res) => {
    res.render('commands', { commands: client.commandsData });
});

router.get('/commands/:name', async (req, res) => {
    const command = commands.get(req.params.name.toLowerCase())
    if (!command) return res.redirect('/commands')
    res.render('command', { command });
});

router.get('/channels', async (req, res) => {
    res.render('channels');
});

router.get('/channel', async (req, res) => {
    if (!req.query.username) return res.render('channels', { error: 'No channel name specified :\\' });
    const channel = (await utils.query(`SELECT id, platform_id AS TwitchId, login, prefix, added FROM channels WHERE login=?`, [req.query.username]))[0]
    if (!channel) return res.render('channels', { error: 'Channel not found' });
    const date = new Date(channel.added)
    res.render('channel', { ...channel, added: date.toDateString() });
});

router.get('/stats', async (req, res) => {
    const { issuedCommands } = (await utils.query(`SELECT issued_commands AS issuedCommands FROM data`))[0]
    const { gb, rows } = (await utils.query("SELECT ((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024 / 1024) AS `gb`, TABLE_ROWS AS `rows` FROM information_schema.TABLES WHERE TABLE_NAME = 'messages'"))[0]
    const dbUptime = (await utils.query(`SELECT variable_value FROM information_schema.global_status WHERE variable_name='Uptime'`))[0].variable_value
    const dbQueries = (await utils.query(`SELECT variable_value FROM information_schema.global_status WHERE variable_name = 'Questions'`))[0].variable_value
    const { connections, topics } = require('../../lib/misc/pubsub.js')

    res.render('stats', {
        channelCount: Object.keys(client.userStateTracker.channelStates).length,
        uptime: utils.humanize(client.connectedAt),
        issuedCommands: { lr: utils.formatNumber(client.issuedCommands), all: utils.formatNumber(issuedCommands) },
        commands: client.knownCommands.length,
        ram: Math.round(process.memoryUsage().rss / 1024 / 1024),
        messages: { logged: utils.formatNumber(rows), size: gb.toFixed(3) },
        dbUptime: utils.humanizeMS(dbUptime * 1000),
        dbQueries: utils.formatNumber(dbQueries),
        qps: (dbQueries / dbUptime).toFixed(3),
        redisKeys: (await utils.redis.dbsize()),
        pubsub: { connections: connections.length, topics: topics.length }
    });
});

router.get('/spotify', async (req, res) => {
    res.render('spotify');
});

module.exports = router;