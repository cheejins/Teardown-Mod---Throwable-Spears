function initUi()

    UI_OPTIONS = false

    font_normal = 24
    font_heading = 42

    checkRegInitialized()

end

function uiDrawOptions()

    local w = UiWidth()
    local h = UiHeight()

    local cont_w = 1400
    local cont_h = 800
    local cont_marginY = 100

    do UiPush()

        UiColor(1,1,1, 1)
        UiFont('bold.ttf', 24)
        UiAlign('center middle')

        marginYSize = 80
        local marginY = 0
        UiTranslate(0, cont_marginY)

        do UiPush()
            UiTranslate(UiCenter(), 0)
            UiAlign('center top')
            UiColor(0,0,0, 0.75)
            UiRect(cont_w, cont_h)

            if InputDown('lmb') and not UiIsMouseInRect(cont_w, cont_h) then
                UI_OPTIONS = not UI_OPTIONS
            end


        UiPop() end

        do UiPush()
            UiTranslate(UiCenter(), 32)
            UiAlign('center top')
            UiFont('bold.ttf', 72)
            UiText('Spear Options')
        UiPop() end

        UiTranslate(0, 200)

        do UiPush()

            UiTranslate(UiCenter()-270, 0)

            do UiPush()

                UiTranslate(-250, 10)

                do UiPush()

                    UiFont('regular.ttf', 24)
                    UiText('Throw Mode: ')
                    UiTranslate(-142, 60)

                    UiColor(0.75,0.75,0.75, 1)
                    UiAlign('center middle')

                    local btnW = 120
                    local btnH = 50
                    local btnSpacing = btnW + 20

                    UiTranslate(btnSpacing, 0)
                    do UiPush()
                        if SPEARS.mode == SPEARS.modes.straight then
                            UiColor(0,1,0, 1)
                            UiFont('bold.ttf', 26)
                        end
                        UiButtonImageBox("ui/common/box-outline-fill-6.png", 10,10)
                        if UiTextButton('Forward', btnW, btnH) then
                            SPEARS.mode = SPEARS.modes.straight
                        end
                    UiPop() end

                    UiTranslate(btnSpacing, 0)
                    do UiPush()
                        if SPEARS.mode == SPEARS.modes.flat then
                            UiColor(0,1,0, 1)
                            UiFont('bold.ttf', 26)
                        end
                        UiButtonImageBox("ui/common/box-outline-fill-6.png", 10,10)
                        if UiTextButton('Flat', btnW, btnH) then
                            SPEARS.mode = SPEARS.modes.flat
                        end
                    UiPop() end

                    UiTranslate(btnSpacing, 0)
                    do UiPush()
                        if SPEARS.mode == SPEARS.modes.rain then
                            UiColor(0,1,0, 1)
                            UiFont('bold.ttf', 26)
                        end
                        UiButtonImageBox("ui/common/box-outline-fill-6.png", 10,10)
                        if UiTextButton('Rain', btnW, btnH) then
                            SPEARS.mode = SPEARS.modes.rain
                        end
                    UiPop() end

                UiPop() end

                UiTranslate(-64, marginYSize)
                marginY = marginY + marginYSize
                UiTranslate(0, marginYSize)
                marginY = marginY + marginYSize

                -- Velocity
                ui.slider.create('Speed', 'spears.velocity', 'm/s', 1, SPEARS.velocityMax)
                UiTranslate(0, marginYSize)
                marginY = marginY + marginYSize

                -- Velocity Max
                ui.slider.create('Max Speed', 'spears.velocityMax', 'm/s', 0, 500)
                UiTranslate(0, marginYSize)
                marginY = marginY + marginYSize

                -- Force Multiplier
                ui.slider.create('Force Multiplier', 'spears.forceMultiplier', 'x', 0, SPEARS.forceMultiplierMax)
                UiTranslate(0, marginYSize)
                marginY = marginY + marginYSize

                -- Sharpness
                ui.slider.create('Sharpness', 'spears.sharpness', '%', 0, 100)
                UiTranslate(0, marginYSize)
                marginY = marginY + marginYSize

            UiPop() end

        UiPop() end

        do UiPush()

            UiTranslate(UiCenter()+300, 0)

            do UiPush()

                do UiPush()

                    UiTranslate(-250, 0)

                    ui.checkBox.create('Unbreakable Spears', 'spears.unbreakableSpears')
                    UiTranslate(0, marginYSize)
                    marginY = marginY + marginYSize

                    ui.checkBox.create('Colliding Spears', 'spears.collisions')
                    UiTranslate(0, marginYSize)
                    marginY = marginY + marginYSize

                    ui.checkBox.create('Spear Tip Light', 'spears.tipLight')
                    UiTranslate(0, marginYSize)
                    marginY = marginY + marginYSize

                    ui.checkBox.create('Yeet', 'spears.yeetMode')
                    UiTranslate(0, marginYSize)
                    marginY = marginY + marginYSize

                UiPop() end

            UiPop() end

        UiPop() end

        do UiPush()

            local resetW = 160
            local closeW = 80
            local wAlign = (resetW + closeW) / 2

            UiTranslate(UiCenter()-wAlign, cont_h - cont_marginY - 150)
            -- UiTranslate(UiCenter(), cont_h - cont_marginY - 150)

            UiAlign('center middle')
            UiImageBox("ui/common/box-outline-fill-6.png", closeW, 50, 10, 10)
            if UiTextButton('Close') then
                UI_OPTIONS = not UI_OPTIONS
            end

            UiTranslate(resetW/2 + closeW/2 + 10, 0)
            -- UiTranslate(0, -60)

            UiImageBox("ui/common/box-outline-fill-6.png", resetW, 50, 10, 10)
            if UiTextButton('Reset Spear') then
                modReset()
            end

        UiPop() end


    UiPop() end

