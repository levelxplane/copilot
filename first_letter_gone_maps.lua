sets = require('sets')
tables = require('tables')
local mb_dark = {"stone", "water", "blizzard"}
local mb_light = {"fire", "aero", "thunder"}
local mb_aspir = {"aspir"}

SUPER_MAP = T{
    mb_ws = T{
        ["atastrophe"] = mb_dark,
        ["orcleaver"] = mb_light,
        ["avage"] = mb_dark,
    },
    spell_flag_map = T{
        -- nukes
        ["ire"] = {name="Fire", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["ero"] = {name="Aero", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["hunder"] = {name="Thunder", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["anish"] = {name="Banish", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["lizzard"] = {name="Blizzard", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["liz"] = {name="Blizzard", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["ater"] = {name="Water", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["tone"] = {name="Stone", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["ira"] = {name="Fira", geo_spell=false, offensive=true, tiers={" II", ""}},
        ["era"] = {name="Aera", geo_spell=false, offensive=true, tiers={" II", ""}},
        ["hundara"] = {name="Thundara", geo_spell=false, offensive=true, tiers={" II", ""}},
        ["lizzara"] = {name="Blizzara", geo_spell=false, offensive=true, tiers={" II", ""}},
        ["atera"] = {name="Watera", geo_spell=false, offensive=true, tiers={" II", ""}},
        ["tonera"] = {name="Stonera", geo_spell=false, offensive=true, tiers={" II", ""}},
        ["spir"] = {name="Aspir", geo_spell=false, offensive=true, tiers={" III", " II", ""}},
        ["rain"] = {name="Drain", geo_spell=false, offensive=true, tiers={" III", " II", ""}},

        -- na spells
        ["ara"] = {name="Paralyna", geo_spell=false, offensive=false, whm_only=true},
        ["aralyna"] = {name="Paralyna", geo_spell=false, offensive=false, whm_only=true},
        ["tona"] = {name="Stona", geo_spell=false, offensive=false, whm_only=true},
        ["etri"] = {name="Stona", geo_spell=false, offensive=false, whm_only=true},
        ["ilence"] = {name="Silena", geo_spell=false, offensive=false, whm_only=true},
        ["ilena"] = {name="Silena", geo_spell=false, offensive=false, whm_only=true},
        ["oison"] = {name="Poisona", geo_spell=false, offensive=false, whm_only=true},
        ["oisona"] = {name="Poisona", geo_spell=false, offensive=false, whm_only=true},
        ["lind"] = {name="Blindna", geo_spell=false, offensive=false, whm_only=true},
        ["lindna"] = {name="Blindna", geo_spell=false, offensive=false, whm_only=true},
        ["irus"] = {name="Viruna", geo_spell=false, offensive=false, whm_only=true},
        ["iruna"] = {name="Viruna", geo_spell=false, offensive=false, whm_only=true},
        ["leep"] = {name="Cure", geo_spell=false, offensive=false},
        ["zz"] = {name="Cure", geo_spell=false, offensive=false},
        ["urse"] = {name="Cursna", geo_spell=false, offensive=false, whm_only=true},
        ["ursna"] = {name="Cursna", geo_spell=false, offensive=false, whm_only=true},
        ["rase"] = {name="Erase", geo_spell=false, offensive=false, whm_only=true},

        -- heals/buffs
        ["rotect"] = {name="Protectra", geo_spell=false, offensive=false, tiers={" III", " II", ""}},
        ["hell"] = {name="Shellra", geo_spell=false, offensive=false, tiers={" III", " II", ""}},
        ["toneskin"] = {name="Stoneskin", geo_spell=false, offensive=false},
        ["s"] = {name="Stoneskin", geo_spell=false, offensive=false},
        ["efresh"] = {name="Refresh", geo_spell=false, offensive=false, tiers={" II", ""}},
        ["aste"] = {name="Haste", geo_spell=false, offensive=false, tiers={" II", ""}},
        ["ure"] = {name="Cure", geo_spell=false, offensive=false, tiers={" V", " IV", " III", " II", ""}},
        ["uraga"] = {name="Curaga", geo_spell=false, offensive=false, tiers={" III", " II", ""}},
        ["aise"] = {name="Raise", geo_spell=false, offensive=false, tiers={" III", " II", ""}},
        ["hst"] = {name="Indi-Haste", geo_spell=true, offensive=false},--ihst
        ["efr"] = {name="Geo-Refresh", geo_spell=true, offensive=false},--refr
    },
            -- geo stuff
            -- cmd lp
    geo = T{
        ["slow"] = {name="Geo-Slow", geo_spell=true, offensive=true},
        ["eva-"] = {name="Geo-Torpor", geo_spell=true, offensive=true},
        ["acc-"] = {name="Geo-Slip", geo_spell=true, offensive=true},
        ["meva"] = {name="Geo-Languor", geo_spell=true, offensive=true},
        ["para"] = {name="Geo-Paralysis", geo_spell=true, offensive=true},
        ["macc-"] = {name="Geo-Vex", geo_spell=true, offensive=true},
        ["def-"] = {name="Geo-Frailty", geo_spell=true, offensive=true},
        ["atk-"] = {name="Geo-Wilt", geo_spell=true, offensive=true},
        ["grav"] = {name="Geo-Gravity", geo_spell=true, offensive=true},
        ["mdef-"] = {name="Geo-Malaise", geo_spell=true, offensive=true},
        ["matk-"] = {name="Geo-Fade", geo_spell=true, offensive=true},

        ["regen"] = {name="Geo-Regen", geo_spell=true, offensive=false},
        ["refresh"] = {name="Geo-Refresh", geo_spell=true, offensive=false},
        ["haste"] = {name="Geo-Haste", geo_spell=true, offensive=false},
        ["eva"] = {name="Geo-Voidance", geo_spell=true, offensive=false},
        ["acc"] = {name="Geo-Precision", geo_spell=true, offensive=false},
        ["meva"] = {name="Geo-Attunement", geo_spell=true, offensive=false},
        ["macc"] = {name="Geo-Focus", geo_spell=true, offensive=false},
        ["def"] = {name="Geo-Barrier", geo_spell=true, offensive=false},
        ["atk"] = {name="Geo-Fury", geo_spell=true, offensive=false},
        ["mdef"] = {name="Geo-Fend", geo_spell=true, offensive=false},
        ["matk"] = {name="Geo-Acumen", geo_spell=true, offensive=false},
    },
    -- cmd ind or ent --
    -- indi debuffs -- treat like non-offensive spells
    ind = T{
        ["poison"] = {name="Indi-Poison", geo_spell=true, offensive=false},
        ["slow"] = {name="Indi-Slow", geo_spell=true, offensive=false},
        ["eva-"] = {name="Indi-Torpor", geo_spell=true, offensive=false},
        ["acc-"] = {name="Indi-Slip", geo_spell=true, offensive=false},
        ["meva-"] = {name="Indi-Languor", geo_spell=true, offensive=false},
        ["para"] = {name="Indi-Paralysis", geo_spell=true, offensive=false},
        ["macc-"] = {name="Indi-Vex", geo_spell=true, offensive=false},
        ["def-"] = {name="Indi-Frailty", geo_spell=true, offensive=false},
        ["atk-"] = {name="Indi-Wilt", geo_spell=true, offensive=false},
        ["grav"] = {name="Indi-Gravity", geo_spell=true, offensive=false},
        ["mdef-"] = {name="Indi-Malaise", geo_spell=true, offensive=false},
        ["matk-"] = {name="Indi-Fade", geo_spell=true, offensive=false},

        -- indi buffs
        ["regen"] = {name="Indi-Regen", geo_spell=true, offensive=false},
        ["refresh"] = {name="Indi-Refresh", geo_spell=true, offensive=false},
        ["haste"] = {name="Indi-Haste", geo_spell=true, offensive=false},
        ["eva"] = {name="Indi-Voidance", geo_spell=true, offensive=false},
        ["acc"] = {name="Indi-Precision", geo_spell=true, offensive=false},
        ["meva"] = {name="Indi-Attunement", geo_spell=true, offensive=false},
        ["macc"] = {name="Indi-Focus", geo_spell=true, offensive=false},
        ["def"] = {name="Indi-Barrier", geo_spell=true, offensive=false},
        ["atk"] = {name="Indi-Fury", geo_spell=true, offensive=false},
        ["mdef"] = {name="Indi-Fend", geo_spell=true, offensive=false},
        ["matk"] = {name="Indi-Acumen", geo_spell=true, offensive=false},
    },
    smn = T{
        ["aruda"] = {name="Garuda", geo_spell=false, offensive=false},
        ["itan"] = {name="Titan", geo_spell=false, offensive=false},
        ["enrir"] = {name="Fenrir", geo_spell=false, offensive=false},
        ["amuh"] = {name="Ramuh", geo_spell=false, offensive=false},
        ["evi"] = {name="Leviathan", geo_spell=false, offensive=false},
    },
    leader_flag_map = T{
        -- custom spells. need to assign functions somehow.
        ["neak"] = {leader_only=true},

        -- ffo and other commands
        ["ollow"] = {leader_only=true},
        ["top"] = {leader_only=true},
        ["o"] = {leader_only=true},
        ["immer"] = {leader_only=true},
        ["ome"] = {leader_only=true},
        ["ount"] = {leader_only=true},
        ["ismount"] = {leader_only=true},

        -- geo stuff
        ["nd"] = {leader_only=true},
        ["nt"] = {leader_only=true},

        ["p"] = {leader_only=true},
        ["pp"] = {leader_only=true},
        ["c"] = {leader_only=true},
        ["a"] = {leader_only=true},

        -- smn stuff
        ["mn"] = {leader_only=true},
        ["ic"] = {leader_only=true},
        ["elease"] = {leader_only=true},
        ["astega"] = {leader_only=true},

        -- pew pew
        -- figure this shit out
        ["mb"] = {leader_only=true}, -- magicburst mode
        ["tm"] = {leader_only=true}, -- tell mode
        ["ag"] = {leader_only=true}, -- auto geo/indi spell
    },
}

return SUPER_MAP
