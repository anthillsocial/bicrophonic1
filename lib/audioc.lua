-- Embedded system for Kaffe Matthews 
-- Copyright (C) 2012 Tom Keene 
--
-- Forked from https://github.com/anthillsocial/sonic-bike-swamp
--  
-- Original Authors:
-- Copyright (C) 2012 Wolfgang Hauptfleisch, Dave Griffiths
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

module("audioc", package.seeall)
local mt = { __index = {} }
local suffix = '.wav'
local samples = {}
local port = 12345
local channelcount = 0
local skipload = false

--- new bicrophonic system
local function send_osc(message)
    if CONFIG.debug == "true" then
        utils.log(CONFIG.logfile, oscmessage)
    end
    -- send an OS message (using os.execute as a temporary measure, better to have native lua OSC though linux modules are not working)
    os.execute(oscmessage)
    posix.sleep(0.25)
    print('-----------------')
    return true
end

-- old swamp system
local function send(message)
    local pipe = io.open("/tmp/dodo", "w")
    if pipe then
        --print("audioc writing: "..message)
        pipe:write(message.."\n")
    else
        print("audioc failed to open pipe")
        return false
    end
    pipe:close()
    return true
end

-- Work out which audo channel we should load/unload
-- And generally keep of track of whats happing with audio
-- Including how much memory its taking up as the OpenFrameworks sound module uses 6 X soundfileSize in memory!!!
function updatesamples(id, state)
    local file=CONFIG.audio_path..id
    -- Create a new sample in the samples array if it doesn't exist
    if samples[id] == nil then
	    samples[id] = {['channel']=channelcount,['size']=0, ['state']=state, ['history']=state, ['randomfile']=nil}
        channelcount = channelcount+1
        local filestat = posix.stat(file)
        if filestat then
	        samples[id]['size'] = filestat.size
            samples[id]['size_mb'] = std.round(filestat.size/1024/1024, 1)
        end
    else
        -- Very usefull debugger
        -- samples[id]['history'] = samples[id]['history']..','..state
        samples[id]['state'] = state 
    end
    -- Check if we should be playing a random file
    --if samples[id]['randomfile'] ~= nil then
    --    id = samples[id]['randomfile'] 
    --end
    -- Loop through the samples array
    local msg = ''
    local totalsize = 0
    local nloaded = 0
    for key,val in pairs(samples) do 
        local vars = ''
        for key2,val2 in pairs(samples[key]) do
            vars = vars..'\n  ['..key2..'] '..val2..' '
            -- Lets work out the total size of all loaded files
            if key2 == 'size' and  samples[key]['state'] ~= 'unload' then
                totalsize = totalsize+samples[key]['size']
                nloaded = nloaded+1
            end
        end
        msg = msg..key..vars..'\n'
    end
    -- Now lets find out available memory and make sure we don't run out!
    freemem = utils.os.capture("free | grep Mem | awk '{print $4}'")  
    freemem = tonumber(freemem)
    -- And check if we are able to load it
    if samples[id]['state'] == 'load'  then
        headroom = samples[id]['size']*CONFIG.audio_filesizeheadroomX
        headroommb = std.round(headroom/1024/1024, 1)
        freememmb = std.round(freemem/1024, 1) 
        if headroommb > freememmb then
            -- don't load the sample
            utils.log(CONFIG.logfile, '[MemoryError] Can\'t load:'..id..' Filesize:'..samples[id]['size_mb']..' Needed:'..headroommb..' Free:'..freememmb)
            totalsize = totalsize - samples[id]['size']
            samples[id]['size'] = 0
            samples[id]['size_mb'] = '0mb'
            skipload = true
        end
    end
    -- And log some pretty output so we know whats happening
    freemem = std.round(freemem/1024, 1)..'mb'
    totalsize = std.round(totalsize/1024/1024, 1)..'mb'  
    msg = ''
    msg = msg..'nChannels['..CONFIG.audio_channels..'] '
    msg = msg..'nLoadedSamples['..nloaded..'] '
    msg = msg..'totalSize['..totalsize..'] '
    msg = msg..'FreeMem['..freemem..']' 
    if CONFIG.debug == "true" then
        utils.log(CONFIG.logfile, msg)
    end
    -- Return the channel this sample is loaded in
    channel = samples[id]['channel']
    return channel
end

---
function load(id)
    if CONFIG.mode == 'swamp' then
        send("load "..id) 
    else
        local channel = updatesamples(id..suffix, 'load')
        -- Only load the file if there is enough memory
        if skipload == false then 
            send_osc('send_osc '..port..' /load '..channel..' '..id..suffix)
        end
        skipload = false
        --posix.sleep(0.5)
    end
end

