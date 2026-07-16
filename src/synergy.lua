--- SYNERGY STUFF
-- transfer_pallete_stats
-- Carries over the accumulated chips/mult/dollars from Red Card, Blue Card,
-- and Yellow Card into the freshly spawned Pallete joker before they dissolve.
local function transfer_pallete_stats(found_jokers, new_joker)
    new_joker.ability.extra = new_joker.ability.extra or {}
    new_joker.ability.extra.chips = new_joker.ability.extra.chips or 0
    new_joker.ability.extra.mult = new_joker.ability.extra.mult or 0
    new_joker.ability.extra.dollars = new_joker.ability.extra.dollars or 0

    for _, joker in ipairs(found_jokers) do
        local key = joker.config.center.key
        local extra = joker.ability and joker.ability.extra

        if key == "j_red_card" then
            -- Red Card's config.extra is just the static +N-per-skip increment;
            -- the actual accumulated bonus lives in ability.mult
            local red_mult = (joker.ability and joker.ability.mult) or 0
            new_joker.ability.extra.mult = new_joker.ability.extra.mult + red_mult
        elseif extra then
            if key == "j_mltro_blue_card" then
                new_joker.ability.extra.chips = new_joker.ability.extra.chips + (extra.chips or 0)
            elseif key == "j_mltro_yellow_card" then
                new_joker.ability.extra.dollars = new_joker.ability.extra.dollars + (extra.dollars or 0)
            end
        end
    end

    card_eval_status_text(new_joker, 'extra', nil, nil, nil, {
        message = "Levels Merged!",
        colour = G.C.DARK_EDITION
    })
end

-- synergies
local synergies = {
    {required = {"j_scary_face", "j_smiley"}, spawn = "j_mltro_syn_yaoi"}, -- Fixed: added j_ prefix
    {required = {"j_rough_gem", "j_bloodstone", "j_arrowhead", "j_onyx_agate"}, spawn = "j_mltro_syn_geology"},
    {required = joker_categories.food, spawn = "j_mltro_syn_refrigerator", n_required = 3},
    {required = {"j_popcorn", "j_hack"}, spawn = "j_mltro_syn_joker_the_movie"},
    {required = joker_categories.colors, spawn = "j_mltro_syn_pallete", on_spawn = transfer_pallete_stats},
    {required = joker_categories.legendary, spawn = "j_mltro_syn_ur_hacking"},
    {required = joker_categories.suit, spawn = "j_mltro_syn_beelzebub"},
    {required = {"j_mltro_syn_beelzebub", "j_mltro_syn_geology"}, spawn = "j_mltro_syn_godhand"},
    {required = {"j_mltro_revolutionary", "j_raised_fist"}, spawn="j_mltro_syn_proletariat"},
    {required = {"j_mltro_evil_riffraff", "j_riff_raff"}, spawn="j_mltro_syn_awesome_riffraff"}
}

table.extend(joker_categories.milatro_syn_pack_blacklist, joker_categories.legendary)

for _,syn in pairs(synergies) do
    table.extend(joker_categories.milatro_syn_pack_pool, syn["required"])
end

-- add synergetic badges to synergetic jokers
for _,key in pairs(joker_categories.milatro_syn_pack_pool) do
    if not string.find(key, "mltro") then
        SMODS.Joker:take_ownership(
            key,
            {
                set_badges = function(self, card, badges)
                    badges[#badges+1] = create_badge(
                        "Synergetic",
                        G.C.DARK_EDITION,
                        G.C.WHITE,
                        0.8
                    )
                end
            }
        )
    elseif nil then
        local joker = SMODS.Jokers["j_"..key]
        if joker then
            local old_set_badges = joker.set_badges
            joker.set_badges = function(self, card, badges)
                if old_set_badges then
                    old_set_badges(self, card, badges)
                end

                badges[#badges+1] = create_badge(
                    "Synergetic",
                    G.C.DARK_EDITION,
                    G.C.WHITE,
                    0.8
                )
            end
        end
    end
end

for _,syn in pairs(synergies) do
    table.extend(joker_categories.milatro_syn_pack_blacklist, {syn["spawn"]})
end

for _,v in ipairs(joker_categories.milatro_syn_pack_blacklist) do
    table.removekey(joker_categories.milatro_syn_pack_pool, v)
end

-- table.extend(joker_categories.milatro_syn_pack_blacklist, joker_categories.milatro_synergies)


--- Old check_synergy
-- check_synergy = function (check_keys, spawn_keys)
--     local jokers = G.jokers.cards
--     local n_found = 0
--     for i = #jokers, 1, -1 do
--         local joker = jokers[i]
--         local current_key = joker.config.center.key
--         for _, v in pairs(check_keys) do
--             if v == current_key then
--                 n_found = n_found + 1
--                 joker:start_dissolve()
--             end
--         end
--     end
--     if n_found >= #check_keys then
--         return true
--     else
--         return false
--     end
-- end

-- log
local log = function (message, enabled)
    if LOGGING_ENABLED and enabled then
        print("[MLTRO_DEBUG] "..message)
    end
end

-- stringify_table
__stringify_depth = 0
stringify_table = function (table, depth_limit, depth)
    depth = depth or 0
    depth_limit = depth_limit or 1
    local s = "{"
    for k,v in pairs(table) do
        s = s.."\t"
        if type(v) == "table" and depth < depth_limit then
            v = stringify_table(v, depth_limit, __stringify_depth)
            __stringify_depth = __stringify_depth + 1
        elseif type(v) == "table" and depth >= depth_limit then
            v = tostring(v)
            __stringify_depth = 0
        end
        v = tostring(v)
        s = s.."\n".."\""..k.."\""..": "..v..","
    end
    local final_string = s.."}"
    if depth > 0 then
        final_string = final_string..","
    end
    return final_string
