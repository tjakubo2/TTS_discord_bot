-- EXAMPLE COMMAND TEMPLATE
-- These have to be ran as "<prefix><cmd_name> <cmd_body>"
-- E.g. "!example some params here maybe?"


-- This will be called when command is sent in chat
-- body is a string of everything that followed command
-- messageObj is Discordia object of command message 
-- (see https://github.com/SinisterRectus/Discordia/wiki/Message)
local function commandFunction(body, messageObj)
    -- Whisper the command body to sender
    messageObj.author:send('It works! You command body was ' .. (body:len() > 0 and body:wrap() or 'empty'))
    
    -- Add a reaction to message that triggered it
    -- (these have to be unicode codepoints)
    messageObj:addReaction('\u{1F44B}') -- hello wave
    
    -- your stuff
    
    -- you can return some results for logging purposes
    return messageObj.author.fullname .. ' tested me!'
end

-- Return a table of {command_name, callback, is_admin}
-- command_name is the string that triggers this command (prefixed with command character)
-- callback is a function that gets called when this command is sent on Discord
-- is_admin restricts the command only to users from elevated_users.txt if set to true
return {'example', commandFunction, false}