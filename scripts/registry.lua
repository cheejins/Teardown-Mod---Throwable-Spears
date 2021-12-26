function modReset()

    regSetFloat('spears.velocity'           ,80)
    regSetFloat('spears.velocityMax'        ,150)

    regSetFloat('spears.forceMultiplier'    ,1)
    regSetFloat('spears.forceMultiplierMax' ,20)

    regSetFloat('spears.sharpness'          ,20)
    regSetFloat('spears.extraThrowHeight'   ,0)

    regSetBool('spears.unbreakableSpears'       , true)
    regSetBool('spears.collisions'              , false)
    regSetBool('spears.rain'                    , false)
    regSetBool('spears.throwFlat'               , false)
    regSetBool('spears.tipLight'                , true)
    regSetBool('spears.hitMarker'               , false)
    regSetBool('spears.yeetMode'                , false)

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
