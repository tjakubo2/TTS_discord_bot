-- Trigger a git fetch, pull and restart

local function commandFunction(body, messageObj)
    messageObj.channel:send('Updating...')
        
    -- fetch remote
    local p, err = io.popen('git fetch origin')
    if not p then
        messageObj.channel:send('Error fetching origin: ' .. err:wrap())
        return
    else
        p:read('*all')
        p:close()
    end
    
    -- check for commits ahead, report if there are any
    p, err = io.popen('git log master..origin/master --pretty=format:"%h: %s, committed by %cn (%ce)"')
    if not p then
        messageObj.channel:send('Error performing log: ' .. err:wrap())
        return
    else
        local log = p:read('*all')
        if log:len() > 0 then
            messageObj.channel:send( log:blockWrap() )
        end
        p:close()
    end
    
    -- pull and report results
    p, err = io.popen('git pull --ff-only')
    if not p then
        messageObj.channel:send('Error executing pull: ' .. err:wrap())
        return
    else
        local log = p:read('*all')
        messageObj.channel:send( log:blockWrap() )
        if not log:find('Already up-to-date', 1, true) and not log:find('Fast-forward', 1, true) then
            messageObj.channel:send( ('Pull was not fast-forward, check for local repo changes'):bold() )
            log.warn('Skipped update, pull was not fast-forward')
        end
        messageObj.channel:send('Restarting....')
        os.exit()
        p:close()
    end
end

return {'update', commandFunction, true}