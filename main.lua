--- STEAMODDED HEADER
--- MOD_NAME: Milatro
--- MOD_ID: milatro
--- MOD_AUTHOR: [sigilpunk]
--- MOD_DESCRIPTION: balatro but milo
--- PREFIX: mltro
----------------------------------------------
------------MOD CODE -------------------------



--- TODO:
--- Create Spectral Card for Starman Seal
--- Create Planet Card for Four Of A Four
--- Create Cash toker (synergy with raised fist: raise lowest card in hand by one rank)
--- Joker Synergies: create new joker when certain jokers are obtained, destroys synergized jokers
---     - balatro
---     - Yaoi: Scary Face + Smiling Face = x2 joker abilities | DONE!
---     - Geology: Rough Gem + Bloodstone + Arrowhead + Onyx Agate = 100% chance $1, X1.5 mult, +50 chips, +7 mult | DONE
---     - Refrigerator: yo gurt + Gros Michael (or Cavendish) + Popcorn + Ramen + Diet Cola + Turtle Bean (5 of any) = 1 random food joker every hand played, ignores joker slots | DONE
---     - "Joker: The Movie": Popcorn + Hack = hack but more retriggers and higher rank
--- 
--- Joker ideas:
---     - Bodyguard: Disables a boss blind, takes $10 when disabling a boss blind
---     - Riff Raff but awesome: spawns one random Milatro joker then fucking dies
---     - Tritanopia: Cards give the same amount of mult as they do chips
---     - Sanctified Sword: Destroys every joker to the left, 

--- HELPER FUNCTIONS AND DEFINITIONS

LOGGING_ENABLED = false

joker_categories = {
    food = {"j_egg", "j_ice_cream", "j_cavendish", "j_turtle_bean", "j_diet_cola", "j_popcorn", "j_ramen", "j_selzer", "j_gros_michel", "j_mltro_yo_gurt", "j_mltro_applebees"}
}

check_jokers = function (keys)
    local jokers = G.jokers.cards
    local n_found = 0
    for i = #jokers, 1, -1 do
        local joker = jokers[i]
        local current_key = joker.config.center.key
        for _, v in pairs(keys) do
            if v == current_key then
                n_found = n_found + 1
            end
        end
    end
    if n_found >= #keys then
        return true
    else
        return false
    end
end

add_jokers = function (keys)
    for _, key in ipairs(keys) do
        local joker = create_card('Joker', G.jokers, nil, nil, nil, nil, key)
        joker:add_to_deck()
        G.jokers:emplace(joker)
    end
end

--- SYNERGY STUFF

local synergies = {
    {required = {"j_scary_face", "j_smiley"}, spawn = "j_mltro_syn_yaoi"}, -- Fixed: added j_ prefix
    {required = {"j_rough_gem", "j_bloodstone", "j_arrowhead", "j_onyx_agate"}, spawn = "j_mltro_syn_geology"},
    {required = joker_categories.food, spawn = "j_mltro_syn_refrigerator", n_required = 3},
    {required = {"j_popcorn", "j_hack"}, spawn = "j_mltro_syn_joker_the_movie"},
}

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

local log = function (message, go)
    go = go or true
    if LOGGING_ENABLED and go then
        print("[MLTRO_DEBUG] "..message)
    end
end

check_synergy = function (required_keys, spawn_key, n_required, LOGGING)
    LOGGING = LOGGING or LOGGING_ENABLED
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

-- Function to check all synergies
local function check_all_synergies()
    for _, synergy in pairs(synergies) do
        check_synergy(synergy.required, synergy.spawn, synergy.n_required, false)
    end
end

-- Hook into the Card:add_to_deck function to trigger synergy checks
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

-- Alternative/Additional: Hook into shop purchase events
-- This ensures synergies trigger when buying jokers from the shop
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

-- Optional: Also check synergies at the start of each round
-- This catches any edge cases or synergies that might have been missed
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

--- ATLASES
-- Jokers atlas
SMODS.Atlas {
    key = "Jokers",
    path = "Jokers.png",
    px = 71,
    py = 95
}

-- Tarots atlas
SMODS.Atlas {
    key = "Tarots",
    path = "Tarots.png",
    px = 71,
    py = 95,
}

