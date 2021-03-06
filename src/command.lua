local cmd = {}

-- Prefix for all commands
cmd.prefix = '!'

-- Does a string contain a command?
function cmd.hasCommand(msgString)
    return msgString:find('^' .. cmd.prefix)
end

-- Parse the command name and body from a string
function cmd.getCommand(msgString)
    if not cmd.hasCommand(msgString) then
        return
    end
    local command, body = msgString:match('^' .. cmd.prefix .. '(%S+)(.-)$')
    body = body:match('^%s*(.-)%s*$')
    return command, body
end

-- Command callback functions keyed by their name
cmd.commands = {
    -- those can be ran by anyone
    regular = {},
    -- those can be ran only by users from 'elevated_users.txt' file
    admin = {}
}
local cmds = cmd.commands

-- Register a command
function cmd.addCommand(name, callback, adminOnly)
    local target = adminOnly and cmds.admin or cmds.regular
    assert(not target[name], 'Trying to add \'' .. name .. '\' command twice')
    target[name] = callback
end

-- Load a command from appropriate file under commands dir
-- (mostly for convenience)
local commandsPath = 'src/commands/'
function cmd.loadCommand(filename)
    local res = require(commandsPath .. filename)
    assert(res, 'Failed to load ' .. commandsPath .. filename)
    cmd.addCommand( unpack(res) )
    log.trace(commandsPath .. filename .. ' loaded')
end

-- Check if user is in the eleveated_users.txt list
-- User needs to be a discordia object (e.g. message.author)
-- elevated_users.txt is re-read every time so it can be externally updated whenever
function cmd.isElevatedUser(userObject)
    if not fs.existsSync('elevated_users.txt') then
        return false
    end
    local elevatedUsers = fs.readFileSync('elevated_users.txt')
    return elevatedUsers:find(userObject.fullname, 1, true) ~= nil
end


function cmd.handleMessage(msgObject)
    
    if cmd.hasCommand(msgObject.content) then
        local command, body = cmd.getCommand(msgObject.content)
        
        log.trace('Received ' .. command .. ' cmd from ' .. msgObject.author.fullname)
        
        -- Admin command with privileges
        if cmds.admin[command] and cmd.isElevatedUser(msgObject.author) then
            log.trace(' -- Handling as admin command')
            return true, cmds.admin[command](body, msgObject)
            
        -- Regular command
        elseif cmds.regular[command] then
            log.trace(' -- Handling as regular cmd')
            return true, cmds.regular[command](body, msgObject)
            
        -- Admin command without privileges
        elseif cmds.admin[command] then
            log.trace(' -- Skipping an admin command')
            msgObject.channel:send('This command can only be used by elevated users')
            return false
        end
    end
    return false
end

return cmd

