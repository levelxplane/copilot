sets = require('sets')
tables = require('tables')
local mb_dark = {
    "rocks",
    "water",
    "blizzard"
}
local mb_light = {
    "fire",
    "aero",
    "thunder"
}
local mb_aspir = {"aspir"}

SUPER_MAP = T{
    mb_ws = T{
        ["catastrophe"] = mb_dark,
        ["torcleaver"] = mb_light,
        ["savage"] = mb_dark, -- savage blade
    },
    spell_flag_map = T{
        -- nukes
        ["fire"] = {name="Fire", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["aero"] = {name="Aero", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["thunder"] = {name="Thunder", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["banish"] = {name="Banish", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["blizzard"] = {name="Blizzard", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["bliz"] = {name="Blizzard", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["water"] = {name="Water", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["stone"] = {name="Stone", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["rocks"] = {name="Stone", geo_spell=false, offensive=true, tiers={" V", " IV", " III", " II", ""}},
        ["fira"] = {name="Fira", geo_spell=false, offensive=true, tiers={" II", ""}},
        ["aera"] = {name="Aera", geo_spell=false, offensive=true, tiers={" II", ""}},
        ["thundara"] = {name="Thundara", geo_spell=false, offensive=true, tiers={" II", ""}},
        ["blizzara"] = {name="Blizzara", geo_spell=false, offensive=true, tiers={" II", ""}},
        ["watera"] = {name="Watera", geo_spell=false, offensive=true, tiers={" II", ""}},
        ["stonera"] = {name="Stonera", geo_spell=false, offensive=true, tiers={" II", ""}},
        ["aspir"] = {name="Aspir", geo_spell=false, offensive=true, tiers={" III", " II", ""}},
        ["drain"] = {name="Drain", geo_spell=false, offensive=true, tiers={" III", " II", ""}},

        -- na spells
        ["para"] = {name="Paralyna", geo_spell=false, offensive=false, whm_only=true},
        ["paralysis"] = {name="Paralyna", geo_spell=false, offensive=false, whm_only=true},
        ["paralyna"] = {name="Paralyna", geo_spell=false, offensive=false, whm_only=true},
        ["stona"] = {name="Stona", geo_spell=false, offensive=false, whm_only=true},
        ["petri"] = {name="Stona", geo_spell=false, offensive=false, whm_only=true},
        ["petrified"] = {name="Stona", geo_spell=false, offensive=false, whm_only=true},
        ["petrification"] = {name="Stona", geo_spell=false, offensive=false, whm_only=true},
        ["silence"] = {name="Silena", geo_spell=false, offensive=false, whm_only=true},
        ["silena"] = {name="Silena", geo_spell=false, offensive=false, whm_only=true},
        ["poison"] = {name="Poisona", geo_spell=false, offensive=false, whm_only=true},
        ["poisona"] = {name="Poisona", geo_spell=false, offensive=false, whm_only=true},
        ["blind"] = {name="Blindna", geo_spell=false, offensive=false, whm_only=true},
        ["blindness"] = {name="Blindna", geo_spell=false, offensive=false, whm_only=true},
        ["blindna"] = {name="Blindna", geo_spell=false, offensive=false, whm_only=true},
        ["disease"] = {name="Viruna", geo_spell=false, offensive=false, whm_only=true},
        ["virus"] = {name="Viruna", geo_spell=false, offensive=false, whm_only=true},
        ["viruna"] = {name="Viruna", geo_spell=false, offensive=false, whm_only=true},
        ["sleep"] = {name="Cure", geo_spell=false, offensive=false},
        ["zzz"] = {name="Cure", geo_spell=false, offensive=false},
        ["curse"] = {name="Cursna", geo_spell=false, offensive=false, whm_only=true},
        ["cursna"] = {name="Cursna", geo_spell=false, offensive=false, whm_only=true},
        ["slow"] = {name="Haste", geo_spell=false, offensive=false, whm_only=false},
        ["bind"] = {name="Erase", geo_spell=false, offensive=false, whm_only=true},
        ["weight"] = {name="Erase", geo_spell=false, offensive=false, whm_only=true},
        ["erase"] = {name="Erase", geo_spell=false, offensive=false, whm_only=true},

        -- heals/buffs
        ["protect"] = {name="Protectra", geo_spell=false, offensive=false, tiers={" III", " II", ""}},
        ["shell"] = {name="Shellra", geo_spell=false, offensive=false, tiers={" III", " II", ""}},
        ["stoneskin"] = {name="Stoneskin", geo_spell=false, offensive=false},
        ["ss"] = {name="Stoneskin", geo_spell=false, offensive=false},
        ["refresh"] = {name="Refresh", geo_spell=false, offensive=false, tiers={" II", ""}},
        ["haste"] = {name="Haste", geo_spell=false, offensive=false, tiers={" II", ""}},
        ["cure"] = {name="Cure", geo_spell=false, offensive=false, tiers={" V", " IV", " III", " II", ""}},
        ["cure3"] = {name="Cure", geo_spell=false, offensive=false, tiers={" III", " II", ""}},
        ["cure2"] = {name="Cure", geo_spell=false, offensive=false, tiers={" III", " II", ""}},
        ["curaga"] = {name="Curaga", geo_spell=false, offensive=false, tiers={" III", " II", ""}},
        ["raise"] = {name="Raise", geo_spell=false, offensive=false, tiers={" III", " II", ""}},
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

        ["slow"] = {name="Geo-Slow", geo_spell=true, offensive=true},
        ["torpor"] = {name="Geo-Torpor", geo_spell=true, offensive=true},
        ["slip"] = {name="Geo-Slip", geo_spell=true, offensive=true},
        ["languor"] = {name="Geo-Languor", geo_spell=true, offensive=true},
        ["paralysis"] = {name="Geo-Paralysis", geo_spell=true, offensive=true},
        ["vex"] = {name="Geo-Vex", geo_spell=true, offensive=true},
        ["frailty"] = {name="Geo-Frailty", geo_spell=true, offensive=true},
        ["wilt"] = {name="Geo-Wilt", geo_spell=true, offensive=true},
        ["gravity"] = {name="Geo-Gravity", geo_spell=true, offensive=true},
        ["malaise"] = {name="Geo-Malaise", geo_spell=true, offensive=true},
        ["fade"] = {name="Geo-Fade", geo_spell=true, offensive=true},

        -- ["regen"] = {name="Geo-Regen", geo_spell=true, offensive=false},
        -- ["refresh"] = {name="Geo-Refresh", geo_spell=true, offensive=false},
        -- ["haste"] = {name="Geo-Haste", geo_spell=true, offensive=false},
        ["voidance"] = {name="Geo-Voidance", geo_spell=true, offensive=false},
        ["precision"] = {name="Geo-Precision", geo_spell=true, offensive=false},
        ["attunement"] = {name="Geo-Attunement", geo_spell=true, offensive=false},
        ["focus"] = {name="Geo-Focus", geo_spell=true, offensive=false},
        ["barrier"] = {name="Geo-Barrier", geo_spell=true, offensive=false},
        ["fury"] = {name="Geo-Fury", geo_spell=true, offensive=false},
        ["fend"] = {name="Geo-Fend", geo_spell=true, offensive=false},
        ["acumen"] = {name="Geo-Acumen", geo_spell=true, offensive=false},
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
        ["haaaste"] = {name="Indi-Haste", geo_spell=true, offensive=false},
        ["eva"] = {name="Indi-Voidance", geo_spell=true, offensive=false},
        ["acc"] = {name="Indi-Precision", geo_spell=true, offensive=false},
        ["meva"] = {name="Indi-Attunement", geo_spell=true, offensive=false},
        ["macc"] = {name="Indi-Focus", geo_spell=true, offensive=false},
        ["def"] = {name="Indi-Barrier", geo_spell=true, offensive=false},
        ["atk"] = {name="Indi-Fury", geo_spell=true, offensive=false},
        ["mdef"] = {name="Indi-Fend", geo_spell=true, offensive=false},
        ["matk"] = {name="Indi-Acumen", geo_spell=true, offensive=false},

        -- indi stats
        ["vit"] = {name="Indi-VIT", geo_spell=true, offensive=false},
        ["str"] = {name="Indi-STR", geo_spell=true, offensive=false},
        ["dex"] = {name="Indi-DEX", geo_spell=true, offensive=false},
        -- ["haaaste"] = {name="Indi-Haste", geo_spell=true, offensive=false},
        -- ["eva"] = {name="Indi-Voidance", geo_spell=true, offensive=false},
        -- ["acc"] = {name="Indi-Precision", geo_spell=true, offensive=false},
        -- ["meva"] = {name="Indi-Attunement", geo_spell=true, offensive=false},
        -- ["macc"] = {name="Indi-Focus", geo_spell=true, offensive=false},
        -- ["def"] = {name="Indi-Barrier", geo_spell=true, offensive=false},
        -- ["atk"] = {name="Indi-Fury", geo_spell=true, offensive=false},
        -- ["mdef"] = {name="Indi-Fend", geo_spell=true, offensive=false},
        -- ["matk"] = {name="Indi-Acumen", geo_spell=true, offensive=false},

        ["slow"] = {name="Indi-Slow", geo_spell=true, offensive=false},
        ["torpor"] = {name="Indi-Torpor", geo_spell=true, offensive=false},
        ["slip"] = {name="Indi-Slip", geo_spell=true, offensive=false},
        ["languor"] = {name="Indi-Languor", geo_spell=true, offensive=false},
        ["paralysis"] = {name="Indi-Paralysis", geo_spell=true, offensive=false},
        ["vex"] = {name="Indi-Vex", geo_spell=true, offensive=false},
        ["frailty"] = {name="Indi-Frailty", geo_spell=true, offensive=false},
        ["wilt"] = {name="Indi-Wilt", geo_spell=true, offensive=false},
        ["gravity"] = {name="Indi-Gravity", geo_spell=true, offensive=false},
        ["malaise"] = {name="Indi-Malaise", geo_spell=true, offensive=false},
        ["fade"] = {name="Indi-Fade", geo_spell=true, offensive=false},

        -- ["regen"] = {name="Indi-Regen", geo_spell=true, offensive=false},
        -- ["refresh"] = {name="Indi-Refresh", geo_spell=true, offensive=false},
        -- ["haste"] = {name="Indi-Haste", geo_spell=true, offensive=false},
        ["voidance"] = {name="Indi-Voidance", geo_spell=true, offensive=false},
        ["precision"] = {name="Indi-Precision", geo_spell=true, offensive=false},
        ["attunement"] = {name="Indi-Attunement", geo_spell=true, offensive=false},
        ["focus"] = {name="Indi-Focus", geo_spell=true, offensive=false},
        ["barrier"] = {name="Indi-Barrier", geo_spell=true, offensive=false},
        ["fury"] = {name="Indi-Fury", geo_spell=true, offensive=false},
        ["fend"] = {name="Indi-Fend", geo_spell=true, offensive=false},
        ["acumen"] = {name="Indi-Acumen", geo_spell=true, offensive=false},
    },
    smn = T{
        ["garuda"] = {name="Garuda", geo_spell=false, offensive=false},
        ["titan"] = {name="Titan", geo_spell=false, offensive=false},
        ["fenrir"] = {name="Fenrir", geo_spell=false, offensive=false},
        ["ramuh"] = {name="Ramuh", geo_spell=false, offensive=false},
        ["levi"] = {name="Leviathan", geo_spell=false, offensive=false},
    },
    leader_flag_map = T{
        -- custom spells. need to assign functions somehow.
        ["sneak"] = {leader_only=true},

        -- ffo and other commands
        ["follow"] = {leader_only=true},
        ["stop"] = {leader_only=true},
        ["po"] = {leader_only=true},
        ["dimmer"] = {leader_only=true},
        ["home"] = {leader_only=true},
        ["mount"] = {leader_only=true},
        ["dismount"] = {leader_only=true},

        -- geo stuff
        ["ind"] = {leader_only=true},
        ["ent"] = {leader_only=true},

        ["lp"] = {leader_only=true},
        ["lpp"] = {leader_only=true},
        ["fc"] = {leader_only=true},
        ["ra"] = {leader_only=true},

        -- smn stuff
        ["smn"] = {leader_only=true},
        ["sic"] = {leader_only=true},
        ["release"] = {leader_only=true},
        ["hastega"] = {leader_only=true},

        -- pew pew
        -- figure this shit out
        ["mb"] = {leader_only=true}, -- magicburst mode
        ["tm"] = {leader_only=true}, -- tell mode
        ["ag"] = {leader_only=true}, -- auto geo/indi spell
    },
}

return SUPER_MAP
