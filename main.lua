#include "scripts/debug.lua"
#include "scripts/registry.lua"
#include "scripts/sound.lua"
#include "scripts/spear.lua"
#include "scripts/ui.lua"
#include "scripts/utility.lua"

version = '22-04-02'

function init()

    GlobalBody = FindBodies('', true)[1]

    RegisterTool("throwableSpears", "Throwable Spear", "MOD/vox/tool.vox")
    SetBool('game.tool.throwableSpears.enabled', true)

    checkRegInitialized()
    initUi()
    initSounds()

    initSpears()

end

function tick()

    isNotGrabbing = GetPlayerGrabBody() == 0 and GetPlayerGrabShape() == 0
    isUsingTool = GetString('game.player.tool') == 'throwableSpears' and GetPlayerVehicle() == 0 and isNotGrabbing

    processInput()
    updateSpears()

    convertSpawnedSpear()

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
