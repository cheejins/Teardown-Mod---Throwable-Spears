function initSpears()

    SetString("game.tool.pipebomb.name", "Throwable Spear") -- Rename pipebomb
    ActiveSpears = {} -- Table of spear objects.


    SPEARS = {} -- Base config for all spears.

    SPEARS.velocitySign = 1
    SPEARS.velocityCharge = regGetFloat('spears.velocity')

    SPEARS.modes = {straight = 'Straight', flat = 'Flat', rain = 'Rain'}
    SPEARS.mode = SPEARS.modes.straight

end

function processSpears()

    for key, spear in pairs(ActiveSpears) do

        -- local tr = GetShapeWorldTransform(spear.shape)
        local tr = GetBodyTransform(spear.body)

        -- Tip pos of the spear.
        local x,y,z = GetShapeSize(spear.shape)
        local tipPos = TransformToParentPoint(tr, Vec(0, 0, -y-1.7))
        spear.tipPos = tipPos

        if spear.impaling.impales < spear.impaling.impaleTicks then

            processSpearTip(spear, tipPos)

            if spear.impaling.impaled then
                spear.impaling.impales = spear.impaling.impales + 1 -- Increment number of ticks impaled so far.
            end

            applySpearSharpness(tr, x,y,z)

        end

        if SPEARS.tipLight then
            PointLight(tipPos, 1,1,1, 2)
        end

    end

end



function updateSpears()

    SPEARS.velocity = regGetFloat('spears.velocity')
    SPEARS.velocityMax = regGetFloat('spears.velocityMax')
    regSetFloat('spears.velocity', clamp(SPEARS.velocity, 0, SPEARS.velocityMax))

    SPEARS.forceMultiplier = regGetFloat('spears.forceMultiplier')
    SPEARS.forceMultiplierMax = regGetFloat('spears.forceMultiplierMax')

    SPEARS.sharpness = regGetFloat('spears.sharpness')/100
    -- SPEARS.sharpness = 1
    SPEARS.holeSize = 0.2 + (0.5*SPEARS.sharpness) -- (spear sharpness)
    SPEARS.holeDepth = 3 * SPEARS.sharpness -- (spear sharpness)

    SPEARS.extraThrowHeight = regGetFloat('spears.extraThrowHeight')


    SPEARS.unbreakableSpears = regGetBool('spears.unbreakableSpears')
    SPEARS.collisions = regGetBool('spears.collisions')
    SPEARS.rain = regGetBool('spears.rain')

    SPEARS.throwFlat = regGetBool('spears.throwFlat')
    SPEARS.hitMarker = regGetBool('spears.hitMarker')
    SPEARS.yeetMode = regGetBool('spears.yeetMode')
    SPEARS.tipLight = regGetBool('spears.tipLight')

end

function applySpearForce(spear, body)

    local spearVel = GetBodyVelocity(spear.body)

    local spearImpulse = VecScale(spearVel, GetBodyMass(spear.body)/GetBodyMass(body))
    local spearImpulse = VecScale(spearImpulse, SPEARS.forceMultiplier)

    -- ApplyBodyImpulse(body, spear.tipPos, spearImpulse)
    SetBodyVelocity(body, spearImpulse)

end

function applySpearSharpness(tr, x,y,z)

    local shapnessDepth = SPEARS.holeDepth
    local shapnessSize = SPEARS.holeSize

    for i = 1, shapnessDepth, shapnessSize  do
        local shapnessDepthIncrement = shapnessDepth - i
        local holePos = TransformToParentPoint(tr, Vec(0, 0, -y-1.9+shapnessDepthIncrement))
        MakeHole(holePos, shapnessSize, shapnessSize, shapnessSize, shapnessSize)
        dbcr(holePos, 1,1,1, 1)
    end

end

function processSpearTip(spear, tipPos)

    -- Spear tip aabb
    local aabbOffset = Vec(0.3, 0.3, 0.3)
    local tipMin = VecAdd(tipPos, aabbOffset)
    local tipMax = VecAdd(tipPos, VecScale(aabbOffset, -1))
    local aabbColor = Vec(1,1,1)

    -- Query bodies near spear tip.
    QueryRejectBody(spear.body)
    local hitBodies = QueryAabbBodies(tipMin, tipMax)

    local spearVelLow = VecLength(GetBodyVelocity(spear.body))  < 10
    if #hitBodies > 0 or spearVelLow then

        spear.impaling.impaled = true

        aabbColor = Vec(0,1,0)
        local hitGlobalBody = false

        -- Process spear impaling/force.
        for index, body in ipairs(hitBodies) do

            if body ~= GlobalBody then
                aabbColor = Vec(1,0,0)
                if db then
                    DrawBodyOutline(body, 1,0,0,1)
                end
                applySpearForce(spear, body) -- Impale bodies at the tip of the spear.
            else
                aabbColor = Vec(1,1,0)
                hitGlobalBody = true
            end

        end

        if hitGlobalBody then
            spear.impaling.impales = spear.impaling.impales + 1
        end

    end

    if db then
        AabbDraw(tipMin, tipMax, aabbColor[1], aabbColor[2], aabbColor[3]) -- Draw spear tip aabb.
    end

end



function setSpearSpawn(spearBody, tr, vel)
    SetBodyTransform(spearBody, tr)
    SetBodyVelocity(spearBody, VecScale(QuatToDir(QuatLookAt(tr.pos, TransformToParentPoint(tr, Vec(0,0,-1)))), SPEARS.velocity))
    SetBodyAngularVelocity(spearBody, Vec(0,0,0))
end

