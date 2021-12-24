#include "scripts/spears.lua"
#include "scripts/registry.lua"
#include "scripts/utility.lua"

function init()

    checkRegInitialized()

    ActiveSpearBodies = {}
    initSpears()

end

function tick()
    convertPipebombs()
    processSpears()
end
