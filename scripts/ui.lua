function initUi()

    UI_OPTIONS = false

    font_normal = 24
    font_heading = 42

    checkRegInitialized()

end

function uiDrawOptions()

    local w = UiWidth()
    local h = UiHeight()

    do UiPush()

        UiColor(1,1,1, 1)
        UiFont('bold.ttf', 24)
        UiAlign('center middle')

        marginYSize = 50
        local marginY = 0

        do UiPush()

            UiTranslate(UiCenter(), UiMiddle())

            do UiPush()
                UiColor(0,0,0, 0.75)
                UiRect(700, 200)
            UiPop() end

            do UiPush()

                UiTranslate(-250, 0)

                ui.slider.create('Spear Velocity', 'spears.velocity', 'm/s', 1, 500)
                UiTranslate(0, marginYSize)
                marginY = marginY + marginYSize

            UiPop() end

        UiPop() end

        do UiPush()

            local resetW = 200
            local closeW = 80
            local wAlign = (resetW + closeW) / 2

            UiTranslate(UiCenter()-wAlign, UiMiddle() + 150)

            UiAlign('center middle')
            UiImageBox("ui/common/box-outline-fill-6.png", closeW, 50, 10, 10)
            if UiTextButton('Close') then
                UI_OPTIONS = not UI_OPTIONS
            end

            UiTranslate(resetW/2 + closeW/2 + 10, 0)

            UiImageBox("ui/common/box-outline-fill-6.png", resetW, 50, 10, 10)
            if UiTextButton('Reset Spear') then
                modReset()
            end

        UiPop() end


    UiPop() end

end


--- Manage when to open and close the options menu.
function uiManageGameOptions()

    if InputPressed('rmb') then UI_OPTIONS = not UI_OPTIONS end

    if UI_OPTIONS then
        UiMakeInteractive()
        uiDrawOptions()
    end

end



ui = {}

ui.colors = {
    white = Vec(1,1,1),
    g3 = Vec(0.5,0.5,0.5),
    g2 = Vec(0.35,0.35,0.35),
    g1 = Vec(0.2,0.2,0.2),
    black = Vec(0,0,0),
}



ui.slider = {}

function ui.slider.create(title, registryPath, valueText, min, max, w, h, fontSize, axis)

    local value = GetFloat('savegame.mod.' .. registryPath)

    min = min or 0
    max = max or 300

    do UiPush()

        -- UiTranslate(0, 10)
        -- UiButtonImageBox('img/reset.png', 1,1,1, 1,1)
        -- if UiBlankButton(40,40) then
        --     modReset()
        -- end
        -- UiTranslate(40, -10)

        UiAlign('left middle')

        -- Text header
        UiColor(1,1,1, 1)
        UiFont('regular.ttf', fontSize or font_normal)
        UiText(title)
        UiTranslate(0, fontSize or font_normal)

        -- Slider BG
        UiColor(0.4,0.4,0.4, 1)
        local slW = w or 400
        UiRect(slW, h or 10)

        -- Convert to slider scale.
        value = ((value-min) / (max-min)) * slW

        -- Slider dot
        UiColor(1,1,1, 1)
        UiAlign('center middle')
        value, done = UiSlider("ui/common/dot.png", "x", value, 0, slW)
        if done then
            local val = (value/slW) * (max-min) + min -- Convert to true scale.
            SetFloat('savegame.mod.' .. registryPath, val)
        end

        -- Slider value
        do UiPush()
            UiAlign('left middle')
            UiTranslate(slW + 20, 0)
            local decimals = ternary((value/slW) * (max-min) + min < 100, 3, 1)
            UiText(sfn((value/slW) * (max-min) + min, decimals) .. ' ' .. (valueText))
        UiPop() end

    UiPop() end

end



ui.checkBox = {}

function ui.checkBox.create(title, registryPath)

    local value = GetBool('savegame.mod.' .. registryPath)

    UiAlign('left middle')

    -- Text header
    UiColor(1,1,1, 1)
    UiFont('regular.ttf', fontSize or font_normal)
    UiText(title)
    UiTranslate(0, fontSize or font_normal)

    -- Toggle BG
    UiAlign('left top')
    UiColor(0.4,0.4,0.4, 1)
    local tglW = w or 140
    local tglH = h or 40
    UiRect(tglW, h or tglH)

    -- Render toggle
    do UiPush()

        local toggleText = 'ON'

        if value then
            UiTranslate(tglW/2, 0)
            UiColor(0,0.8,0, 1)
        else
            toggleText = 'OFF'
            UiColor(0.8,0,0, 1)
        end

        UiRect(tglW/2, tglH)

        do UiPush()
            UiTranslate(tglW/4, tglH/2)
            UiColor(1,1,1, 1)
            UiFont('bold.ttf', font_normal)
            UiAlign('center middle')
            UiText(toggleText)
        UiPop() end

    UiPop() end

    UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 0,0,0, a)
    if UiBlankButton(tglW, tglH) then
        SetBool('savegame.mod.' .. registryPath, not value)
        PlaySound(LoadSound('clickdown.ogg'), GetCameraTransform().pos, 1)
    end

end