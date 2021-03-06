local discordia = require('discordia')
local client = discordia.Client()

-- Globals
_G.fs = require('fs')
_G.log = require('src/log')
log.outfile = 'bot_runtime.log'
require('src/util')

log.info('')
log.info('BOT STARTUP')

-- Commands
local cmd = require('src/command')
cmd.loadCommand('example')
cmd.loadCommand('run')
cmd.loadCommand('update')

-- When the bot comes online
client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

-- On any message seen by bot
client:on('messageCreate', function(message)
    
    -- So I can easily see if it's alive
    if message.content == '!ping' then
        message.channel:send('Pong!')
    end

    -- Handle any explicit commands
    local cmdRan, result = cmd.handleMessage(message)
    if cmdRan and result then
        log.trace('Command report: ' .. result)
    end
end)

-- Run the bot
assert(fs.existsSync('token.dat'), 'No bot token file found. Create a \'token.dat\' file containing it and try again.')
client:run(fs.readFileSync('token.dat'))

