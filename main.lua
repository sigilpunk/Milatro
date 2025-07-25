--- STEAMODDED HEADER
--- MOD_NAME: Milatro
--- MOD_ID: milatro
--- MOD_AUTHOR: [sigilpunk]
--- MOD_DESCRIPTION: balatro but milo
--- PREFIX: mltro
----------------------------------------------
------------MOD CODE -------------------------

-- Jokers atlas
SMODS.Atlas{
    key = "Jokers",
    path = "Jokers.png",
    px = 71,
    py = 95
}

-- Tarots atlas
SMODS.Atlas{
    key = "Tarots",
    path = "Tarots.png",
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
    key = "yo gurt",
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
        allow_duplicates = false
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

-- SMODS.PokerHandPart {
--     key = "four_flush",
--     evaluate = function(parts, hand)
--         print(hand)
--         return {}
--     end
-- }


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
    -- visible = false,
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

----------------------------------------------
------------MOD CODE END----------------------