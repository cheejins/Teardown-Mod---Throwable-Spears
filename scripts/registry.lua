function modReset()



    regSetFloat('spears.velocity'           ,70)
    regSetFloat('spears.velocityMax'        ,150)

    regSetFloat('spears.sharpness'          ,20)
    regSetFloat('spears.forceMultiplier'    ,1)
    regSetFloat('spears.forceMultiplierMax' ,10)

    regSetFloat('spears.extraThrowHeight'   ,0)

    regSetBool('spears.impaling'    , true)

end

function checkRegInitialized()
    local regInit = GetBool('savegame.mod.regInit')
    if regInit == false then
        modReset()
        SetBool('savegame.mod.regInit', true)
    end
end

function regGetFloat(path)
    local p = 'savegame.mod.' .. path
    return GetFloat(p)
end
function regSetFloat(path, value)
    local p = 'savegame.mod.' .. path
    SetFloat(p, value)
end

function regGetBool(path)
    local p = 'savegame.mod.' .. path
    return GetBool(p)
end
function regSetBool(path, value)
    local p = 'savegame.mod.' .. path
    SetBool(p, value)
end
