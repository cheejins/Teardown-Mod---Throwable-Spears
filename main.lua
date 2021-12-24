#include "scripts/debug.lua"
#include "scripts/registry.lua"
#include "scripts/spear.lua"
#include "scripts/ui.lua"
#include "scripts/utility.lua"

function init()

    checkRegInitialized()
    initUi()

    initSpears()

end

function tick()

    processInput()
    updateSpears()

    convertPipebombs()
    processSpears()

end

function draw()
    uiManageGameOptions()
end
