--- STEAMODDED HEADER
--- MOD_NAME: Milatro
--- MOD_ID: milatro
--- MOD_AUTHOR: [sigilpunk]
--- MOD_DESCRIPTION: balatro but milo
--- PREFIX: mltro
----------------------------------------------
------------MOD CODE -------------------------

SMODS.Atlas{
    key = "Jokers",
    path = "Jokers.png",
    px = 71,
    py = 95
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
--- TODO:
--- - BUGFIX: Discarded fours trigger downgrade when debuffed, check flush with 4 when debuffed too (thatnky you sober milo)
--- - POSSIBLE BUG: Dupliactes happened but it meight be because i spawned it in with debug puslus
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

        if context.pre_discard then
            for _, discarded_card in ipairs(context.full_hand) do
                if discarded_card:get_id() == 4 then
                    if card.ability.extra.Xmult > 1 and card.ability.extra.Xmult - 0.25 >= 1 then
                        card.ability.extra.Xmult = card.ability.extra.Xmult - 0.25
                        return {
                            message = ":(",
                            colour = G.C.MULT,
                            card = card,
                            sound = "mltro_mj_downgrade"
                        }
                    end
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
---
--- TODO:
--- - Return joker status when 16 ehnahnced cards 
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
    rarity = 3,
    cost = 8,
    atlas = "Jokers",
    pos = {x = 1, y = 1},
    
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

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
    config = { extra = { money_mod = 2, money = 0 } },
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
            card.ability.extra.money_mod, card.ability.extra.money
        } }
    end,
    calculate = function(self, card, context)
        if context.skipping_booster and not context.blueprint then
            card.ability.extra.money = card.ability.extra.money + card.ability.extra.money_mod
            return {
                message = localize { type = 'variable', key = 'a_dollars', vars = { card.ability.extra.money_mod } },
                colour = G.C.MONEY,
                dollars = card.ability.extra.money
            }
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end,
}


----------------------------------------------
------------MOD CODE END----------------------