end


--- Manage when to open and close the options menu.
function uiManageGameOptions()

    if UI_OPTIONS then
        UiMakeInteractive()
        uiDrawOptions()
    end

end


function drawSpearQuickOptions()
    if drawingSpearQuickOptions then

        UiMakeInteractive()

        UiColor(1,1,1, 1)
        UiFont('bold.ttf', 36)
        UiAlign('center middle')
        UiTranslate(0, -100)

        do UiPush()

            -- BG
            UiTranslate(UiCenter(), UiMiddle()-200)
            UiColor(0,0,0, 0.5)
            UiRect(400, 200)

            UiTranslate(-50, 0)

            UiColor(1,1,1, 1)
            UiAlign('right middle')
            UiImageBox('MOD/img/mouse_lmb.png', 100,100, 1,1)

            UiAlign('center top')
            UiTranslate(100, -40)
            UiText('Throw Mode:')
            UiTranslate(0, 48)
            UiText(SPEARS.mode)

        UiPop() end

        do

            UiTranslate(0, 50)

            -- BG
            do UiPush()
                UiTranslate(UiCenter(), UiMiddle()+100)
                UiColor(0,0,0, 0.5)
                UiRect(1000, 400)
            UiPop() end

            -- Spear velocity
            UiTranslate(-250, 0)
            do UiPush()

                local sliderWidth = 400
                local velocityFactor = SPEARS.velocityMax/gtZero(SPEARS.velocity)

                UiTranslate(UiCenter(), UiMiddle())
                UiText('Speed:')

                UiFont('bold.ttf', 48)
                UiTranslate(0, 48)
                UiText(sfn(SPEARS.velocity,0) .. ' m/s')

                UiAlign('left middle')
                UiTranslate(-sliderWidth/2, 48)

                UiColor(0,0,0, 1)
                do UiPush()
                    UiTranslate(-4,0)
                    UiRect(sliderWidth+8, 36)
                UiPop() end

                UiColor(1, 1 - 1/velocityFactor, 1 - 1/velocityFactor, 1)
                UiRect(sliderWidth / velocityFactor, 28)

                -- Mouse image
                do UiPush()

                    UiAlign('center middle')
                    UiColor(1,1,1, 1)
                    UiTranslate(sliderWidth/2, 96)
                    UiImageBox('MOD/img/mouse.png', 100,100, 1,1)

                    do UiPush()
                        UiTranslate(100, 0)
                        UiImageBox('MOD/img/arrow_right.png', 100,100, 1,1)
                    UiPop() end
                    do UiPush()
                        UiTranslate(-100, 0)
                        UiImageBox('MOD/img/arrow_left.png', 100,100, 1,1)
                    UiPop() end

                UiPop() end

            UiPop() end

            -- Spear force
            UiTranslate(500, 0)
            do UiPush()

                local sliderWidth = 400
                local forceFactor = SPEARS.forceMultiplierMax/gtZero(SPEARS.forceMultiplier)

                UiTranslate(UiCenter(), UiMiddle())
                UiText('Force Multiplier:')

                UiFont('bold.ttf', 48)
                UiTranslate(0, 48)
                UiText(sfn(SPEARS.forceMultiplier,1)*100 .. ' %')

                UiAlign('left middle')
                UiTranslate(-sliderWidth/2, 48)

                UiColor(0,0,0, 1)
                do UiPush()
                    UiTranslate(-4,0)
                    UiRect(sliderWidth+8, 36)
                UiPop() end

                UiColor(1, 1 - 1/forceFactor, 1 - 1/forceFactor, 1)
                UiRect(sliderWidth / forceFactor, 28)

                -- Mouse image
                do UiPush()
                    UiAlign('center middle')
                    UiColor(1,1,1, 1)
                    UiTranslate(sliderWidth/2, 96)
                    UiImageBox('MOD/img/mouse.png', 100,100, 1,1)

                    do UiPush()
                        UiTranslate(100, 0)
                        UiRotate(90)
                        UiImageBox('MOD/img/arrow_right.png', 100,100, 1,1)
                    UiPop() end
                    do UiPush()
                        UiTranslate(-100, 0)
                        UiRotate(90)
                        UiImageBox('MOD/img/arrow_left.png', 100,100, 1,1)
                    UiPop() end

                UiPop() end

            UiPop() end
        end



    end
