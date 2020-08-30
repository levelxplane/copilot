_addon.name    = 'copilot'
_addon.author  = 'Berlioz'
_addon.version = '1.0.0'
_addon.command = 'copilot'

string = require('string')
sets = require('sets')
tables = require('tables')
require('packets')
-- require('filters')
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
    MAGICBURST = false,  -- try to MB if enabled
    PARTY_ONLY = true,
}
local MB_COUNTER = 1
local NUKE_TIER_LIMIT = 5


local SPELL_FLAG_MAP = MAPS.spell_flag_map
local GEO_FLAG_MAP = MAPS.geo
local INDI_FLAG_MAP = MAPS.ind
local SMN_FLAG_MAP = MAPS.smn

local LEADER_FLAG_MAP = MAPS.leader_flag_map

-- local CUSTOM_FLAG_MAP = T{}

local WS_FLAGS = MAPS.mb_ws

local OPTIONS = T{
    CURRENT_TARGET = nil, -- current target id
    FORCE_LUOPAN = nil, -- which Luopan to use by default
    FORCE_INDI = nil,  -- which indi to use by default
    FORCE_ELEMENT = nil, -- which elemental spell to use by default
    ELEMENTAL_TIER_LIMIT = {' III', ' II', ''},
    PLAYER_ID = windower.ffxi.get_player().id, -- ID of character using this script.
    WHITELIST = S{
        LEADER_NAME,
    },
    PARTY_MEMBERS = {},
    AUTOHEAL = true,
    IN_COMBAT = false,
}

TASK_QUEUE = T{}
PREVIOUS_TASK = nil

local next_frame = os.clock()
local frame_check_period = 1
local party_index = {}


buffs = T{}
buffs['whitelist'] = {}
buffs['blacklist'] = {}


-- windower.register_event('incoming chunk', function(id, data)
--     if id == 0x076 then
--         -- print(id)
--         -- print(type(id))
--         for  k = 0, 4 do
--             local id = data:unpack('I', k*48+5)
--             buffs['whitelist'][id] = {}
-- 			buffs['blacklist'][id] = {}
--
--             if id ~= 0 then
--                 for i = 1, 32 do
--                     local buff = data:byte(k*48+5+16+i-1) + 256*( math.floor( data:byte(k*48+5+8+ math.floor((i-1)/4)) / 4^((i-1)%4) )%4) -- Credit: Byrth, GearSwap
--                     if buffs['whitelist'][id][i] ~= buff then
--                         buffs['whitelist'][id][i] = buff
--                     end
-- 					if buffs['blacklist'][id][i] ~= buff then
--                         buffs['blacklist'][id][i] = buff
--                     end
--                 end
--             end
--         end
--     end
--
-- end)

