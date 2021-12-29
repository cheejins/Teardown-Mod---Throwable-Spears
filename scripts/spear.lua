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

        processSpearTip(spear, tipPos)
        applySpearSharpness(spear, x,y,z)
        applySpearPenetration(spear)

    end

end



function updateSpears()

    SPEARS.velocity = regGetFloat('spears.velocity')
    SPEARS.velocityMax = regGetFloat('spears.velocityMax')
    regSetFloat('spears.velocity', clamp(SPEARS.velocity, 0, SPEARS.velocityMax))

    SPEARS.forceMultiplier = regGetFloat('spears.forceMultiplier')
    SPEARS.forceMultiplierMax = regGetFloat('spears.forceMultiplierMax')

    SPEARS.stiffness = regGetFloat('spears.stiffness')
    SPEARS.sharpness = regGetFloat('spears.sharpness')/100

    SPEARS.extraThrowHeight = regGetFloat('spears.extraThrowHeight')


    SPEARS.unbreakableSpears = regGetBool('spears.unbreakableSpears')
    SPEARS.collisions = regGetBool('spears.collisions')
    SPEARS.rain = regGetBool('spears.rain')

    SPEARS.throwFlat = regGetBool('spears.throwFlat')
    SPEARS.hitMarker = regGetBool('spears.hitMarker')
    SPEARS.yeetMode = regGetBool('spears.yeetMode')
    SPEARS.hitIndicator = regGetBool('spears.hitIndicator')

end

function applySpearForce(spear, body)

    local spearVel = GetBodyVelocity(spear.body)

    local spearImpulse = VecScale(spearVel, GetBodyMass(spear.body)/GetBodyMass(body))
    local spearImpulse = VecScale(spearImpulse, SPEARS.forceMultiplier)

    -- ApplyBodyImpulse(body, spear.tipPos, spearImpulse)
    SetBodyVelocity(body, spearImpulse)

end

function applySpearSharpness(spear, x,y,z)

    local spearTr = GetShapeWorldTransform(spear.shape)

    local forwardVel = TransformToLocalVec(spearTr, GetBodyVelocity(spear.body))[3] * -1
    forwardVel = clamp(forwardVel, 0, math.huge) * SPEARS.sharpness
    forwardVel = forwardVel / 2 -- scale
    dbw('forwardVel', forwardVel)

    local addTipFowardPos = clamp(forwardVel / 10, 0, 2)
    spearTr.pos = TransformToParentPoint(spearTr, Vec(x/20, y/20, -addTipFowardPos)) -- Center of spear.

    local shapnessDepth = clamp(forwardVel * SPEARS.sharpness, 0.3, 2)
    -- local shapnessDepth = 1
    local holeSize = 0.3

    for i = 1, shapnessDepth, 0.1  do
        local shapnessDepthIncrement = shapnessDepth - i
        local holePos = TransformToParentPoint(spearTr, Vec(0, 0, shapnessDepthIncrement))
        MakeHole(holePos, holeSize, holeSize, holeSize, holeSize)
        dbcr(holePos, 1,1,1, 1)
    end

end

function applySpearPenetration(spear)

    local p = (100 - SPEARS.stiffness) / 100
    local angVel = GetBodyAngularVelocity(spear.body)
    local spearAngVelNew = VecMult(angVel, Vec(p,p,p)) -- Scale angular velocity.

    SetBodyAngularVelocity(spear.body, spearAngVelNew)

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
                if SPEARS.hitIndicator then
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

    if SPEARS.hitIndicator then
        AabbDraw(tipMin, tipMax, aabbColor[1], aabbColor[2], aabbColor[3]) -- Draw spear tip aabb.
    end

end



function setSpearSpawn(spearBody, tr, vel)
    SetBodyTransform(spearBody, tr)
    SetBodyVelocity(spearBody, VecScale(QuatToDir(QuatLookAt(tr.pos, TransformToParentPoint(tr, Vec(0,0,-1)))), SPEARS.velocity))
    SetBodyAngularVelocity(spearBody, Vec(0,0,0))
end

function setSpearDimensions(spear)

    local spearTr = GetShapeWorldTransform(spear.shape)

    if spear.dimensions == nil then

        local sx, sy, sz = GetShapeSize(spear.shape)
        spear.dimensions = {sx, sy, sz}

        dbp('set spear dim')
    end


    if spear.sh == nil then

        spear.sh = 1

    end

    -- if spear.sh < 10 then

        local x, y, z = spear.dimensions[1], spear.dimensions[2], spear.dimensions[3]

        dbp('spear.sh ' .. spear.sh)


        for i = 0, z, 0.05 do
            MakeHole(TransformToParentPoint(spearTr, Vec(0,0,i)), 0.05, 0.05, 0.05, 0.05)
        end
        dbl(spearTr.pos, TransformToParentPoint(spearTr, Vec(0, 0, z/10)), 1,1,1, 1)


        local spearTrOffset = TransformCopy(spearTr)
        spearTrOffset.pos = VecAdd(spearTrOffset.pos, Vec(x/10,0,0))
        for i = 0, z, 0.05 do
            MakeHole(TransformToParentPoint(spearTrOffset, Vec(0,0,i)), 0.05, 0.05, 0.05, 0.05)
        end
        dbl(spearTrOffset.pos, TransformToParentPoint(spearTrOffset, Vec(0, 0, z/10)), 1,1,1, 1)


        local spearTrOffset = TransformCopy(spearTr)
        spearTrOffset.pos = VecAdd(spearTrOffset.pos, Vec(x/10,y/10,0))
        for i = 0, z, 0.05 do
            MakeHole(TransformToParentPoint(spearTrOffset, Vec(0,0,i)), 0.05, 0.05, 0.05, 0.05)
        end
        dbl(spearTrOffset.pos, TransformToParentPoint(spearTrOffset, Vec(0, 0, z/10)), 1,1,1, 1)


        local spearTrOffset = TransformCopy(spearTr)
        spearTrOffset.pos = VecAdd(spearTrOffset.pos, Vec(0,y/10,0))
        for i = 0, z, 0.05 do
            MakeHole(TransformToParentPoint(spearTrOffset, Vec(0,0,i)), 0.05, 0.05, 0.05, 0.05)
        end
        dbl(spearTrOffset.pos, TransformToParentPoint(spearTrOffset, Vec(0, 0, z/10)), 1,1,1, 1)


        -- spear.sh = spear.sh + 1
    -- end

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

            -- setSpearDimensions(spear)

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