-- Blinds atlas
SMODS.Atlas {
    key = "Blinds",
    path = "Blinds.png",
    px = 64,
    py = 64,
    -- frames = 1
}

-- Enhancments atlas
SMODS.Atlas {
    key = "Enhancers",
    path = "Enhancers.png",
    px = 71,
    py = 95,
}

SMODS.Sound {
    key = "friendyoumilo",
    path = "friendyoumilo.wav"
}
SMODS.Sound {
    key = "mj_death",
    path = "mj_death.wav"
}
SMODS.Sound {
    key = "mj_upgrade",
    path = "mj_upgrade.wav"
}
SMODS.Sound {
    key = "mj_downgrade",
    path = "mj_downgrade.wav"
}
SMODS.Sound {
    key = "fart",
    path = "long-brain-fart.wav"
}
--- JOKERS
-- planets_vro
SMODS.Joker {
    key = "planets_vro",
    loc_txt = {
        name = "planets vro 🥀",
        text = {
            "When {C:attention}Blind{} is selected,",
            "creates {C:attention}1{} random",
            "{C:dark_edition,T:e_negative}Negative{} {C:planet,T:v_planet,E:1}Planet Card{}"
        }
    },
    config = {
        extra = {}
    },
    rarity = 2,
    cost = 7,
    atlas = "Jokers",
    pos = {x = 0, y = 0},
    
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    in_pool = function(self)
        allow_duplicates = false
        return true
    end,
    
    -- Function that triggers when blind is selected
    calculate = function(self, card, context)
        if context.setting_blind then
            -- Create a pool of only unlocked planet cards
            local unlocked_planets = {}
            for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                -- Check if the planet has a hand type and if that hand is unlocked
                if v.config and v.config.hand_type and G.GAME.hands[v.config.hand_type] and G.GAME.hands[v.config.hand_type].visible then
                    table.insert(unlocked_planets, v)
                end
            end
            
            -- Only create a planet card if there are unlocked ones
            if #unlocked_planets > 0 then
                local planet_key = pseudorandom_element(unlocked_planets, pseudoseed('test_joker')).key
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "Planets!",
                    G.C.SECONDARY_SET.Planet
                })
                local planet_card = create_card('Planet', G.consumeables, nil, nil, nil, nil, planet_key)
                planet_card:set_edition("e_negative")
                planet_card:add_to_deck()
                G.consumeables:emplace(planet_card)
            else
                -- Fallback message if no planets are available
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "No planets??!???!",
                    colour = G.C.RED
                })
            end
            
            
            return true
        end
    end
}

