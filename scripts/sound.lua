function initSounds()

    sounds = {
        yeets = {
            LoadSound("MOD/snd/yeet_gentle.ogg"),
            LoadSound("MOD/snd/yeet_swagger.ogg"),
            LoadSound("MOD/snd/yeet_sam.ogg"),
            LoadSound("MOD/snd/yeet_yeet.ogg"),
        },
    }

    sounds.play = {
        yeet = function(pos, vol)
            sounds.playRandom(pos, sounds.yeets, vol or 1)
        end,
    }

    sounds.playRandom = function(pos, soundsTable, vol)
        local p = soundsTable[math.random(1, #soundsTable)]
        PlaySound(p, pos, vol or 1)
    end

end