windower.register_event('prerender', function()
    local now = os.clock()

    if now < next_frame then
        return
    end

    next_frame = now + frame_check_period
    coroutine.schedule(process_queue, 0)
    --
    -- print (#TASK_QUEUE)
    -- print (#OPTIONS.PARTY_MEMBERS)

end)
--
-- windower.register_event('incoming chunk', function(id, data)
--
--     -- print(string.format('%1s %2s'.format(id, 'zoop')))
--     if id == 23 and #TASK_QUEUE > 0 then
--         print('looool')
--         process_queue()
--     end
-- end)


local PARTY_QUEUE_LIMIT = 2 -- limit number of things to be queued
local PARTY_QUEUE_COUNTER = 0

function update_party_members()

    party_data = windower.ffxi.get_party()
    if party_data ==  nil then
        return
    end

    if party_data.party1_count ~= #OPTIONS.PARTY_MEMBERS then
        party_names = {}
        party_indexes = {}

        for _, p_ind in pairs({'p0', 'p1', 'p2', 'p3', 'p4', 'p5'}) do
            if party_data[p_ind] and party_data[p_ind].mob ~= nil and  party_data[p_ind].mob.is_npc == false then
                table.insert(party_names, party_data[p_ind].name)
                table.insert(party_indexes, p_ind)
            end
        end
        OPTIONS.PARTY_MEMBERS = party_indexes

        -- todo, better way to maintain whitelist while modifying party
        OPTIONS.WHITELIST = party_names
        table.insert(OPTIONS.WHITELIST, LEADER_NAME)
        -- add more for other people to whitelist
    end
end

function check_party_status()
    if OPTIONS.IN_COMBAT == false then
        -- print('not in combat')
        return
     end

    party_data = windower.ffxi.get_party()
    if PARTY_QUEUE_COUNTER < PARTY_QUEUE_LIMIT and OPTIONS.AUTOHEAL then
        for _, p_ind in pairs(OPTIONS.PARTY_MEMBERS) do
            member = party_data[p_ind]
            if member.mob ~= nil and member.mob.is_npc == false and member.hpp ~= 0 and member.hpp < 60 then
                PARTY_QUEUE_COUNTER = PARTY_QUEUE_COUNTER + 1
                -- print(member.name .. tostring(member.hpp))
                local tmp_details = table.copy(SPELL_FLAG_MAP['cure'])
                tmp_details.tiers = {" III", " II", ""}
                table.insert(TASK_QUEUE, {
                    flag = 'cure',
                    args = {'cure', member.name},
                    sender = member.name,
                    target = member.name,
                    type = 'spell',
                    spell_details = tmp_details,
                    from_queue = true,
                })
                -- print('Adding 1(frame)', 'cure', #TASK_QUEUE)
                break -- exit queue if cure is added.
            -- elseif member.
            end
        end
    end
end

windower.register_event('chat message', function(message, sender, mode, gm)
    player_info = windower.ffxi.get_player()
    -- print (mode)

    if (mode == 3 or mode == 4) and dead(player_info.status) == false then
    else
        -- clear queue if dead
        TASK_QUEUE = T{}
        return
    end
    update_party_members()
    party_names = OPTIONS.WHITELIST
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

    -- print(type(CUSTOM_FLAG_MAP[flag]))
    if mode == 4 and SPELL_FLAG_MAP[flag] and party_only_check then
        spell_info = SPELL_FLAG_MAP[flag]
        if spell_info.whm_only == true then
            if (player_info.sub_job == 'WHM' or player_info.main_job == 'WHM') then
                -- pass
            else
                print ('no whm main or job to cast -nas')
                return
            end
        end
        table.insert(TASK_QUEUE, {
            flag = flag,
            args = args,
            sender = sender,
            target = args[2],
            type = 'spell',
            spell_details = SPELL_FLAG_MAP[flag]
        })
    elseif LEADER_FLAG_MAP[flag] and sender == LEADER_NAME then
        table.insert(TASK_QUEUE, {
            flag = flag,
            args = args,
            sender = sender,
            target = args[3] or '<me>',
            type = 'command',
            spell_details = LEADER_FLAG_MAP[args[2]],
        })
    elseif TOGGLES.MAGICBURST and WS_FLAGS[flag] and sender == LEADER_NAME then
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
    elseif type(CUSTOM_FLAG_MAP[flag]) == 'function' and sender == LEADER_NAME then
        -- print('custom')
        tmp_func = CUSTOM_FLAG_MAP[flag]

        tmp_func()
    end

    if #TASK_QUEUE > 0 then
        -- print('Adding(chat) 1', flag, #TASK_QUEUE)
    end

    -- while #TASK_QUEUE > 0 do
    --     -- print(#TASK_QUEUE)
    --     process_queue()
    --     -- print('task completed. ', #TASK_QUEUE, ' left.')
    --
    -- end
end)

function process_queue()
    -- print(#TASK_QUEUE)
    if TOGGLES.BUSY == false and #TASK_QUEUE > 0 then
        TOGGLES.BUSY = true

        while #TASK_QUEUE > 0 do
            affliction = debuffed()
            if affliction and TOGGLES.SUFFERING == false then
                TOGGLES.SUFFERING = true
                windower.send_command(string.format('input /p I am suffering from %s.', affliction))
                if TOGGLES.SUFFERING then
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

            if current_task.from_queue then
                PARTY_QUEUE_COUNTER = PARTY_QUEUE_COUNTER - 1
            end
            -- print('Dequeuing', current_task.flag, #TASK_QUEUE)

            if current_task.type == 'spell' then
                cast_spell(current_task)
            elseif current_task.type == 'command' then
                execute_leader_command(current_task)
            else
                -- stuff
            end
        end

        TOGGLES.BUSY = false
    else
        TOGGLES.BUSY = false
    end
    check_party_status()
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
    [' II'] = 4,
    [' III'] = 2,
    [' IV'] = 1,
    [' V'] = 1,
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
    if OPTIONS.ELEMENTAL_TIER_LIMIT and listContains({'aero', 'fire', 'blizzard', 'thunder', 'stone', 'water'}, task_table.flag) then
        tmp_tiers = OPTIONS.ELEMENTAL_TIER_LIMIT
    else
        tmp_tiers = spell_details.tiers
    end

    if tmp_tiers then
        for _, tier in pairs(tmp_tiers) do
            spell_resource = primed_spells[spell_details.name .. tier]
            if spell_resource then
                -- print('found ' .. spell_resource.en)
                spell_tier = tier
                break
            end
        end
    else
        spell_resource = primed_spells[spell_details.name]
    end

    player_info = windower.ffxi.get_player()
    if player_info.in_combat then
        OPTIONS.IN_COMBAT = true
    else
        OPTIONS.IN_COMBAT = false
    end
    combat_check = spell_details.offensive == false or (spell_details.offensive == true and OPTIONS.IN_COMBAT)

    -- if combat_check then
    --     print ('in combat or healing spell')
    -- end
    if spell_resource and combat_check and spell_resource.mp_cost < player_info.vitals.mp then

        spell_name = spell_resource.en
        cast_time = spell_resource.cast_time

        windower.send_command('ffo stop')
        windower.ffxi.run(false)

        sleep(0.2)

        TOGGLES.BUSY = true -- redundant

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

        -- print(string.format('sleeping for %1s', spell_name), #TASK_QUEUE)
        -- sleep(cast_time + 2)
        if #TASK_QUEUE == 0 and task_table.from_queue ~= nil then
            -- print('no remaining tasks')
            sleep(cast_time)
        elseif #TASK_QUEUE == 0 and task_table.from_queue == nil then -- try to handle non-queued spell delay
            -- print('no remaining tasks(not queue)')
            sleep(cast_time + 2)
        else
            -- print(#TASK_QUEUE, 'remaining tasks') -- queued spells have 3 second delay
            sleep(cast_time + 3)
        end
    elseif spell_resource ~= nil then
        print(string.format('Usable spell not found for %s', task_table.spell_details.name .. spell_tier))
    elseif spell_resource.mp_cost > player_info.vitals.mp then
        windower.send_command(string.format('input /p Out of MP :c'))
    else
        print('other error found during spell lookup')
    end

    -- print('exiting spell')
    if TOGGLES.ALWAYS_FOLLOW and #TASK_QUEUE == 0 then
        -- TOGGLES.BUSY = false
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

        -- print(flag)
        if flag == 'mb' then
            if tonumber(sub_command) and (0 <= tonumber(sub_command) and tonumber(sub_command) < 6) then
                if tonumber(sub_command) == 0 then
                    OPTIONS.ELEMENTAL_TIER_LIMIT = nil
                    --target = 'none'
                elseif tonumber(sub_command) == 1 then
                    OPTIONS.ELEMENTAL_TIER_LIMIT = {''}
                elseif tonumber(sub_command) == 2 then
                    OPTIONS.ELEMENTAL_TIER_LIMIT = {' II', ''}
                elseif tonumber(sub_command) == 3 then
                    OPTIONS.ELEMENTAL_TIER_LIMIT = {' III', ' II', ''}
                elseif tonumber(sub_command) == 4 then
                    OPTIONS.ELEMENTAL_TIER_LIMIT = {' IV', ' III', ' II', ''}
                end
                print(string.format('spell tier limit: %s', sub_command))

            elseif listContains({'aero', 'fire', 'blizzard', 'thunder', 'stone', 'water', 'none'}, sub_command) then
                if sub_command == 'none' then
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

            if sub_command and 0 < tonumber(sub_command) and tonumber(sub_command) < 8 then
                windower.send_command(string.format('ffo min %s', sub_command))
                print(string.format('ffo min %s', sub_command))
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
                    sleep(2)
                    cast_spell(task_table)
                end
            end

        elseif flag == 'lp' then
            if task_args and sub_command then
                details = GEO_FLAG_MAP[sub_command]

                task_table.flag = sub_command
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
                    sleep(1.5)
                    cast_spell(task_table)
                    windower.send_command('input /ja "Ecliptic Attrition" <me>')
                    sleep(1.5)
                    windower.send_command('input /ja "Life Cycle" <me>')
                    sleep(1.5)
                    windower.send_command('input /ja "Dematerialize" <me>')
                    sleep(1.5)
                end
            end

        elseif flag == 'fc' then
            windower.send_command('input /ja "Full Circle" <me>')
            sleep(1)

        elseif flag == 'ra' then
            windower.send_command('input /ja "Radial Arcana" <me>')
            sleep(1)

        elseif flag ==  'rr' then
            task_table.target = '<me>'
            task_table.spell_details = LEADER_FLAG_MAP[flag]
            cast_spell(task_table)

        elseif flag == 'sic' then
            windower.send_command(string.format('input /assist %s', LEADER_NAME))
            sleep(1)
            windower.send_command('input /p Attacking on <t>!')
            windower.send_command('input /pet Assault <t>')
            windower.send_command('input /lockon')
        elseif flag == 'release' then
            windower.send_command('input /pet Release <me>')
        elseif flag == 'smn' then
            details = SMN_FLAG_MAP[sub_command]

            task_table.flag = sub_command
            task_table.target = '<me>'
            task_table.spell_details = details

            if details then cast_spell(task_table) end
        elseif flag == 'hastega' then
            windower.send_command('input /pet "Hastega II" <me>')
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

------------------------------------------------------------------------------------------------------------------------
----------------------------CUSTOM FUNCTIONS----------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
function example_flag_function()
    print('this is a custom function')
end

function rr()
    windower.send_command('input /ma "Reraise" <me>')
    sleep(5)
end

CUSTOM_FLAG_MAP = {
    ["exampleflag"] = example_flag_function,
    ["rr"] = rr,
}


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
    elseif command == 'autoheal' then
        if OPTIONS.AUTOHEAL then OPTIONS.AUTOHEAL = false else OPTIONS.AUTOHEAL = true end
        if OPTIONS.AUTOHEAL then
            print('will autoheal')
        end
        -- windower.send_command(string.format('input /ma "%s" ', luopan) .. '<me>')
    elseif command == 'po' then
        -- nui id == 597433
        if TOGGLES.PARTY_ONLY then TOGGLES.PARTY_ONLY = false else TOGGLES.PARTY_ONLY = true end
        if OPTIONS.PARTY_ONLY then
            print('only party')
        end
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

function dead(current_status)
    dead_status = {2, 3}
    if listContains(dead_status, current_status) then
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