function unload(id)
    if CONFIG.mode == 'swamp' then
        send("unload "..id) 
    else
        local channel = updatesamples(id..suffix, 'unload')
        send_osc('send_osc '..port..' /unload '..channel)
        if samples[id..suffix]['randomfile'] ~= nil then
            randomchannel = updatesamples(samples[id..suffix]['randomfile'] , 'random')
            --posix.sleep(0.25)
            send_osc('send_osc '..port..' /unload '..randomchannel)
        end
    end
end

function positionloop(id)
    if CONFIG.mode == 'swamp' then    
        print('posloop')
    else
        local channel = updatesamples(id..suffix, 'positionloop')
        -- Allow the worms script (wifi, analog) to change this sample
        send_osc('send_osc '..port..' /masschange '..channel..' 1 superlooper') 
    end
end

function random(id)
    if CONFIG.mode == 'swamp' then    
        print('random')
    else
        --local channel = updatesamples(id..suffix, 'random') 
        --key=id..suffix
        --randomfile = scandirforrandom(CONFIG.audio_path, id)
        --print('------PLAY RANDOM--------:'..randomfile)
        --samples[key]['randomfile'] = randomfile
        --send_osc('send_osc '..port..' /unload '..channel)
        --randomchannel = updatesamples(samples[key]['randomfile'] , 'random')
        --if skipload == false then
        --    posix.sleep(0.5)
        --    send_osc('send_osc '..port..' /load '..randomchannel..' '..samples[key]['randomfile'])
        --    print('------LOAD RANDOM FILE:'..randomfile..' channel:'..randomchannel)
        --end
        --skipload = false
        print('random')
    end
end
    
function pitch(id, speed)
    if CONFIG.mode == 'swamp' then 
        local message = speed.." "..id
        send(message)
    else
        local channel = updatesamples(id..suffix, 'pitch')
        -- Allow the worms script to change this sample 
        send_osc('send_osc '..port..' /masschange '..channel..' 1 pitch') 
    end
end

function volume(id)
    if CONFIG.mode == 'swamp' then 
        print('volume')
    else
        local channel = updatesamples(id..suffix, 'volume')
        -- Allow the worms script to change this sample 
        send_osc('send_osc '..port..' /masschange '..channel..' 1 volume') 
    end
end

function startpoint(id)
    if CONFIG.mode == 'swamp' then 
        print('startpoint')
    else
        local channel = updatesamples(id..suffix, 'startpoint')
        -- Allow the worms script to change this sample 
        send_osc('send_osc '..port..' /masschange '..channel..' 1 startpoint') 
    end
end

function play(id, pan)
    if CONFIG.mode == 'swamp' then 
        local message
        if not channel then
            message = "play "..id
        else
            message = "play_"..channel.." "..id
        end
        --print("sending "..message)
        send(message)
    else
        -- channel=pan
        local channel = updatesamples(id..suffix, 'play')
        send_osc('send_osc '..port..' /play '..channel)
    end
end

function loop(id, channel)
    if CONFIG.mode == 'swamp' then 
        local message
        if not channel then
            message = "loop "..id
        else
            message = "loop_"..channel.." "..id
        end
        send(message)
    else
        local channel = updatesamples(id..suffix, 'loop')
        send_osc('send_osc '..port..' /loopplay '..channel)   
    end
end

---
function stop(id)
    if CONFIG.mode == 'swamp' then 
        local message = "stop "..id
        send(message)
    else
        local channel = updatesamples(id..suffix, 'stop')
        send_osc('send_osc '..port..' /pause '..channel..' 1') 
    end
end

---
function shift(id, channel)
    if CONFIG.mode == 'swamp' then 
        local message
        message = channel.." "..id
        send(message)
    else
        local id = id..suffix
        local newchannel = updatesamples(id, 'shift')
        send_osc('send_osc '..port..' /loop '..channel..' 1') 
    end
end

---
function fadeout(id)
    if CONFIG.mode == 'swamp' then 
        local message = "fadeout "..id
        send(message)
    else
        local channel = updatesamples(id..suffix, 'fadeout')
        -- TODO: need to implement proper fade out in the audio engine...
        send_osc('send_osc '..port..' /pause '..channel..' 1') 
    end
end

function scandirforrandom(directory, prefix)
    local i, t, popen = 0, {}, io.popen
    for filename in popen('ls -a "'..directory..'"'):lines() do
        len = string.len(prefix)
        potential = string.sub(filename,1,len)
        if potential == prefix then
            i = i + 1 
            t[i] = filename
            --print(filename)
        end
    end
    if i == 0 then
        return prefix..suffix
    end 
    math.randomseed(os.time())
    rand = math.random(i)
    return t[rand]
end