-- CEO of Idiot
SMODS.Joker {
    key = "ceoofidiot",
    loc_txt = {
        name = "CEO of Idiot",
        text = {
            "Joker gains {X:mult,C:white}X0.5{} Mult if",
            "played hand contains a",
            "{C:attention}4{} and a {C:attention}Flush{},",
            "Loses {X:mult,C:white}X0.25{} Mult per {C:attention}discarded 4{}",
            "{C:inactive}(currently {}{X:mult,C:white}X#1#{}{C:inactive} Mult){}",
            "{s:0.6}also, {C:chips,s:0.6}+4{}{s:0.6} chips{}"
        }
    },
    config = {
        extra = {
            Xmult = 1
        }
    },
    rarity = 3,
    cost = 4,
    atlas = "Jokers",
    pos = {x = 1, y = 0},
    
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    loc_vars = function(self, info_queue, card)
        return {vars = {
            card.ability.extra.Xmult
        }}
    end,

    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then
            play_sound("mltro_friendyoumilo", 1, 3)
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        if not from_debuff then
            play_sound("mltro_mj_death", 1, 1.5)
        end
    end,

    in_pool = function(self)
        allow_duplicates = false
        return true
    end,

    calculate = function(self, card, context)
        if context.before and context.main_eval and not context.blueprint and not context.repitition then
            local is_flush = false
            if next(context.poker_hands["Flush"]) then
                is_flush = true
            end

            local has_four = false
            -- if G.play and G.play.cards then
            --     for i = 1, #G.play.cards do
            --         if G.play.cards[i]:get_id() == 4 then
            --             has_four = true
            --             break
            --         end
            --     end
            -- end
            for _, scored_card in ipairs(context.scoring_hand) do
                if scored_card:get_id() == 4 and not scored_card.debuff then
                    has_four = true
                    break
                elseif scored_card:get_id() == 4 and scored_card.debuff then
                    return {
                        message = "Debuffed!",
                        colour = G.C.RED,
                        card = card
                    }
                end
            end
        
            if is_flush and has_four then
                card.ability.extra.Xmult = card.ability.extra.Xmult + 0.5
                return {
                    message = "Upgrade!",
                    colour = G.C.MULT,
                    card = card,
                    sound = "mltro_mj_upgrade"
                }
            end
        end

        if context.pre_discard and not context.blueprint then
            for _, discarded_card in ipairs(context.full_hand) do
                if discarded_card:get_id() == 4 and not discarded_card.debuff then
                    if card.ability.extra.Xmult > 1 and card.ability.extra.Xmult - 0.25 >= 1 then
                        card.ability.extra.Xmult = card.ability.extra.Xmult - 0.25
                        return {
                            message = ":(",
                            colour = G.C.MULT,
                            card = card,
                            sound = "mltro_mj_downgrade"
                        }
                    elseif discarded_card:get_id() == 4 and discarded_card.debuff then
                        return {
                            message = "Debuffed!",
                            colour = G.C.RED,
                            card = card
                        }
                    end
                else
                    
                end
            end
        end

        if context.cardarea == G.jokers and context.joker_main then
            return {
                -- Show the multiplier value above the joker during scoring
                message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra.Xmult}},
                Xmult_mod = card.ability.extra.Xmult,  -- This actually applies the multiplier to the score
                chips = 4,
                colour = G.C.MULT,
                card = card
            }
        end
    end
}

-- J*b Application
SMODS.Joker {
    key = "jobapp",
    loc_txt = {
        name = "J*b Application",
        text = {
            "Earn {C:money}$12.48{} after every {C:attention}Boss Blind{}",
            "if you have at least {C:attention}16{} {C:enhanced,E:1}Enhanced",
            "cards in your deck",
            "{C:inactive}(currently {}{C:attention}#1#{}{C:inactive}){}"
        }
    },
    config = {
        extra = {
            dollars = 12.48,
            required_enhanced = 16
        }
    },
    rarity = 3,
    cost = 7,
    atlas = "Jokers",
    pos = {x = 2, y = 0},
    
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    loc_vars = function(self, info_queue, card)
        local job_tally = 0
        for _, playing_card in pairs(G.playing_cards or {}) do
            if next(SMODS.get_enhancements(playing_card)) then job_tally = job_tally + 1 end
        end
        return {vars = {job_tally}}
    end,

    in_pool = function(self)
        allow_duplicates = false
        return true
    end,

    calc_dollar_bonus = function(self, card)
        local job_tally = 0
        for _, playing_card in pairs(G.playing_cards or {}) do
            if next(SMODS.get_enhancements(playing_card)) then job_tally = job_tally + 1 end
        end
        if G.GAME.blind and G.GAME.blind.boss then
            if job_tally >= card.ability.extra.required_enhanced then
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "Paycheck!",
                    colour = G.C.MONEY
                })
                return card.ability.extra.dollars
            end
        end
    end,
}

-- Excellent Driver
SMODS.Joker {
    key = "driver",
    loc_txt = {
        name = "Excellent Driver",
        text = {
            "Gives {C:attention}4{} {C:dark_edition,T:e_negative}negative{}",
            "copies of {C:tarot,T:v_wheel_of_fortune}Wheel Of Fortune{}",
            "after selecting a {C:attention}Blind{}"
        }
    },
    config = {
        extra = {
            
        }
    },
    rarity = 3,
    cost = 7,
    atlas = "Jokers",
    pos = {x = 3, y = 0},
    
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    in_pool = function(self)
        allow_duplicates = false
        return true
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            -- local tarot_cards = {}
            -- for k, v in pairs(G.P_CENTER_POOLS.Tarot) do
            --     table.insert(tarot_cards, v)
            -- end

            -- -- Only create a planet card if there are unlocked ones
            -- local wheel_key = tarot_cards["wheel"].key
            -- card_eval_status_text(card, 'extra', nil, nil, nil, {
            --     message = "Crash!",
            --     colour = G.C.SECONDARY_SET.Tarot
            -- })
            for _=1,4 do
                local wheel_card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, "c_wheel_of_fortune")
                wheel_card:set_edition("e_negative")
                wheel_card:add_to_deck()
                G.consumeables:emplace(wheel_card)
            end
            -- Fallback message if no planets are available
            -- card_eval_status_text(card, 'extra', nil, nil, nil, {
            --     message = "No planets??!???!",
            --     colour = G.C.RED
            -- })

            
            
            return true
        end
    end    
}

