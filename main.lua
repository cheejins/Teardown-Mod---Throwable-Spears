#include "scripts/debug.lua"
#include "scripts/registry.lua"
#include "scripts/spear.lua"
#include "scripts/ui.lua"
#include "scripts/utility.lua"

function init()

    GlobalBody = FindBodies('', true)[1]

    checkRegInitialized()
    initUi()

    initSpears()

end

function tick()

    processInput()
    updateSpears()

    convertPipebombs()
    processSpears()

    debugMod()

end

function draw()
    uiManageGameOptions()
    drawSpearForce()
end
