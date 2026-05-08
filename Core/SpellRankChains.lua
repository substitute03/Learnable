local Addon = Learnable

-- Spell IDs per rank group, ordered low rank -> high rank (WotLK 3.3.x).
-- This is used so that the IsSpellKnown function only reports the highest rank learned.
local CHAINS = {
    -- Warrior
    { 78, 284, 285, 1608, 11564, 11565, 11566, 11567, 25286, 29707, 30324, 47449, 47450 },
    { 100, 6178, 11578 },
    { 772, 6546, 6547, 6548, 11572, 11573, 11574, 25208, 46845, 47465 },
    { 845, 7369, 11608, 11609, 20569, 25231, 47519, 47520 },
    { 1160, 6190, 11554, 11555, 11556, 25202, 25203, 47437 },
    { 1464, 8820, 11604, 11605, 25241, 25242, 47474, 47475 },
    { 6673, 5242, 6192, 11549, 11550, 11551, 25289, 2048, 47436 },
    { 5308, 20658, 20660, 20661, 20662, 25234, 25236, 47470, 47471 },
    { 6343, 8198, 8204, 8205, 11580, 11581, 25264, 47501, 47502 },
    { 6572, 6574, 7379, 11600, 11601, 25288, 25269, 30357, 57823 },
    { 12294, 21551, 21552, 21553, 25248, 30330, 47485, 47486 },
    { 20243, 30016, 30022, 47497, 47498 },
    { 23922, 23923, 23924, 23925, 25258, 30356, 47487, 47488 },
    -- Rogue
    { 53, 2589, 2590, 2591, 8721, 11279, 11280, 11281, 25300, 26863, 48656, 48657 },
    { 408, 8643 },
    { 703, 8631, 8632, 8633, 11289, 11290, 26839, 26884, 48675, 48676 },
    { 1752, 1757, 1758, 1759, 1760, 8621, 11293, 11294, 26861, 26862, 48637, 48638 },
    { 1856, 1857, 26889 },
    { 1943, 8639, 8640, 11273, 11274, 11275, 26867, 48671, 48672 },
    { 1966, 6768, 8637, 11303, 25302, 27448, 48658, 48659 },
    { 6770, 2070, 11297, 51724 },
    { 2098, 6760, 6761, 6762, 8623, 8624, 11299, 11300, 31016, 26865, 48667, 48668 },
    { 2983, 8696, 11305 },
    { 5171, 6774 },
    { 5277, 26669 },
    { 8676, 8724, 8725, 11267, 11268, 11269, 27441, 48689, 48690, 48691 },
    { 32645, 32684, 57992, 57993 },
    { 1329, 34411, 34412, 34413, 48663, 48666 },
}

local chainInfoBySpellId = {}

for c = 1, #CHAINS do
    local chain = CHAINS[c]
    for i = 1, #chain do
        chainInfoBySpellId[chain[i]] = {
            chain = chain,
            index = i,
        }
    end
end

function Addon.IsSpellEffectivelyKnown(spellId)
    if not spellId then
        return false
    end
    if IsSpellKnown and IsSpellKnown(spellId) then
        return true
    end
    local info = chainInfoBySpellId[spellId]
    if not info then
        return false
    end
    local chain = info.chain
    for j = info.index + 1, #chain do
        if IsSpellKnown and IsSpellKnown(chain[j]) then
            return true
        end
    end
    return false
end