-- Marcelium
SMODS.Joker {
    key = "marcelium",
    loc_txt = {
        name = "Marcelium",
        text = {
            "Retrigger your entire hand {C:attention}once{}"
        }
    },
    config = {
        extra = {
            
        }
    },
    rarity = 3,
    cost = 7,
    atlas = "Jokers",
    pos = {x = 0, y = 1},
    
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    in_pool = function(self)
        allow_duplicates = false
        return true
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and (context.other_card:is_face() or not context.other_card:is_face()) then
            return {
                repetitions = 1
            }
        end
    end
}

-- Fresh Lemon
SMODS.Joker {
    key = "fresh_lemon",
    loc_txt = {
        name = "Fresh Lemon",
        text = {
            "If discard only contains {C:attention}1{} card",
            "{C:green,E:1}randomize{} that card's {C:attention}suit{}"
        }
    },
    config = {
        extra = {
            
        }
    },
    rarity = 2,
    cost = 6,
    atlas = "Jokers",
    pos = {x = 1, y = 1},
    
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    in_pool = function(self)
        allow_duplicates = false
        return true
    end,

    calculate = function(self, card, context)
        if context.pre_discard then
            if #context.full_hand == 1 then
                discarded_card = context.full_hand[1]
                -- local suit_key = pseudorandom_element()
                local other_suits = ({"Spades", "Clubs", "Hearts", "Diamonds"})
                for i = 1,#other_suits do
                    if other_suits[i] == discarded_card.base.suit then
                        table.remove(other_suits, i)
                        break
                    end
                end
                discarded_card:change_suit(other_suits[math.random(1,#other_suits)])
                return {
                    message = "Woah!",
                    colour = G.C.GOLD,
                    card = card,
                }
            end
        end
    end
}

-- thinion
-- SMODS.Joker {}

-- Applebee's Neighborhood Grill + Bar
SMODS.Joker {
    key = "applebees",
    loc_txt = {
        name = "Applebee's Neighborhood Grill + Bar",
        text = {
            "All items in shop are {C:money}50%{} off",
            "{s:0.7,E:1}(thank you ry!){}"
        }
    },
    config = {
        extra = {
            
        }
    },
    rarity = 2,
    cost = 7,
    atlas = "Jokers",
    pos = {x = 3, y = 1},

    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    in_pool = function(self)
        allow_duplicates = false
        return true
    end,

    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.GAME.discount_percent = G.GAME.discount_percent + 50
                    for _, v in pairs(G.I.CARD) do
                        if v.set_cost then v:set_cost() end
                    end
                    return true
                end
            }))
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        if not from_debuff then
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.GAME.discount_percent = G.GAME.discount_percent - 50
                    for _, v in pairs(G.I.CARD) do
                        if v.set_cost then v:set_cost() end
                    end
                    return true
                end
            }))
        end
    end
}

-- blue card
SMODS.Joker {
    key = "blue_card",
    blueprint_compat = true,
    perishable_compat = false,
    discovered = false,
    rarity = 1,
    cost = 5,
    atlas = "Jokers",
    pos = { x = 0, y = 2 },
    config = { extra = { chip_mod = 5, chips = 0 } },
    loc_txt = {
        name = "Blue Card",
        text = {
            "This Joker gains",
            "{C:chips}+#1#{} Chips when any",
            "{C:attention}Booster Pack{} is skipped",
            "{C:inactive}(currently {}{C:chips}+#2#{}{C:inactive} Chips){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.chip_mod, card.ability.extra.chips
        } }
    end,

    in_pool = function(self)
        allow_duplicates = false
        return true
    end,

    calculate = function(self, card, context)
        if context.skipping_booster and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
            return {
                message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chip_mod } },
                colour = G.C.BLUE,
            }
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end,
}

