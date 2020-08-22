_addon.name    = 'copilot'
_addon.author  = 'Berlioz'
_addon.version = '1.0.0'
_addon.command = 'copilot'

string = require('string')
sets = require('sets')
tables = require('tables')
-- loop = require('loop')

files = require('files')
resources = require('resources')

MAPS = require('maps')


--------------------------------- Personal Config ---------------------------------------
local LEADER_NAME = 'Berlioz' -- character to follow/assist. basically the actual person playing.
local MOUNT = 'Tulfaire'


local TOGGLES = T{
    BUSY = false,  -- Probably not needed anymore. determine if needed
    SUFFERING = false,  -- if poison, stunned, paralyzed, etc,

    ALWAYS_FOLLOW = true, -- if using ffo, always follow or not.
    MAGICBURST = true,  -- try to MB if enabled
    PARTY_ONLY = true,
}
local MB_COUNTER = 1
local NUKE_TIER_LIMIT = 5


local SPELL_FLAG_MAP = MAPS.spell_flag_map
local GEO_FLAG_MAP = MAPS.geo
local INDI_FLAG_MAP = MAPS.ind

local LEADER_FLAG_MAP = MAPS.leader_flag_map

local CUSTOM_FLAG_MAP = MAPS.custom

local WS_FLAGS = MAPS.mb_ws

local OPTIONS = T{
    CURRENT_TARGET = nil, -- current target id
    FORCE_LUOPAN = nil, -- which Luopan to use by default
    FORCE_INDI = nil,  -- which indi to use by default
    FORCE_ELEMENT = nil, -- which elemental spell to use by default
    ELEMENTAL_TIER_LIMIT = nil,
    PLAYER_ID = windower.ffxi.get_player().id, -- ID of character using this script.
}

PREVIOUS_TASK = nil

TASK_QUEUE = T{}

