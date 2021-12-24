function initSpears()

    SetString("game.tool.pipebomb.name", "Throwable Spear")
    ActiveSpears = {}
    SPEARS = {}

end


function updateSpears()
    SPEARS.velocity = regGetFloat('spears.velocity')
    -- SPEARS.impaling = regGetBool('spears.impaling')
    SPEARS.impaling = true
end


-- SPEAR
do

    function processSpears()

        for key, spear in pairs(ActiveSpears) do

            if SPEARS.impaling then
                -- local tr = GetShapeWorldTransform(spear.shape)
                local tr = GetBodyTransform(spear.body)

                local x,y,z = GetShapeSize(spear.shape)
                local tipPos = TransformToParentPoint(tr, Vec(0, 0, -y-1.3))

                -- local totalVel = VecLength(GetBodyVelocity(spear.body))
                MakeHole(tipPos, 0.3, 0.3, 0.3, 0.3)
                -- DebugCross(tipPos, 1,1,1, 1)
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
            -- end

            local bodyTrSpear = TransformCopy(GetCameraTransform())
            bodyTrSpear.pos = TransformToParentPoint(bodyTrSpear, Vec(0,0,-3))
            setSpearSpawn(body, bodyTrSpear)

            local spear = {
                body = body,
                shape = shape
            }

            table.insert(ActiveSpears, spear)
        end

    end

    function setSpearSpawn(spearBody, tr, vel)
        SetBodyTransform(spearBody, tr)
        SetBodyVelocity(spearBody, VecScale(QuatToDir(QuatLookAt(tr.pos, TransformToParentPoint(tr, Vec(0,0,-1)))), SPEARS.velocity))
        SetBodyAngularVelocity(spearBody, Vec(0,0,0))
    end

    function impaleSpear(spear)
    end

    -- Process the hit of an impalement.
    function impaleSpearHit(spear)
    end

end



-- OTHER
do

    function deleteSpears()
        for key, value in pairs(ActiveSpears) do
            Delete(value.body)
        end
    end

    function processInput()

        if InputPressed('r') and GetString('game.player.tool') == 'pipebomb' then
            deleteSpears()
            beep()
         end

         if InputPressed('z') and GetString('game.player.tool') == 'pipebomb' then
             Delete(ActiveSpears[#ActiveSpears].body)
             ActiveSpears[#ActiveSpears] = nil
         end

    end

end