-- yellow card
SMODS.Joker {
    key = "yellow_card",
    blueprint_compat = true,
    perishable_compat = false,
    discovered = false,
    rarity = 1,
    cost = 5,
    atlas = "Jokers",
    pos = { x = 1, y = 2 },
    config = { extra = { dollars_mod = 2, dollars = 0 } },
    loc_txt = {
        name = "Yellow Card",
        text = {
            "This Joker gains",
            "{C:money}$#1#{} when any",
            "{C:attention}Booster Pack{} is skipped",
            "{C:inactive}(currently {}{C:money}$#2#{}{C:inactive}){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.dollars_mod, card.ability.extra.dollars
        } }
    end,

    in_pool = function(self)
        allow_duplicates = false
        return true
    end,

    calculate = function(self, card, context)
        if context.skipping_booster and not context.blueprint then
            -- Ensure the extra table exists and has default values
            card.ability.extra = card.ability.extra or {}
            card.ability.extra.dollars = card.ability.extra.dollars or 0
            card.ability.extra.dollars_mod = card.ability.extra.dollars_mod or 2
            
            card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.dollars_mod
            return {
                message = "+$"..card.ability.extra.dollars_mod,
                colour = G.C.MONEY,
                card = card,
            }
        end
    end,

    calc_dollar_bonus = function(self, card)
        if card.ability.extra.dollars > 0 then
            return card.ability.extra.dollars
        end
    end,
}

-- yo gurt
SMODS.Joker {
    key = "yo_gurt",
    blueprint_compat = true,
    perishable_compat = false,
    discovered = false,
    rarity = 2,
    cost = 5,
    atlas = "Jokers",
    pos = { x = 2, y = 2 },
    config = { extra = { rounds_alive = 5, health = 5 } },
    loc_txt = {
        name = "yo gurt",
        text = {
            "Balances {C:chips}Chips{} and {C:mult}Mult{}",
            "Joker is destroyed after",
            "{C:attention}#1#{} rounds played",
            "{C:inactive}({}{C:attention}#2#{}{C:inactive} rounds left){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.rounds_alive, card.ability.extra.health
        } }
    end,

    in_pool = function(self)
        allow_duplicates = false
        return true
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                balance = true
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            if card.ability.extra.health > 0 then
                card.ability.extra.health = card.ability.extra.health - 1
                if card.ability.extra.health == 0 then
                    card:start_dissolve()
                    return {
                        message = "Empty!",
                        colour = G.C.RED,
                    }
                else
                    return {
                        message = "Yum!",
                        colour = G.C.PURPLE,
                    }
                end
            elseif card.ability.extra.health == 0 then
                card:start_dissolve()
                return {
                    message = "Empty!",
                    colour = G.C.RED,
                }
            end
        end
    end
}

