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

    isUsingTool = GetString('game.player.tool') == 'pipebomb'

    processInput()
    updateSpears()

    convertPipebombs()
    processSpears()
    processSpearMode()

    debugMod()

end

function draw()

    if isUsingTool then
        do UiPush()
            uiManageGameOptions()
        UiPop() end

        do UiPush()
            drawSpearQuickOptions()
        UiPop() end

        do UiPush()
            drawToolText()
        UiPop() end
    end

end
