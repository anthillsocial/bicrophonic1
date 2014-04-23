#!/usr/bin/lua

-- Swamp Bike Opera embedded system for Kaffe Matthews 
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

local scriptpath=string.match(arg[0], '^.*/')

package.path = package.path..";"..scriptpath.."/?.lua;"..scriptpath.."/../lib/?.lua"

require 'engine'
require 'gps'
require 'posix'
require 'poly'
require 'map'
require 'direction'
require 'random'
require 'socket'
require 'utils'
require 'json'

CONFIG=utils.load_json("../config.json")  

local logfile = CONFIG.logfile
local gpsdev  = CONFIG.gps_device
local mapfile = CONFIG.mapfile
local fake_gps = CONFIG.fake_gps
local audio_player_bin = CONFIG.audio_player_bin
local module  = "bicrophonic1"

-- lets connect to a fake gps trail
file = io.open(CONFIG.fake_gps, "r")
io.input(file)

while true do
        -- read fake gps every second
        posix.sleep(0.5)
        local line = io.read()
        if line then
            line = string.sub(line, 26)
            print(line)
            local lat, lng = string.match(line, "^(.-)%s(.-)$")
        else
            print("no gps")
        end
end






