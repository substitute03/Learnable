local Addon = Learnable

-- Spell IDs per rank group, ordered low rank -> high rank (WotLK 3.3.x).
-- When a higher rank is known, IsSpellKnown often returns false for superseded rank spell IDs;
-- these chains let IsSpellEffectivelyKnown treat lower ranks as known.
-- Each spell ID must appear in at most one chain (last write wins in chainInfoBySpellId).
local CHAINS = {
    -- Warrior
    { 78, 284, 285, 1608, 11564, 11565, 11566, 11567, 25286, 29707, 30324, 47449, 47450 }, -- Heroic Strike
    { 100, 6178, 11578 }, -- Charge
    { 772, 6546, 6547, 6548, 11572, 11573, 11574, 25208, 46845, 47465 }, -- Rend
    { 845, 7369, 11608, 11609, 20569, 25231, 47519, 47520 }, -- Cleave
    { 1160, 6190, 11554, 11555, 11556, 25202, 25203, 47437 }, -- Demoralizing Shout
    { 1464, 8820, 11604, 11605, 25241, 25242, 47474, 47475 }, -- Slam
    { 6673, 5242, 6192, 11549, 11550, 11551, 25289, 2048, 47436 }, -- Battle Shout
    { 5308, 20658, 20660, 20661, 20662, 25234, 25236, 47470, 47471 }, -- Execute
    { 6343, 8198, 8204, 8205, 11580, 11581, 25264, 47501, 47502 }, -- Thunder Clap
    { 6572, 6574, 7379, 11600, 11601, 25288, 25269, 57823 }, -- Shield Block
    { 12294, 21551, 21552, 21553, 25248, 30330, 47485, 47486 }, -- Mortal Strike
    { 20243, 30016, 30022, 47497, 47498 }, -- Devastate
    { 23922, 23923, 23924, 23925, 25258, 30356, 30357, 47487, 47488 }, -- Shield Slam
    -- Rogue
    { 53, 2589, 2590, 2591, 8721, 11279, 11280, 11281, 25300, 26863, 48656, 48657 }, -- Sinister Strike
    { 408, 8643 }, -- Kidney Shot
    { 703, 8631, 8632, 8633, 11289, 11290, 26839, 26884, 48675, 48676 }, -- Garrote
    { 1752, 1757, 1758, 1759, 1760, 8621, 11293, 11294, 26861, 26862, 48637, 48638 }, -- Backstab
    { 1856, 1857, 26889 }, -- Vanish
    { 1943, 8639, 8640, 11273, 11274, 11275, 26867, 48671, 48672 }, -- Rupture
    { 1966, 6768, 8637, 11303, 25302, 27448, 48658, 48659 }, -- Feint
    { 6770, 2070, 11297, 51724 }, -- Sap
    { 2098, 6760, 6761, 6762, 8623, 8624, 11299, 11300, 31016, 26865, 48667, 48668 }, -- Eviscerate
    { 2983, 8696, 11305 }, -- Sprint
    { 5171, 6774 }, -- Slice and Dice
    { 5277, 26669 }, -- Evasion
    { 8676, 8724, 8725, 11267, 11268, 11269, 27441, 48689, 48690, 48691 }, -- Ambush
    { 32645, 32684, 57992, 57993 }, -- Deadly Throw
    { 1329, 34411, 34412, 34413, 48663, 48666 }, -- Mutilate
    -- Druid
    { 99, 1735, 9490, 9747, 9898, 26998, 48559, 48560 }, -- Demoralizing Roar
    { 8921, 8924, 8925, 8926, 8928, 8929, 9833, 9834, 26984, 27012, 48463, 48470 }, -- Moonfire
    { 339, 1062, 5195, 5196, 9852, 9853, 26987, 53308 }, -- Entangling Roots
    { 5177, 5178, 5179, 5180, 8918, 8949, 8950, 8951, 9892, 9910, 9912, 48461, 53307 }, -- Wrath
    { 5186, 5187, 5188, 5189, 6778, 9888, 9889, 25297, 26978, 48440, 48378 }, -- Healing Touch
    { 8936, 8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858, 48450, 48442, 48443, 48562 }, -- Regrowth
    { 774, 1058, 1430, 2090, 3627, 8910, 9839, 9840, 9841, 26981, 48462, 48446, 48571 }, -- Rejuvenation
    { 2912, 8927, 25298, 48465, 48469 }, -- Starfire
    { 1126, 5232, 6756, 8907, 9884, 9885, 26990, 49800 }, -- Mark of the Wild
    { 467, 782, 1075, 8914, 8905, 48467 }, -- Thorns
    { 21849, 21850, 49803 }, -- Gift of the Wild
    { 20484, 20739, 20742, 20747, 20748, 48477 }, -- Rebirth
    { 17401, 17402, 53312 }, -- Hurricane
    { 9862, 9863 }, -- Tranquility
    { 33763, 33357, 48441 }, -- Lifebloom
    { 1082, 3029, 5201, 9849, 9850, 27000, 48569, 48570 }, -- Claw
    { 1822, 1823, 1824, 27003, 27004, 48574, 48577 }, -- Rake
    { 1079, 9492, 9493, 9752, 9894, 9896, 27008, 48572 }, -- Rip
    { 5221, 6800, 8992, 9829, 9830 }, -- Shred
    { 22568, 22827, 22829, 22896, 31018, 48451, 48447 }, -- Ferocious Bite
    { 9005, 9823, 9827, 9835, 27006, 27005 }, -- Pounce
    { 6807, 6808, 6809, 8972, 8992, 9880, 9881, 48568 }, -- Maul
    { 779, 780, 769, 9754, 9901, 48575 }, -- Swipe (Bear)
    { 5211, 6798, 8983 }, -- Bash
    { 2637, 18657, 18658 }, -- Hibernate
    { 770, 778 }, -- Faerie Fire (Feral)
    { 5217, 6793, 9845, 9846 }, -- Tiger's Fury
    { 5215, 9913 }, -- Prowl
    { 6785, 6787 }, -- Ravage
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
