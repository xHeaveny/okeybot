const Twitch = require('dank-twitch-irc');

const utils = require('./lib/utils/utils.js');
const { helix } = require('./lib/utils/twitchapi.js')
const { logger } = require('./lib/utils/logger.js')

require('dotenv').config()
require('./www')

const { client } = require('./lib/misc/connections.js')
const { handle } = require('./lib/misc/handler.js')
const pubsub = require('./lib/misc/pubsub.js')

const fs = require('fs')
const collection = require('@discordjs/collection')

client.commands = new collection();
const commandFiles = fs.readdirSync('./lib/commands').filter(file => file.endsWith('.js'));

for (const file of commandFiles) {
    const command = require(`./lib/commands/${file}`);
    client.commands.set(command.name, command)
}

client.knownCommands = ["8ball", "copypasta", "dadjoke", "donger", "everyone", "fill", "%", "ping", "prefix", "pyramid", "title", "tts", "uptime", "weather", "yourmom", "notify", "help", "subemotes", "uid", "steam", "cat", "dog", "channels", "geoip", "query", "botinfo", "firstmsg", "randline", "chatters", "mostsent", "findmsg", "esearch", "avatar", "stalk", "math", "stats", "funfact", "suggest", "lines"]
let cmdsJSON = []
for (let cmdName of client.knownCommands) {
    let badgeURL;
    const cmd = client.commands.get(cmdName)

    switch (cmd.access) {
        case "mod": badgeURL = 'https://static-cdn.jtvnw.net/badges/v1/3267646d-33f0-4b17-b3df-f923a41db1d0/2'; break;
        case "vip": badgeURL = 'https://static-cdn.jtvnw.net/badges/v1/b817aba4-fad8-49e2-b88a-7cc744dfa6ec/2'; break;
    }

    cmdsJSON[cmdsJSON.length] = {
        name: cmd.name,
        nameEncoded: encodeURIComponent(cmd.name),
        aliases: cmd.aliases?.join(', '),
        description: cmd.description,
        access: cmd.access,
        accessBadge: badgeURL,
        cooldown: cmd.cooldown,
        preview: cmd.preview
    }
}
fs.writeFileSync("./data/help.json", JSON.stringify(cmdsJSON), { encoding: 'utf8', flag: 'w' })

client.connect();

client.on("ready", async () => {
    client.connectedAt = Date.now()
    const channels = (await utils.query('SELECT login FROM channels WHERE parted=?', [false])).map(channel => channel.login)
    client.joinAll(channels)
    pubsub.connect()
    listenEvents()
    utils.supinicAPIping()
    setInterval(utils.supinicAPIping, 600000)
    client.say(process.env.botusername, 'Connected AlienPls')
    logger.info("Connected to chat");
});

process.on('SIGINT', () => {
    client.say(process.env.botusername, `Exiting... ppCircle`)
    logger.info(`Exiting...`)
})

client.on("close", (error) => {
    if (error) return logger.error("Client closed due to error", error);
    logger.error('Client closed without an error')
});

client.on('NOTICE', async ({ channelName, messageID, messageText }) => {
    if (!messageID) return;

    switch (messageID) {
        case 'msg_rejected':
        case 'msg_rejected_mandatory': {
            logger.error(`received msg_rejected/mandatory from ${channelName} -> ${messageText}`);
            break;
        }

        case 'no_permission': {
            logger.error(`no permission from ${channelName} -> ${messageText}`);
            await client.say(channelName, 'I have no permission to perform that action');
            break;
        }

        case 'msg_banned': {
            logger.info(`bot is banned in ${channelName}`);
            const data = (await utils.query(`SELECT COUNT(id) AS entries FROM channels WHERE login=?`, [channelName]))[0]
            if (data.entries) await utils.query(`UPDATE channels SET parted=? WHERE login=?`, [true, channelName])
            break;
        }

        case 'host_on':
        case 'bad_delete_message_mod':
        case 'msg_channel_suspended':
        case 'host_target_went_offline':
            break;

        default:
            logger.info(`notice ${messageID} in channel ${channelName} -> ${messageText}`);
    }
});

client.issuedCommands = 0

client.on("PRIVMSG", async (msg) => {
    let channelData;
    const cacheData = await utils.cache.get(msg.channelID)

    if (cacheData && cacheData.login === msg.channelName) {
        channelData = JSON.parse(cacheData)
    } else {
        channelData = (await utils.query(`SELECT login, prefix, added FROM channels WHERE platform_id=?`, [msg.channelID]))[0]
        await utils.cache.set(msg.channelID, JSON.stringify(channelData))
    }

    const msgData = {
        'user': {
            'id': msg.senderUserID,
            'name': msg.displayName,
            'login': msg.senderUsername,
            'colorRaw': msg.colorRaw,
            'badgesRaw': msg.badgesRaw,
            'color': msg.color,
            'badges': msg.badges.map(badge => badge.name),
            'perms': { mod: msg.isMod, broadcaster: msg.badges.hasBroadcaster, vip: msg.badges.hasVIP }
        },
        'channel': {
            'id': msg.channelID,
            'login': msg.channelName,
            'query': channelData
        },
        'isAction': msg.isAction,
        'raw': msg.rawSource,
        'text': msg.messageText,
        'timestamp': msg.serverTimestampRaw,
        'tags': msg.ircTags,

        send: async function (message) {
            try {
                message = utils.fitText(message, 490)
                await client.say(this.channel.login, message)
            } catch (e) {
                if (e instanceof Twitch.SayError && e.message.includes('@msg-id=msg_rejected')) {
                    return await this.send(`${this.user.name}, the reply message violates the channel blocked terms (automod)`);
                }
                await this.send(`${this.user.name}, an unexcepted error occurred when sending the reply message`);
                console.error(`error while sending reply message in ${this.channel.login}: ${e}`);
            }
        }
    }

    handle(msgData)
})

client.on("JOIN", async (o) => {
    logger.info(`Joined ${o.channelName}`)
});

client.on("PART", async (o) => {
    logger.info(`Parted ${o.channelName}`)
});

async function listenEvents() {
    const events = ['stream.online', 'stream.offline', 'channel.update'];

    const channels = await utils.query('SELECT user_id AS id, login FROM notify_data')

    for (let channel of channels) {
        let requestBody = {
            "type": null,
            "version": "1",
            "condition": {
                "broadcaster_user_id": channel.id
            },
            "transport": {
                "method": "webhook",
                "callback": `${process.env.website_url}/api/webhooks/callback`,
                "secret": process.env.twitchSigningSecret
            }
        }

        for (let event of events) {
            requestBody['type'] = event
            const { body } = await helix.post('eventsub/subscriptions', { json: requestBody })
            if (!body.error) logger.info(`created listener ${requestBody.type} for ${channel.login}`)
            else if (body?.error !== 'Conflict') logger.error(`failed listening ${requestBody.type} for ${channel.login} (${body.error}): ${body.message}`)
        }
    }
}