function modReset()

    regSetFloat('spears.velocity'           ,70)
    regSetFloat('spears.velocityMax'        ,300)

    regSetFloat('spears.forceMultiplier'    ,1)
    regSetFloat('spears.forceMultiplierMax' ,30)

    regSetFloat('spears.stiffness'          ,0)

    regSetFloat('spears.sharpness'          ,0)
    regSetFloat('spears.extraThrowHeight'   ,0)

    regSetBool('spears.unbreakableSpears'       , false)
    regSetBool('spears.collisions'              , true)
    regSetBool('spears.rain'                    , false)
    regSetBool('spears.throwFlat'               , false)
    regSetBool('spears.tipLight'                , false)
    regSetBool('spears.hitIndicator'            , false)
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

function setPreset_superPenetrator()
    SPEARS.mode = SPEARS.modes.flat
    regSetFloat('spears.velocity'               ,300)
    regSetFloat('spears.velocityMax'            ,300)
    regSetFloat('spears.forceMultiplier'        ,0)
    regSetFloat('spears.stiffness'    ,100)

    regSetBool('spears.unbreakableSpears'       ,true)
    regSetBool('spears.hitIndicator'            ,true)

end

function setPreset_blunt()
    regSetFloat('spears.stiffness'    ,0)
    regSetFloat('spears.sharpness'              ,0)
end

function setPreset_sharp()
    regSetFloat('spears.stiffness'    ,100)
    regSetFloat('spears.sharpness'              ,100)
end