-- spilled ink
-- Turns your played hand into spades
SMODS.Joker {
    key = "spilled_ink",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = 2,
    cost = 5,
    config = {extra = { suit_conv = "Spades"}},
    atlas = "Jokers",
    pos = { x = 3, y = 2 },
    loc_txt = {
        name = "Spilled Ink",
        text = {
            "Turns all {C:attention}scored cards{}",
            "into {C:SUITS.Spades}Spades{}"
        }
    },

    in_pool = function(self)
        allow_duplicates = false
        return true
    end,

    calculate = function (self, card, context)
        if context.before and context.main_eval and not context.blueprint and not context.repitition then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    play_sound('tarot1')
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
            for i = 1, #context.scoring_hand do
                local percent = 1.15 - (i - 0.999) / (#context.scoring_hand - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        context.scoring_hand[i]:flip()
                        play_sound('card1', percent)
                        context.scoring_hand[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
            delay(0.2)
            for _,scored_card in ipairs(context.scoring_hand) do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        scored_card:change_suit("Spades")
                        return true
                    end
                }))
            end
            for i = 1, #context.scoring_hand do
                local percent = 0.85 + (i - 0.999) / (#context.scoring_hand - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        context.scoring_hand[i]:flip()
                        play_sound('tarot2', percent, 0.6)
                        context.scoring_hand[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
            delay(0.5)
        end
    end
}

-- the deal
-- howie mandel
SMODS.Joker {
    key = "the_deal",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = 2,
    cost = 1,
    config = {extra = {steal_amount = 5, steal_add = 5, reward = 5}},
    atlas = "Jokers",
    pos = { x = 0, y = 3 },
    loc_txt = {
        name = "The Deal",
        text = {
            "{C:chips}-#1# chips{}",
            "{C:money}$#3#{} for every {C:chips}#2# chips{} stolen",
            "{C:chips}+#2# chips{} stolen at the end of each round"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.steal_amount, card.ability.extra.steal_add, card.ability.extra.reward
        } }
    end,

    in_pool = function(self)
        allow_duplicates = false
        if G.GAME.round_resets.ante >= 3 then
            return true
        else
            return false
        end
    end,

    calculate = function (self, card, context)
        if context.joker_main or context.blueprint then
        -- if context.cardarea == G.play then
            local dollar_mod = (card.ability.extra.steal_amount / card.ability.extra.steal_add) * card.ability.extra.reward
            return {
                chips = -card.ability.extra.steal_amount,
                dollars = dollar_mod
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            local messages = {"Deal!", "No Deal!"}
            card.ability.extra.steal_amount = card.ability.extra.steal_amount + card.ability.extra.steal_add
            return {
                message = messages[math.random(1, #messages)],
                colour = G.C.FILTER
            }
        end
    end
}

-- teague westra
SMODS.Joker {
    key = "teague_westra",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = 1,
    cost = 0,
    config = {},
    atlas = "Jokers",
    pos = { x = 1, y = 3 },
    loc_txt = {
        name = "teague westra",
        text = {
            "does nothing"
        }
    },

    in_pool = function(self)
        allow_duplicates = true
    end,

    calculate = function (self, card, context)
        if context.main_joker or context.blueprint then
            return {
                chips = 0
            }
        end
    end
}

 -- fuck you joker
SMODS.Joker {
    key = "fuck_you",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = 1,
    cost = 0,
    config = {},
    atlas = "Jokers",
    pos = { x = 2, y = 3 },
    loc_txt = {
        name = "i fucking hate you and im going to kill you",
        text = {
            "{C:attention}destroys{}",
            "{s:0.6}\"fuck you\"{}"
        }
    },

    in_pool = function(self)
        allow_duplicates = true
    end,

    calculate = function (self, card, context)
        return true
    end,

    set_card_type_badge = function (self, card, badges)
        badges[1] = create_badge("fuck you", G.C.BLACK, G.C.WHITE, 1.2)
    end
}

-- brown card
SMODS.Joker {
    key = "brown_card",
    blueprint_compat = true,
    perishable_compat = false,
    discovered = false,
    rarity = 1,
    cost = 5,
    atlas = "Jokers",
    pos = { x = 3, y = 3 },
    loc_txt = {
        name = "Brown Card",
        text = {
            ""
        }
    },

    in_pool = function(self)
        allow_duplicates = false
        return true
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            play_sound("mltro_fart")
            return {
                message = "i farded",
                card = card
            }
        end
    end,
}

--- SYNERGY JOKERS
-- Yaoi
SMODS.Joker {
    key = "syn_yaoi",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = 4, 
    cost = 0,
    config = {
        extra = {
            mult = 10,
            chips = 60
        }
    },
    atlas = "Jokers",
    pos = { x = 2, y = 3 },
    loc_txt = {
        name = "Yaoi",
        text = {
            "{C:attention,E:1}hot men kissing{}",
            "Played {C:attention}face{} cards give {C:mult}+#1#{} Mult and",
            "{C:chips}+#2#{} Chips when scored"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.chips } }
    end,

    in_pool = function(self)
        return false -- Synergy jokers shouldn't appear in normal pools
    end,

    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
            return {
                mult = card.ability.extra.mult,
                chips = card.ability.extra.chips
            }
        end
    end,

    set_card_type_badge = function (self, card, badges)
        badges[1] = create_badge("Synergy", G.C.DARK_EDITION, G.C.EDITION, 1)
    end
}

-- Geology
SMODS.Joker {
    key = "syn_geology",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = 4, 
    cost = 0,
    config = {
        extra = {
            mult = 7,
            chips = 50,
            xmult = 1.5,
            dollars = 1,
        }
    },
    atlas = "Jokers",
    pos = { x = 1, y = 4 },
    loc_txt = {
        name = "Geology",
        text = {
            "Every scored card has a",
            "{C:green}1 in 1 chance{} to give:",
            "{C:mult}+#1#{} Mult",
            "{C:chips}+#2#{} Chips",
            "{X:mult,C:white}x#3#{} Mult",
            "and {C:money}$#4#{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.mult,
            card.ability.extra.chips,
            card.ability.extra.xmult,
            card.ability.extra.dollars
        } }
    end,

    in_pool = function(self)
        return false -- Synergy jokers shouldn't appear in normal pools
    end,

    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.play then
            return {
                mult = card.ability.extra.mult,
                chips = card.ability.extra.chips,
                dollars = card.ability.extra.dollars,
                xmult = card.ability.extra.xmult
            }
        end
    end,

    set_card_type_badge = function (self, card, badges)
        badges[1] = create_badge("Synergy", G.C.DARK_EDITION, G.C.EDITION, 1)
    end
}

-- Refrigerator
SMODS.Joker {
    key = "syn_refrigerator",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = 4, 
    cost = 0,
    config = {
        extra = {
            mult = 7,
            chips = 50,
            xmult = 1.5,
            dollars = 1,
        }
    },
    atlas = "Jokers",
    pos = { x = 0, y = 4 },
    loc_txt = {
        name = "Refrigerator",
        text = {
            "At the {C:attention}beginning{} of a round,",
            "spawns a random {C:attention}Food Joker{}",
            "{C:inactives:0.8}(Turtle Bean, Popcorn, etc.){}"
        }
    },

    in_pool = function(self)
        return false -- Synergy jokers shouldn't appear in normal pools
    end,

    calculate = function (self, card, context)
        if context.setting_blind then
            add_jokers({joker_categories.food[math.random(1, #joker_categories.food)]})
            return {
                message = "Yummy!",
                card = card
            }
        end
    end,

    set_card_type_badge = function (self, card, badges)
        badges[1] = create_badge("Synergy", G.C.DARK_EDITION, G.C.EDITION, 1)
    end
}

-- "Joker: The Movie"
SMODS.Joker {
    key = "syn_joker_the_movie",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = 4, 
    cost = 0,
    config = {
        extra = {
            mult = 7,
            chips = 50,
            xmult = 1.5,
            dollars = 1,
        }
    },
    atlas = "Jokers",
    pos = { x = 2, y = 4 },
    loc_txt = {
        name = "\"Joker: The Movie\"",
        text = {
            "oeepeepoopoo"
        }
    },

    in_pool = function(self)
        return false -- Synergy jokers shouldn't appear in normal pools
    end,

    calculate = function (self, card, context)
        if context.setting_blind then
            add_jokers({joker_categories.food[math.random(1, #joker_categories.food)]})
            return {
                message = "Yummy!",
                card = card
            }
        end
    end,

    set_card_type_badge = function (self, card, badges)
        badges[1] = create_badge("Synergy", G.C.DARK_EDITION, G.C.EDITION, 1)
    end
}

--- TAROTS
-- four tarot
SMODS.Tarot {
    key = "four_tarot",
    set = "Tarot",
    atlas = "Tarots",
    pos = {x = 0, y = 0},
    cost = 3,
    config = { max_highlighted = 2 },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.max_highlighted
            }
        }
    end,
    unlocked = true, 
    discovered = false,
    loc_txt = {
        name = "four",
        text = {
            "Sets the rank of {C:attention}#1#{}",
            "selected cards to {C:attention}4{}"
        }
    },

    in_pool = function(self)
        return true
    end,

    use = function(self, card, area)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    -- SMODS.modify_rank will increment/decrement a given card's rank by a given amount
                    local card_rank = G.hand.highlighted[i]:get_id()
                    local delta = card_rank - 4
                    assert(SMODS.modify_rank(G.hand.highlighted[i], -delta))
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
}

--- SEALS
-- Starman Seal
SMODS.Seal {
    key = "starman",
    loc_txt = {
        name = "Starman Seal",
        text = {
            "When a card with this seal is {C:attention}scored{},",
            "all other scored cards",
            "become {C:SUITS.Diamonds}Diamonds{}"
        }
    },
    in_pool = function(self, args)
        return true
    end,
    atlas = "Enhancers",
    config = {},
    discovered = true,
    badge_colour = HEX("ec9c24"),
    sound = {
        sound = "whoosh_long",
        per = 1,
        vol = 0.9
    },
    calculate = function (self, card, context)
        if context.cardarea == G.play and context.main_scoring and not context.blueprint and not context.repitition then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    play_sound('tarot1')
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
            for i = 1, #context.scoring_hand do
                local percent = 1.15 - (i - 0.999) / (#context.scoring_hand - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        context.scoring_hand[i]:flip()
                        play_sound('card1', percent)
                        context.scoring_hand[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
            delay(0.2)
            for _,scored_card in ipairs(context.scoring_hand) do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        scored_card:change_suit("Diamonds")
                        return true
                    end
                }))
            end
            for i = 1, #context.scoring_hand do
                local percent = 0.85 + (i - 0.999) / (#context.scoring_hand - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        context.scoring_hand[i]:flip()
                        play_sound('tarot2', percent, 0.6)
                        context.scoring_hand[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
            delay(0.5)
        end
    end
}

-- SMODS.PokerHandPart {
--     key = "four_flush",
--     evaluate = function(parts, hand)
--         print(hand)
--         return {}
--     end
-- }

--- HANDS
-- Flush Four PokerHandPart (4 cards of same suit)
SMODS.PokerHandPart {
    key = "flush_four",
    func = function(hand)
        local ret = {}
        local suits = {}
        
        -- Group cards by suit
        for i = 1, #hand do
            local suit = hand[i].base.suit
            if not suits[suit] then
                suits[suit] = {}
            end
            table.insert(suits[suit], hand[i])
        end
        
        -- Check for suits with exactly 4 cards
        for suit, cards in pairs(suits) do
            if #cards == 4 then
                ret[#ret + 1] = cards
            end
        end
        
        return ret
    end
}

-- four of a four
SMODS.PokerHand {
    key = "four_of_a_four",
    mult = 44,
    chips = 44,
    l_mult = 4, 
    l_chips = 44,
    visible = false,
    loc_txt = {
        name = "Four Of A Four",
        description = {
            "4 cards ranked 4 sharing the same suit"
        }
    },
    example = {
        {'C_4', true },
        {'C_4', true },
        {'C_4', true },
        {'C_4', true },
        {'H_A', false}
    },
    evaluate = function(parts, hand)
        if next(parts._4) and next(parts.mltro_flush_four) then
            local four_cards = parts._4[1]
            local flush_four_cards = parts.mltro_flush_four[1]

            if #four_cards == 4 and #flush_four_cards == 4 then
                local all_fours_in_flush = true
                for i = 1, #four_cards do
                    local found = false
                    for j = 1, #flush_four_cards do
                        if four_cards[i] == flush_four_cards[j] then
                            found = true
                            break
                        end
                    end
                    if not found then
                        all_fours_in_flush = false
                        break
                    end
                end
                
                if all_fours_in_flush then
                    return {
                        SMODS.merge_lists(parts.mltro_flush_four, parts._4, parts._flush),
                        name = "Four Of A Four",
                        flush = parts.mltro_flush_four
                    }
                end
            end
        end
        return {}
    end
}


--- BLINDS
-- evil blind
-- "fuck you"
-- insane chip goal
SMODS.Blind {
    key = "evil_blind",
    loc_txt = {
        name = "evil blind",
        text = {
            "fuck you"
        }
    },
    atlas_table = "Blinds",
    discovered = true,
    boss = { min = 1 },
    pos = {x = 0, y = 0},
    dollars = 15,
    mult = 50000,
    boss_colour = HEX("000000")
}
----------------------------------------------
------------MOD CODE END----------------------