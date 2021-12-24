function initSpears()
    SPEARS = {}
end

function processSpears()

    SPEARS.velocity = regGetFloat('spear.velocity')

end

function convertPipebombs()

    pipebombs = FindShapes('bomb', true)

    for key, shape in pairs(pipebombs) do

        local body = GetShapeBody(shape)
        local bodyTr = GetBodyTransform(shape)

        -- if GetShapeVoxelCount(shape) == 21 then
            RemoveTag(shape,'bomb')
            RemoveTag(shape,'smoke')
            SetTag(body,'spear')
        -- end

        local bodyTrSpear = TransformCopy(GetCameraTransform())
        bodyTrSpear.pos = TransformToParentPoint(bodyTrSpear, Vec(0,0,-2))
        setSpearSpawn(body, bodyTrSpear)

        table.insert(ActiveSpearBodies, body)
    end

end

function setSpearSpawn(spearBody, tr, vel)

    SetBodyTransform(spearBody, tr)
    SetBodyVelocity(spearBody, VecScale(QuatToDir(QuatLookAt(tr.pos, TransformToParentPoint(tr, Vec(0,0,-1)))), SPEARS.velocity))
    SetBodyAngularVelocity(spearBody, Vec(0,0,0))

end