end

-- print_table
print_table = function (table, depth_limit)
    print(stringify_table(table, depth_limit))
end

-- check_synergy
check_synergy = function (required_keys, spawn_key, n_required, LOGGING, on_spawn)
    -- LOGGING = LOGGING or LOGGING_ENABLED
    -- LOGGING = LOGGING or (SYNERGY_LOGGING_ENABLED and LOGGING_ENABLED)
    local LOGGING = false
    if not n_required then
        n_required = #required_keys -- Default to requiring all jokers 
    end
    log("Starting 'check_synergy' routine with "..n_required.." required jokers", LOGGING)
    log("  > Check spawn conditions for '"..spawn_key.."'", LOGGING)
    local jokers = G.jokers.cards
    log("  > Current jokers:", LOGGING)
    for i, joker in ipairs(jokers) do
        log("    > ["..i.."] '"..joker.config.center.key.."'", LOGGING)
    end
    local found_jokers = {}
    local copied_required_keys = {}
    log("  > Copying table 'required_keys' into 'copied_required_keys'...", LOGGING)
    for i, v in ipairs(required_keys) do
        copied_required_keys[i] = v
        log("    > Copied '"..v.."' into index "..i.." of table 'copied_required_keys'", LOGGING)
    end
    
    -- Find all required jokers
    for i = #jokers, 1, -1 do
        local joker = jokers[i]
        local current_key = joker.config.center.key
        log("  > Entering loop to check '"..current_key.."' against table 'required_keys'", LOGGING)
        
        for req_index, required_key in ipairs(copied_required_keys) do
            if required_key == current_key then
                log("    > Found '"..current_key.."'!", LOGGING)
                log("    > Adding '"..current_key.."' to table 'found_jokers'", LOGGING)
                table.insert(found_jokers, joker)
                log("    > Removing '"..copied_required_keys[req_index].."' from table 'copied_required_keys'", LOGGING)
                -- copied_required_keys[req_index] = nil
                table.remove(copied_required_keys, req_index)
                log(" [!]> Breaking loop [main.lua; line 131]", LOGGING)
                break
            else
                log("    > '"..current_key.."' is NOT '"..required_key.."', continuing", LOGGING)
            end
        end
    end
    
    -- Check if we found enough jokers
    if #found_jokers >= n_required then
        log("  > Found enough ("..n_required..") jokers!", LOGGING)
        log("  > Starting dissolve on all jokers...", LOGGING)
        -- Dissolve the found jokers
        for _, joker in pairs(found_jokers) do
            joker:start_dissolve()
            log("    > Dissolved "..joker.config.center.key, LOGGING)
        end
        
        -- Spawn the new synergy joker
        if spawn_key then
            log("  > Spanwing '"..spawn_key.."'", LOGGING)
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.3,
                func = function()
                    -- Check if the joker key exists before trying to create it
                    if not G.P_CENTERS[spawn_key] then
                        error("ERROR: Synergy joker key '" .. spawn_key .. "' not found!")
                        return true
                    end
                    
                    local new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, spawn_key)
                    new_joker:add_to_deck()
                    G.jokers:emplace(new_joker)

                    -- Let the synergy transfer stats from the dissolved jokers, if defined
                    if on_spawn then
                        on_spawn(found_jokers, new_joker)
                    end
                    
                    -- Show synergy message
                    card_eval_status_text(new_joker, 'extra', nil, nil, nil, {
                        message = "Synergy!",
                        colour = G.C.DARK_EDITION
                    })
                    play_sound('card1')
                    play_sound('polychrome1')
                    return true
                end
            }))
        end
        
        return true
    else
        log("[!] Did not find enough jokers!", LOGGING)
        return false
    end
end

-- check_all_synergies
local function check_all_synergies()
    for _, synergy in pairs(synergies) do
        check_synergy(synergy.required, synergy.spawn, synergy.n_required, false, synergy.on_spawn)
    end
end

-- Card:add_to_deck hook
local card_add_to_deck = Card.add_to_deck
function Card:add_to_deck(from_debuff)
    local ret = card_add_to_deck(self, from_debuff)
    
    -- Only check synergies when a joker is added (not from debuff effects)
    if not from_debuff and self.ability and self.ability.set == 'Joker' then
        -- Delay the synergy check slightly to ensure the card is fully added
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                check_all_synergies()
                return true
            end
        }))
    end
    
    return ret
end

-- Card:buy_and_use hook
local card_buy_and_use = Card.buy_and_use
function Card:buy_and_use(area, skip_animation)
    local ret = card_buy_and_use(self, area, skip_animation)
    
    -- Check synergies after buying a joker
    if self.ability and self.ability.set == 'Joker' then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                check_all_synergies()
                return true
            end
        }))
    end

    for k, v in pairs(G.P_CENTERS) do
        if string.find(k, "yaoi") then
            print("Found yaoi joker: " .. k)
        end
    end
    
    return ret
end

-- Game:start_run hook
local game_start_run = Game.start_run
function Game:start_run(args)
    local ret = game_start_run(self, args)
    
    -- Check synergies at the start of each run
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 1.0,
        func = function()
            check_all_synergies()
            return true
        end
    }))
    
    return ret
end