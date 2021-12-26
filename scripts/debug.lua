db = false
-- db = true

function db_func(func) if db then func() end end -- debug function call

function dbw(str, value) if db then DebugWatch(str, value) end end -- debug watch
function dbp(str, newLine) if db then DebugPrint(str .. ternary(newLine, '\n', '')) print(str .. ternary(newLine, '\n', '')) end end -- debug print

function dbl(p1, p2, c1, c2, c3, a) if db then DebugLine(p1, p2, c1, c2, c3, a) end end -- debug line
function dbdd(pos,w,l,r,g,b,a,dt) DrawDot(pos,w,l,r,g,b,a,dt) end -- debug draw dot
function dbray(tr, dist, c1, c2, c3, a) dbl(tr.pos, TransformToParentPoint(tr, Vec(0,0,-dist)), c1, c2, c3, a) end -- Debug ray from transform.
function dbcr(pos, r,g,b, a) if db then DebugCross(pos, r or 1, g or 1, b or 1, a or 1) end end -- debug cross