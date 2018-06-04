local discordia = require('discordia')
local fs = require('fs')
local client = discordia.Client()

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

client:on('messageCreate', function(message)
	if message.content == '!ping' then
		message.channel:send('Pong!')
	end

	if message.content == '!quit' then
		message.channel:send('Exiting....')
		os.exit()
	end

	if message.content == '!update' then
		os.execute('git pull --ff-only')
		os.exit()
	end
    
    if message.content == '!woo' then
        message.channel:send('Wee')
    end

end)

client:run(fs.readFileSync('token.dat'))