function convertPipebombs()

    pipebombs = FindShapes('bomb', true)

    local playerTr = GetPlayerTransform()

    for key, shape in pairs(pipebombs) do

        -- if GetShapeVoxelCount(shape) == 21 then
        if HasTag(shape, 'bomb') and HasTag(shape, 'smoke') then
            RemoveTag(shape,'bomb')
            RemoveTag(shape,'smoke')

            if SPEARS.unbreakableSpears then
                SetTag(shape, 'unbreakable')
            end

            -- Set spear spawn
            local body = GetShapeBody(shape)
            local bodyTrSpear = TransformCopy(GetCameraTransform())
            bodyTrSpear.pos = TransformToParentPoint(bodyTrSpear, Vec(0,0,-3))
            local hit, hitPos, hitShape = RaycastFromTransform(GetCameraTransform(), 500)

            if SPEARS.rain then

                if hit then
                    -- Top of hit shape
                    local min, max = GetShapeBounds(hitShape)
                    local maxY = min[2] + max[2]
                    local spawnPos = VecAdd(hitPos, Vec(0, maxY + SPEARS.velocity, 0))

                    local spawnRot = QuatLookDown(spawnPos)

                    bodyTrSpear = Transform(spawnPos, spawnRot)

                    PointLight(hitPos, 1,0,0, 2)
                    DrawDot(hitPos, 0.25,0.25, 1,0,0, 1)
                end

            end

            if SPEARS.throwFlat and hit then
                local throwPos = TransformToParentPoint(playerTr, Vec(0,0,-1))
                bodyTrSpear.pos = Vec(throwPos[1], hitPos[2], throwPos[3])
                bodyTrSpear.rot = QuatLookAt(bodyTrSpear.pos, hitPos)
            end

            setSpearSpawn(body, bodyTrSpear)

            -- Spear collisions
            if not SPEARS.collisions then
                SetShapeCollisionFilter(shape, 2, 255-2)
            end

            local spear = {

                body = body,
                shape = shape,

                impaling = {

                    impaled = false,
                    impales = 0,
                    -- impaleTicks = VecLength(GetBodyVelocity(body))/3, -- Impale for this many ticks after the tip hits an object.
                    impaleTicks = 15, -- Impale for this many ticks after the tip hits an object.

                    impaleBody = nil,
                    impaleAttachBody = nil,

                }
            }

            table.insert(ActiveSpears, spear)
        end

    end

end

function deleteSpears()
    for key, value in pairs(ActiveSpears) do
        Delete(value.body)
        ActiveSpears[key] = nil
    end
end

function processSpearMode()

    -- I know this is terrible. It works for now lol.

    if SPEARS.mode == SPEARS.modes.straight then

        regSetBool('spears.rain', false)
        regSetBool('spears.throwFlat', false)

    elseif SPEARS.mode == SPEARS.modes.flat then

        regSetBool('spears.rain', false)
        regSetBool('spears.throwFlat', true)

    elseif SPEARS.mode == SPEARS.modes.rain then

        regSetBool('spears.rain', true)
        regSetBool('spears.throwFlat', false)

    end

end

function processQuickOptionsMouseInput()

    local dy = InputValue('mousedy')
    local dx = InputValue('mousedx')

    if math.abs(math.floor(dy^3)) > math.abs(math.floor(dx^3)) then
        dx = 0
    else
        dy = 0
    end

    dy = -dy / 500 * SPEARS.forceMultiplierMax
    dx = dx / 500 * SPEARS.velocityMax

    dbw('dx', dx)
    dbw('dy', dy)

    regSetFloat('spears.velocity', clamp(SPEARS.velocity + dx, 0, SPEARS.velocityMax))
    regSetFloat('spears.forceMultiplier', clamp(SPEARS.forceMultiplier + dy, 0, SPEARS.forceMultiplierMax))

end



function processInput()

    local yeetMode = SPEARS.yeetMode and not (UI_OPTIONS or drawingSpearQuickOptions)
    if InputPressed('lmb') and isUsingTool and yeetMode then
        local pos = GetCameraTransform().pos
        sounds.play.yeet(pos)
    end

    --> Delete all spears.
    if InputPressed('r') and isUsingTool then
        deleteSpears()
        beep()
    end

    --> Delete/undo last spear created.
    if InputPressed('z') and isUsingTool then
        if #ActiveSpears >= 1 then
            Delete(ActiveSpears[#ActiveSpears].body)
            ActiveSpears[#ActiveSpears] = nil
        end
    end

    --> Toggle options UI.
    if InputPressed('o') and isUsingTool then
        UI_OPTIONS = not UI_OPTIONS
    end

    --> Quick options UI.
    if InputDown('rmb') and isUsingTool then

        drawingSpearQuickOptions = true

        processQuickOptionsMouseInput()

        if InputPressed('lmb') then
            incrementSpearMode()
        end

    else
        drawingSpearQuickOptions = false
    end

end

function incrementSpearMode()
    -- Convert SPEARS.modes to numeric keys.
    local spearModeIndex = nil
    local modes = {}
    for key, mode in pairs(SPEARS.modes) do
        table.insert(modes, mode)
    end

    for i, mode in ipairs(modes) do
        if SPEARS.mode == mode then
            spearModeIndex = i
            break
        end
    end

    if spearModeIndex + 1 > #modes then
        SPEARS.mode = modes[1]
    else
        SPEARS.mode = modes[spearModeIndex + 1]
    end

    dbw('spearModeIndex', spearModeIndex)
    dbw('SPEARS.mode', SPEARS.mode)
end

function debugMod()
    dbw('#ActiveSpears', #ActiveSpears)
end