end


function drawToolText()

    UiTranslate(UiCenter(), UiHeight())

    UiColor(1,1,1, 0.4)
    UiFont('bold.ttf', 24)
    UiAlign('center middle')

    UiTranslate(0, -56)
    UiTextShadow(0,0,0, 0.2, 2, 0)
    UiText('Press "o" to show all options.')

    UiTranslate(0, -30)
    UiText('Hold "right click" to show quick options.')

    UiFont('bold.ttf', 32)

    if not UI_OPTIONS then

        UiTranslate(0, -120)
        UiAlign('left middle')
        do UiPush()
            -- UiColor(1,1,1, 1)
            -- UiFont('bold.ttf', 48)
            UiText(sfn(SPEARS.forceMultiplier,1)*100 .. '%')
        UiPop() end
        UiAlign('right middle')
        UiText('Force:   ')

        UiTranslate(0, -40)
        UiAlign('left middle')
        do UiPush()
            -- UiColor(1,1,1, 1)
            -- UiFont('bold.ttf', 48)
            UiText(sfn(SPEARS.velocity,0) .. ' m/s')
        UiPop() end
        UiAlign('right middle')
        UiText('Speed:   ')

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

function ui.slider.create(title, registryPath, valueText, min, max, w, h, fontSize, dec)

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
            local decimals = ternary((value/slW) * (max-min) + min <= 100, 2, 0)
            UiText(sfn((value/slW) * (max-min) + min, dec or decimals) .. ' ' .. (valueText))
        UiPop() end

    UiPop() end

end



ui.checkBox = {}

function ui.checkBox.create(title, registryPath)

    UiTranslate(0, -font_normal*0.35)

    local value = GetBool('savegame.mod.' .. registryPath)

    -- Text header
    UiAlign('left top')
    UiColor(1,1,1, 1)
    UiFont('regular.ttf', font_normal)
    UiText(title)
    UiTranslate(0, font_normal * 1.2 )

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

    UiTranslate(0, font_normal*0.5)

end