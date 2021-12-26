function initSpears()

    SetString("game.tool.pipebomb.name", "Throwable Spear") -- Rename pipebomb
    ActiveSpears = {} -- Table of spear objects.

    SPEARS = {} -- Base config for all spears.
    SPEARS.velocitySign = 1
    SPEARS.velocityCharge = regGetFloat('spears.velocity')

end


function updateSpears()

    SPEARS.velocityMax = regGetFloat('spears.velocityMax')

    SPEARS.velocity = regGetFloat('spears.velocity')
    regSetFloat('spears.velocity', clamp(SPEARS.velocity, 0, SPEARS.velocityMax))

    SPEARS.impaling = true

    SPEARS.holeSize = 0.3 -- (spear sharpness)
    SPEARS.holeDepth = 2 -- (spear sharpness)

    SPEARS.forceMultiplier = regGetFloat('spears.forceMultiplier')
    SPEARS.forceMultiplierMax = regGetFloat('spears.forceMultiplierMax')

    SPEARS.unbreakable = true
    -- SPEARS.overheadThrow = regGetBool('spears.overheadThrow')

end


-- SPEAR
do

    function processSpears()

        for key, spear in pairs(ActiveSpears) do

            -- local tr = GetShapeWorldTransform(spear.shape)
            local tr = GetBodyTransform(spear.body)

            -- Tip pos of the spear.
            local x,y,z = GetShapeSize(spear.shape)
            local tipPos = TransformToParentPoint(tr, Vec(0, 0, -y-1))
            spear.tipPos = tipPos

            if spear.impaling.impales < spear.impaling.impaleTicks then

                processSpearForce(spear, tipPos)
                processSpearSharpness(tr, x,y,z)

            end

        end

    end

    function convertPipebombs()

        pipebombs = FindShapes('bomb', true)

        for key, shape in pairs(pipebombs) do

            -- if GetShapeVoxelCount(shape) == 21 then
                RemoveTag(shape,'bomb')
                RemoveTag(shape,'smoke')

                ternary(SPEARS.unbreakable, SetTag(shape,'unbreakable'))

            -- end

            local body = GetShapeBody(shape)
            local bodyTrSpear = TransformCopy(GetCameraTransform())
            bodyTrSpear.pos = TransformToParentPoint(bodyTrSpear, Vec(0,0,-3))
            setSpearSpawn(body, bodyTrSpear)


            local spear = {

                body = body,
                shape = shape,

                impaling = {

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

    function applySpearForce(spear, body)

        local spearVel = GetBodyVelocity(spear.body)

        local spearImpulse = VecScale(spearVel, GetBodyMass(spear.body)/GetBodyMass(body))
        local spearImpulse = VecScale(spearImpulse, SPEARS.forceMultiplier)

        -- ApplyBodyImpulse(body, spear.tipPos, spearImpulse)
        SetBodyVelocity(body, spearImpulse)

    end

    function processSpearSharpness(tr, x,y,z)

        local shapnessDepth = SPEARS.holeDepth
        local shapnessSize = SPEARS.holeSize

        for i = 1, shapnessDepth, shapnessSize  do
            local shapnessDepthIncrement = shapnessDepth - i
            local holePos = TransformToParentPoint(tr, Vec(0, 0, -y-1.3+shapnessDepthIncrement))
            MakeHole(holePos, 0.4, 0.4, 0.4, 0.4)
            dbcr(holePos, 1,1,1, 1)
        end

    end

    function processSpearForce(spear, tipPos)

        -- Spear tip aabb
        local aabbOffset = Vec(SPEARS.holeSize, SPEARS.holeSize, SPEARS.holeSize)
        local tipMin = VecAdd(tipPos, aabbOffset)
        local tipMax = VecAdd(tipPos, VecScale(aabbOffset, -1))
        local aabbColor = Vec(1,1,1)

        -- Query bodies near spear tip.
        QueryRejectBody(spear.body)
        local hitBodies = QueryAabbBodies(tipMin, tipMax)

        -- Process spear impaling/force.
        for index, body in ipairs(hitBodies) do

            if body ~= GlobalBody then
                aabbColor = Vec(1,0,0)
                DrawBodyOutline(body, 1,0,0,1)
                applySpearForce(spear, body) -- Impale bodies at the tip of the spear.
            end

        end

        spear.impaling.impales = spear.impaling.impales + 1 -- Increment number of ticks impaled so far.

        AabbDraw(tipMin, tipMax, aabbColor[1], aabbColor[2], aabbColor[3]) -- Draw spear tip aabb.

    end

end



-- OTHER
do

    function processVelocityCharging()

        local velCharge = regGetFloat('spears.velocity')
        local max = SPEARS.velocityMax
        local increment = 500/SPEARS.velocityMax

        if velCharge <= 0 then
            velCharge = increment*2
            SPEARS.velocitySign = 1
        elseif velCharge >= max then
            velCharge = max - (increment*2)
            SPEARS.velocitySign = -1
        end

        regSetFloat('spears.velocity', velCharge + (SPEARS.velocitySign * increment))

        dbw('SPEARS.velocitySign', SPEARS.velocitySign)
        dbw('spears.velocity', velCharge)

    end

    function setSpearSpawn(spearBody, tr, vel)
        SetBodyTransform(spearBody, tr)
        SetBodyVelocity(spearBody, VecScale(QuatToDir(QuatLookAt(tr.pos, TransformToParentPoint(tr, Vec(0,0,-1)))), SPEARS.velocity))
        SetBodyAngularVelocity(spearBody, Vec(0,0,0))
    end

    function deleteSpears()
        for key, value in pairs(ActiveSpears) do
            Delete(value.body)
            ActiveSpears[key] = nil
        end
    end

    function processInput()

        local isUsingTool = GetString('game.player.tool') == 'pipebomb'

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

        --> Toggle options UI.
        if InputDown('rmb') and isUsingTool then

            drawingSpearForce = true

            local dx = InputValue('mousedx')/5
            regSetFloat('spears.velocity', clamp(SPEARS.velocity + dx, 0, SPEARS.velocityMax))

            local dy = InputValue('mousedy')/10
            regSetFloat('spears.forceMultiplier', clamp(SPEARS.forceMultiplier + dy, 0, SPEARS.forceMultiplierMax))

        else
            drawingSpearForce = false
        end

    end

    function debugMod()
        dbw('#ActiveSpears', #ActiveSpears)
    end

end
