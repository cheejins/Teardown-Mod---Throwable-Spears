function initSpears()

    SetString("game.tool.pipebomb.name", "Throwable Spear")
    ActiveSpears = {}
    SPEARS = {}

end


function updateSpears()

    SPEARS.velocity = regGetFloat('spears.velocity')
    SPEARS.impaling = regGetBool('spears.impaling')
    -- SPEARS.overheadThrow = regGetBool('spears.overheadThrow')

end


-- SPEAR
do

    function processSpears()

        for key, spear in pairs(ActiveSpears) do

            if SPEARS.impaling and spear.impaling.impales < spear.impaling.impaleTicks then

                -- local tr = GetShapeWorldTransform(spear.shape)
                local tr = GetBodyTransform(spear.body)

                -- Tip pos of the spear.
                local x,y,z = GetShapeSize(spear.shape)
                local tipPos = TransformToParentPoint(tr, Vec(0, 0, -y-1))
                spear.tipPos = tipPos

                -- Bodies near tip
                local aabbOffset = Vec(0.4, 0.4, 0.4)
                local tipMin = VecAdd(tipPos, aabbOffset)
                local tipMax = VecAdd(tipPos, VecScale(aabbOffset, -1))
                QueryRejectBody(spear.body)
                local hitBodies = QueryAabbBodies(tipMin, tipMax)

                local aabbColor = Vec(1,1,1)

                for index, body in ipairs(hitBodies) do

                    if body ~= GlobalBody then
                        aabbColor = Vec(1,0,0)
                        DrawBodyOutline(body, 1,0,0,1)
                        impaleSpear(spear, body) -- Impale bodies at the tip of the spear.
                    end

                end

                spear.impaling.impales = spear.impaling.impales + 1

                -- Impale (spear tip cuts through voxels easier)
                -- MakeHole(tipPos, (x+z)/2, (x+z)/2, (x+z)/2, (x+z)/2)
                MakeHole(tipPos, 0.4, 0.4, 0.4, 0.4)

                AabbDraw(tipMin, tipMax, aabbColor[1], aabbColor[2], aabbColor[3])
                dbcr(tipPos, 1,1,1, 1)
            end

        end

    end

    function convertPipebombs()

        pipebombs = FindShapes('bomb', true)

        for key, shape in pairs(pipebombs) do

            local body = GetShapeBody(shape)

            -- if GetShapeVoxelCount(shape) == 21 then
                RemoveTag(shape,'bomb')
                RemoveTag(shape,'smoke')
                SetTag(shape,'unbreakable')
            -- end

            local bodyTrSpear = TransformCopy(GetCameraTransform())
            bodyTrSpear.pos = TransformToParentPoint(bodyTrSpear, Vec(0,0,-3))
            setSpearSpawn(body, bodyTrSpear)

            local spear = {

                body = body,
                shape = shape,

                impaling = {

                    impales = 0,
                    impaleTicks = 10, -- Impale for this many ticks after the tip hits an object.

                    impaleBody = nil,
                    impaleAttachBody = nil,

                }
            }

            table.insert(ActiveSpears, spear)
        end

    end

    function impaleSpear(spear, body)

        local spearVel = GetBodyVelocity(spear.body)

        local spearImpulse = VecScale(spearVel, GetBodyMass(spear.body)/GetBodyMass(body))
        -- local spearImpulse = VecScale(spearVel, 0.5)

        -- ApplyBodyImpulse(body, spear.tipPos, spearImpulse)
        SetBodyVelocity(body, spearImpulse)

    end

    -- Process the hit of an impalement.
    function impaleSpearHit(spear)
    end

end



-- OTHER
do

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
            Delete(ActiveSpears[#ActiveSpears].body)
            ActiveSpears[#ActiveSpears] = nil
        end

        --> Toggle options UI.
        if InputPressed('rmb') and isUsingTool then
            UI_OPTIONS = not UI_OPTIONS
        end


    end

    function debugMod()
        dbw('#ActiveSpears', #ActiveSpears)
    end

end
