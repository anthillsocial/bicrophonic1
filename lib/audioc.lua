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
---
local function send_osc(oscmessage)
    print(oscmessage)
    if CONFIG.debug == "true" then
        utils.log(CONFIG.logfile, oscmessage)
    end
    -- send an OS message (using os.execute as a temporary measure, better to have native lua OSC)
    os.execute(oscmessage)
    print('-----------------')
    --local pipe = io.open("/tmp/dodo", "w")
    --if pipe then
      ----print("audioc writing: "..message)
    --   pipe:write(message.."\n")
    --else
    --   print("audioc failed to open pipe")
    --   return false
    --end
    --pipe:close()
    return true
end

-- Work out which audo channel we should load/unload
function updatesamples(id, state)
    local file=CONFIG.audio_path..id
    -- Create a new sample if it doesn't exist
    if samples[id] == nil then
	    samples[id] = {['channel']=channelcount, ['state']=state, ['history']=state}
        channelcount = channelcount+1
        local filestat = posix.stat(file)
        if filestat then
	        samples[id]['size'] = filestat.size
            samples[id]['size_mb'] = std.round(filestat.size/1024/1024, 1)
        end
    else
        samples[id]['history'] = samples[id]['history']..','..state
        samples[id]['state'] = state 
    end
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
    -- Now lets find out available memory
    freemem = utils.os.capture("free | grep Mem | awk '{print $4}'")  
    freemem = tonumber(freemem)
    -- And check if we are able to load it
    if samples[id]['state'] == 'load' and freemem  then
        samples[id]['state'] = 'load'
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
    return samples[id]['channel']
end

---
function load(id)
    local channel = updatesamples(id..suffix, 'load')
    --os.execute('sleep 2')
    send_osc('send_osc '..port..' /load '..channel..' '..id..suffix)
end

function unload(id)
    local channel = updatesamples(id..suffix, 'unload')
    send_osc('send_osc '..port..' /unload '..channel)
end

function play(id, pan)
    -- channel=pan
    local channel = updatesamples(id..suffix, 'play')
    send_osc('send_osc '..port..' /play '..channel)
end

function loop(id, channel)
    local channel = updatesamples(id..suffix, 'loop')
    send_osc('send_osc '..port..' /loopplay '..channel)   
end

---
function stop(id)
    local channel = updatesamples(id..suffix, 'stop')
    send_osc('send_osc '..port..' /pause '..channel..' 1') 
end

---
function shift(id, channel)
    local id = id..suffix
    local newchannel = updatesamples(id, 'shift')
    send_osc('send_osc '..port..' /loop '..channel..' 1') 
end

---
function fadeout(id)
    local channel = updatesamples(id..suffix, 'fadeout')
    -- TODO: need to implement proper fade out in the audio engine...
    send_osc('send_osc '..port..' /pause '..channel..' 1') 
end

---
function pitch(id, speed)
    send_osc('send_osc '..port..' /pitch '..channel..' 0.5') 
end

