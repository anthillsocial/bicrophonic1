#!/bin/lua
function scandirforrandom(directory, prefix)
    local i, t, popen = 0, {}, io.popen
    for filename in popen('ls -a "'..directory..'"'):lines() do
        len = string.len(prefix)
        potential = string.sub(filename,1,len)
        if potential == prefix then
            i = i + 1
            t[i] = filename
        end
    end
    math.randomseed(os.time())
    if i == 0 then
        return prefix..'.wav'
    end
    rand = math.random(i)
    return t[rand]
end
prefix="clap1"
randomfile = scandirforrandom("/home/sonic/sdcard/findingsonghome/sound", prefix)
print(randomfile)