windower.register_event('chat message', function(message, sender, mode, gm)

    player_info = windower.ffxi.get_player()
    party_info = windower.ffxi.get_party()

    party_members = {
        party_info.p0,
        party_info.p1,
        party_info.p2,
        party_info.p3,
        party_info.p4,
        party_info.p5,
    }
    party_names = {
        LEADER_NAME,
        -- any really anyone you specically wanna whitelist to always get cures
    }

    -- for k, v in pairs(party_members) do
    --     if v then
    --         print (v.name)
    --         table.insert(party_names, v.name)
    --     end
    -- end

    if dead() then
        return
    end
    -- from party
    args = split(message)

    -- mode 26 is shout
    -- mode 4 is party
    -- mode 3 is tell
    -- mode 27 is ls
    flag = args[1]:lower()

    -- do something
    -- PARTY_ONLY = True and Sender in Party
    -- PARTY_ONLY = False

    -- do not do
    -- PARTY_ONLY = True and SEnder Not in Party

    party_only_check = TOGGLES.PARTY_ONLY == false or (TOGGLES.PARTY_ONLY and listContains(party_names, sender))

    if mode == 4 and SPELL_FLAG_MAP[flag] and party_only_check then
        table.insert(TASK_QUEUE, {
            flag = flag,
            args = args,
            sender = sender,
            target = args[2],
            type = 'spell',
            spell_details = SPELL_FLAG_MAP[flag]
        })
    elseif LEADER_FLAG_MAP[flag] and sender == LEADER_NAME and (mode == 4 or mode == 3) then
        table.insert(TASK_QUEUE, {
            flag = flag,
            args = args,
            sender = sender,
            target = args[3],
            type = 'command',
            spell_details = LEADER_FLAG_MAP[args[2]],
        })
    elseif TOGGLES.MAGICBURST and WS_FLAGS[flag] and sender == LEADER_NAME and (mode == 4 or mode == 3) then
        ws_spells = WS_FLAGS[flag]
        MB_SPELL_COUNTER = (MB_SPELL_COUNTER % #ws_spells) + 1


        if OPTIONS.FORCE_ELEMENT == nil then
            new_flag = ws_spells[MB_SPELL_COUNTER]
        else
            new_flag = OPTIONS.FORCE_ELEMENT
        end
        spell_details = SPELL_FLAG_MAP[new_flag]

        table.insert(TASK_QUEUE, {
            flag = new_flag,
            args = args,
            sender = sender,
            target = nil,
            type = 'spell',
            spell_details = spell_details,
            after_ws = true,
        })
    elseif CUSTOM_FLAG_MAP[flag] and (mode == 4 or mode == 3) then
        -- ?????
    end

    while #TASK_QUEUE > 0 do
        -- print(#TASK_QUEUE)
        process_queue()
        -- print('task completed. ', #TASK_QUEUE, ' left.')

    end
end)

function example()
    print("this is an example of a custom function")
end

function process_queue()

    if TOGGLES.BUSY == false then
        affliction = debuffed()
        if affliction and TOGGLES.SUFFERING == false then
            TOGGLES.SUFFERING = true
            windower.send_command(string.format('input /p I am suffering from %s.', affliction))
            if afflication == 'Silence' then
                windower.send_command('input /item "Echo Drops" <me>')
                sleep(1)
            else
                windower.send_command(string.format('input /item Remedy <me>'))
                sleep(1)
            end
            return
        elseif affliction == nil and TOGGLES.SUFFERING == true then
            windower.send_command('input /p I\'m cured!')
            TOGGLES.SUFFERING = false
        elseif TOGGLES.SUFFERING == true then
            return
        end

        current_task = table.remove(TASK_QUEUE, 1)

        if current_task.type == 'spell' then
            cast_spell(current_task)
        elseif current_task.type == 'command' then
            execute_leader_command(current_task)
        else
            -- stuff
        end

        TOGGLES.BUSY = false
    else
        table.remove(TASK_QUEUE, 1)
        TOGGLES.BUSY = false
    end

end
-- process_queue:loop(10)


-- every element in TASK_QUEUE should look like this.
task_table_structure = {
    flag = 'cure', -- see maps for flags
    args = {'cure', 'Target', 'blahs'}, -- 1 is flag, 2 should usually be target's name, 3+ could be anything
    sender = 'Partymember', -- Lead characters name.
    target = 'Target', -- target's name. can't do enemies
    type = 'type', -- ['spell', 'command']
    spell_details = {
        name="Geo-Fend",  -- see MAPS.spell_map
        geo_spell=true, offensive=true, tiers=false
    },
}

local TIER_DELAY = T{
    [''] = 5,
    [' II'] = 5,
    [' III'] = 3,
    [' IV'] = 3,
    [' V'] = 2,
}

function cast_spell(task_table)


    -- print(string.format('starting new spell %s', task_table.spell_details.name))
    -- if true then
    --     return
    -- end

    spell_name = nil
    spell_tier = nil
    cast_time = 1

    spell_details = task_table.spell_details
    primed_spells = get_available_spells()
    spell_resource = nil
    -- print(task_table.flag)
    -- if task_table.after_ws then
    --     print('from ws')
    -- end
    tmp_tiers = spell_details.tiers

    if OPTIONS.ELEMENTAL_TIER_LIMIT and spell_details.offensive then
        tmp_counter = OPTIONS.ELEMENTAL_TIER_LIMIT

        while tmp_counter - 1 > 0 do
            xxx = table.remove(tmp_tiers, 1)
            tmp_counter = tmp_counter - 1
        end
    end

    if tmp_tiers then
        for _, tier in pairs(tmp_tiers) do
            spell_resource = primed_spells[spell_details.name .. tier]
            if spell_resource then
                spell_tier = tier
                break
            end
        end
    else
        spell_resource = primed_spells[spell_details.name]
    end

    if spell_resource then

        spell_name = spell_resource.en
        cast_time = spell_resource.cast_time

        windower.send_command('ffo stop')
        TOGGLES.BUSY = true

        if spell_details.offensive == true then
            if spell_tier ~= nil and task_table.after_ws then
                delay = TIER_DELAY[spell_tier]
            else
                delay = 1
            end
            windower.send_command(string.format('input /assist %s', LEADER_NAME))
            sleep(delay)
            windower.send_command(string.format('input /p Casting "%s" on <t>!', spell_name))
            windower.send_command(string.format('input /ma "%s" <t>', spell_name))
            windower.send_command('input /lockon')
        else
            if task_table.target then
                target = task_table.target
            else
                target = task_table.sender
            end

            windower.send_command(string.format('input /p Casting "%1s" on %2s!', spell_name, target))
            windower.send_command(string.format('input /ma "%1s" %2s', spell_name, target))
        end
    else
        print(string.format('Usable spell not found for %s', task_table.spell_details.name))
        TOGGLES.BUSY = false
        return
    end

    sleep(cast_time + 3)
    -- print('exiting spell')
    if TOGGLES.ALWAYS_FOLLOW and #TASK_QUEUE == 0 then
        windower.send_command(string.format('ffo %s', LEADER_NAME))
    end
end


-- -- every element in TASK_QUEUE should look like this.
-- task_table_structure = {
--     flag = 'cure', -- see maps for flags
--     args = {'cure', 'Target', 'blahs'}, -- 1 is flag, 2 should usually be target's name, 3+ could be anything
--     sender = 'Leader', -- Lead characters name.
--     target = 'Target', -- target's name. can't do enemies
--     type = 'type', -- ['spell', 'command']
--     spell_details = {
--         name="Geo-Fend",  -- see MAPS.spell_map
--         geo_spell=true, offensive=true, tiers=false
--     },
-- }

MB_SPELL_COUNTER = 1
function execute_leader_command(task_table)
    if LEADER_FLAG_MAP[task_table.flag] then
        TOGGLES.BUSY = true

        flag = task_table.flag
        task_args = task_table.args

        sub_command = task_args[2]

        print(flag)
        if flag == 'mb' then
            if sub_command and 0 <= tonumber(sub_command) and tonumber(sub_command) < 6 then
                if tonumber(sub_command) == 0 then
                    OPTTIONS.ELEMENTAL_TIER_LIMIT = nil
                    target = 'none'
                else
                    OPTIONS.ELEMENTAL_TIER_LIMIT = tonumber(sub_command)
                end
                print(string.format('spell tier limit: %s', sub_command))

            elseif listContains({'aero', 'fire', 'blizzard', 'thunder', 'stone', 'water', 'none'}, sub_command) then
                if target == 'none' then
                    OPTIONS.FORCE_ELEMENT = nil
                    print('not forcing element')
                else
                    OPTIONS.FORCE_ELEMENT = sub_command
                    print(string.format('forcing %s', sub_command))
                end

            else
                if TOGGLES.MAGICBURST then
                    print('Not going to magicburst')
                    TOGGLES.MAGICBURST = false
                else
                    print('Will magicburst')
                    TOGGLES.MAGICBURST = true
                end
            end


        elseif flag == 'sneak' then
            TOGGLES.BUSY = true
            sneak()

        elseif flag == 'follow' then
            windower.send_command(string.format('ffo %s', LEADER_NAME))
            TOGGLES.ALWAYS_FOLLOW = true

            if sub_command and 0 < tonumber(sub_command) and tonumber(sub_command) < 5 then
                windower.send_command(string.format('ffo min %s', sub_command))
            end

        elseif flag == 'stop' then
            windower.send_command('ffo stop')
            TOGGLES.ALWAYS_FOLLOW = false

        elseif flag == 'dimmer' then
            windower.send_command('dimmer')

        elseif flag == 'home' then
            windower.send_command('myhome')

        elseif flag == 'mount' then
            windower.send_command(string.format('input /mount "%s"', MOUNT))

        elseif flag == 'dismount' then
            windower.send_command('input /dismount')

        elseif flag == 'ind' then
            if task_args and sub_command then
                details = INDI_FLAG_MAP[sub_command]

                task_table.flag = sub_command
                task_table.target = '<me>'
                task_table.spell_details = details

                if details then cast_spell(task_table) end
            end

        elseif flag == 'ent' then
            if sub_command and sub_command then
                details = INDI_FLAG_MAP[sub_command]

                task_table.flag = sub_command
                task_table.spell_details = details

                if spell_details then
                    windower.send_command('input /ja "Entrust" <me>')
                    sleep(1)
                    cast_spell(task_table)
                end
            end

        elseif flag == 'lp' then
            if task_args and sub_command then
                details = GEO_FLAG_MAP[sub_command]

                task_table.flag = sub_command
                task_table.target = '<me>'
                task_table.spell_details = details

                if details then cast_spell(task_table) end
            end
        elseif flag == 'lpp' then
            if task_args and sub_command then
                details = GEO_FLAG_MAP[sub_command]

                task_table.flag = sub_command
                task_table.target = '<me>'
                task_table.spell_details = details

                if details then
                    windower.send_command('input /ja "Blaze of Glory" <me>')
                    sleep(1)
                    cast_spell(task_table)
                    windower.send_command('input /ja "Ecliptic Attrition" <me>')
                    sleep(1)
                    windower.send_command('input /ja "Life Cycle" <me>')
                    sleep(1)
                    windower.send_command('input /ja "Dematerialize" <me>')
                    sleep(1)
                end
            end

        elseif flag == 'fc' then
            windower.send_command('input /ja "Full Circle" <me>')
            sleep(1)

        elseif flag == 'ra' then
            windower.send_command('input /ja "Radial Arcana" <me>')
            sleep(1)

        elseif flag == 'sic' then
            windower.send_command(string.format('input /assist %s', LEADER_NAME))
            sleep(1)
            windower.send_command('input /p Attacking on <t>!')
            windower.send_command('input /pet Assault <t>')
            windower.send_command('input /lockon')

        elseif flag ==  'rr' then
            task_table.target = '<me>'
            task_table.spell_details = LEADER_FLAG_MAP[flag]
            cast_spell(task_table)
        end
    end
    TOGGLES.BUSY = false
end


------------------------------------------------------------------------------------------------------------------------
----------------------LEADER COMMANDS---------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function sneak()
    windower.send_command(string.format('input /ma "Sneak" %s', LEADER_NAME))
    sleep(7)
    windower.send_command(string.format('input /ma "Invisible" %s', LEADER_NAME))
    sleep(8)
    windower.send_command('input /ma "Sneak" <me>')
    sleep(7)
    windower.send_command('input /ma "Invisible" <me>')
    sleep(7)
end

function rr()
    windower.send_command('input /ma "Reraise" <me>')
    sleep(5)
end

------------------------------------------------------------------------------------------------------------------------
----------------------------CUSTOM FUNCTIONS----------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
function exampleflag()
    print('this is a custom function')
end



------------------------------------------------------------------------------------------------------------------------
----------------------------HELPER FUNCTIONS----------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
windower.register_event('addon command',function (command, ...)
    command = command and command:lower() or 'help'

    local command_args = {...}
    -- for i, a in pairs(command_args) do
    --     print(a)
    -- end

    if command == 'help' or command == 'h' or command == '?' then
        display_help()
    elseif command == 'show' then
        -- do stuff
    elseif command == 'reset' then
        -- do stuff
    elseif command == 'luopan' then

        if command_args[1] ~= nil and listContains(offensive_geo_flags, command_args[1]) then
            luopan = command_args[1] or 'Geo-Frailty'
            print(string.format('Setting Luopan to %s.', luopan))
        end

        -- windower.send_command(string.format('input /ma "%s" ', luopan) .. '<me>')
    elseif command == 'po' then
        -- nui id == 597433
        if TOGGLES.PARTY_ONLY then TOGGLES.PARTY_ONLY = false else TOGGLES.PARTY_ONLY = true end
    else
        display_help()
    end
end)

--display a basic help section
function display_help()
    windower.add_to_chat(7, _addon.name .. ' v.' .. _addon.version)
    windower.add_to_chat(7, 'Usage: //copilot cmd')
end

function get_name_by_id(id)
    mob = windower.ffxi.get_mob_by_index(id)
    if mob ~= nil then
        return mob.name or ''
    else
        return ''
    end
end

function debuffed()
    debuffs = {0, 2, 4, 6, 7, 10, 17, 19, 28}
    active_debuff = listContains(debuffs, windower.ffxi.get_player().buffs)
    if active_debuff then
        return resources.buffs[active_debuff].en
    else
        return nil
    end
end

function dead()
    dead_status = {2, 3}
    if listContains(dead_status, windower.ffxi.get_player().status) then
        return true
    else
        return false
    end
end
-- check if specific spell available with optional parameter, or return all available
function get_available_spells(spell)
    local known_spells = windower.ffxi.get_spells()
    local available = T{}
    local recasts = windower.ffxi.get_spell_recasts()
    for id, learned in pairs(known_spells) do
        if learned and recasts[id] == 0 then
            spell_name = resources.spells[id].en
            if spell ~= nil and spell == spell_name then
                return T{[spell_name] = resources.spells[id]}
            end
            available[spell_name] = resources.spells[id]
        end
    end
    if spell then
        -- if you get this far while checking for a spell,
        -- it was never found
        print('should not be here')
        return nil
    else
        return available
    end
end

function split(inputstr, sep)
    if sep == nil then
            sep = " "
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function sleep(n)  -- seconds
    local clock = os.clock
    local t0 = clock()
    -- print(t0)
    while clock() - t0 <= n do end

    -- t0 = clock()
    -- print(t0)
end

function table_to_str(target_table, delimiter)
    new_str = ''
    for i, t in pairs(target_table) do
        new_str = new_str .. delimiter .. t
    end
    return new_str
end

function listContains(list, value)
    if type(value) == 'table' then
        for _, v in pairs(value) do
            found = listContains(list, v)
            if found then
                return found
            else
                return nil
            end
        end
    else
        for _, v in pairs(list) do
            if value == v then
                return v
            end
        end
    end
    return nil
end

function traverse_table(tmp_table, spaces)
    if spaces == nil then
        spaces = ''
    end
    for k, v in pairs(tmp_table) do
        if type(v) == 'table' then
			print(spaces .. k)
            traverse_table(v, spaces .. ' ')
        else
            print(spaces .. k .. ': ' .. v)
        end
    end
end

-- ideal: you watch all the party packets for updates
-- less-ideal: use functions.loop
-- also less-ideal: use prerender
-- also also less-ideal: while true with a sleep inside -- especially dangerous
-- ---------------------------
-- delay = 0.2
-- function stuff_that_happens_often()
--   local party_info = get_party()
--   -- etc
-- end
--
-- stuff_that_happens_often:loop(delay)
---------------------------------
-- local framecount = 0
-- global_variable_1 = 'blah'
-- windower.register_event('prerender',function(stuff)
--     framecount = framecount +1
--     if framecount > 10 then
--         framecount = 0
--         party_info = windower.ffxi.get_party()
--         dothingswith(party_info)
--     end
-- end)
--------------------------
