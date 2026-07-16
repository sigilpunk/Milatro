--- JOKERS
-- planets vro 🥀
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

-- CEO Of Idiot
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
                discarded_card:change_suit(other_suits[pseudorandom(1,#other_suits)])
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

-- Blue Card
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

-- Yellow Card
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

-- Spilled Ink
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
                        if not context.scoring_hand[i].base.suit == "Spades" then
                            context.scoring_hand[i]:flip()
                            play_sound('card1', percent)
                            context.scoring_hand[i]:juice_up(0.3, 0.3)
                        end
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
                        if not scored_card.base.suit == "Spades" then
                            scored_card:change_suit("Spades")
                        end
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
                        if not  context.scoring_hand[i].base.suit == "Spades" then
                            context.scoring_hand[i]:flip()
                            play_sound('tarot2', percent, 0.6)
                            context.scoring_hand[i]:juice_up(0.3, 0.3)
                        end
                        return true
                    end
                }))
            end
            delay(0.5)
        end
    end
}

-- The Deal
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
                message = messages[pseudorandom(1, #messages)],
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

-- i fucking hate you and im going to kill you
SMODS.Joker {
    key = "fuck_you",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = 1,
    cost = 0,
    config = {},
    atlas = "Jokers",
    pos = JOKER_PLACEHOLDER_ART,
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

-- Brown Card
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
        text = {""}
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

-- Bodyguard
SMODS.Joker {
    key = "bodyguard",
    blueprint_compat = true,
    perishable_compat = false,
    discovered = false,
    rarity = 2,
    cost = 5,
    config = {
        extra = {
            bodyguard_fee = -10
        }
    },
    atlas = "Jokers",
    pos = { x = 3, y = 4 },
    loc_txt = {
        name = "Bodyguard",
        text = {
            "{C:attention}Disables{} the current {C:attention}Boss Blind{}'s ability",
            "When triggered, takes {C:money}$#1#{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.bodyguard_fee
        } }
    end,

    in_pool = function(self)
        allow_duplicates = false
        return true
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            if G.GAME.blind and not G.GAME.blind.disabled and G.GAME.blind.boss then
                return {
                    message = "Hold It!",
                    dollars = card.ability.extra.bodyguard_fee,
                    colour = G.C.PURPLE,
                    func = function ()
                        G.GAME.blind:disable()
                    end
                }
            end
        end
    end,
}

-- Riff Raff but evil
SMODS.Joker {
    key = "evil_riffraff",
    blueprint_compat = true,
    perishable_compat = false,
    discovered = false,
    rarity = 1,
    cost = 0,
    config = {
        extra = {
            creates = 1,
            w_good = 0.1,
            w_shit = 0.9
        }
    },
    atlas = "Jokers",
    pos = { x = 0, y = 5 },
    loc_txt = {
        name = "Evil Riff-Raff",
        text = {
            "When {C:attention}Blind{} is selected,",
            "Creates #1# {X:dark_edition,C:white}Milatro{} joker then {V:1}fucking dies{}",
            "{C:green}#3#% chance{} of a bad {X:dark_edition,C:white}Milatro{} joker, {C:green}#2#% chance{} of a good one",
            "{C:inactive}(must have room){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.creates,
            card.ability.extra.w_good*100,
            card.ability.extra.w_shit*100,
            colours = { HEX("aa2220")}
        } }
    end,

    in_pool = function(self)
        allow_duplicates = false
        return true
    end,

    calculate = function(self, card, context)
        if context.setting_blind and #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit - 1 then
            local jokers_to_create = math.min(
                card.ability.extra.creates,
                G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer)
            )

            print("jokers_to_create = "..jokers_to_create)
    
            G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
    
            if jokers_to_create > 0 then
    
                local chosen_joker = weighted_choice({
                    {weight = card.ability.extra.w_shit, pool = joker_categories.milatro_dogshit},
                    {weight = card.ability.extra.w_good, pool = joker_categories.milatro_good}
                })
                add_jokers({chosen_joker})
                print(chosen_joker)
    
                G.GAME.joker_buffer = 0
                SMODS.destroy_cards(card, nil, nil, true)
    
                return {
                    message = "see ya loser",
                    colour = G.C.DARK_EDITION
                }
            end
        end
    end,
}

-- Colorblind
SMODS.Joker {
    key = "colorblind",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = 3,
    cost = 8,
    atlas = "Jokers",
    pos = {x = 1, y = 5},
    loc_txt = {
        name = "Colorblind",
        text = {
            "Scored cards give as much",
            "{C:mult}Mult{} as they do {C:chips}Chips{}"
        }
    },

    in_pool = function(self)
        return true
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.end_of_round then
            -- print_table(context.other_card.base)
            return {
                mult = context.other_card:get_chip_bonus()
            }
        end
    end
}

-- Sanctified Sword
SMODS.Joker {
    key = "sword",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = 2,
    cost = 6,
    atlas = "Jokers",
    pos = JOKER_PLACEHOLDER_ART,
    config = {
        extra = {
            mult = 0
        }
    },
    loc_txt = {
        name = "Sanctified Sword",
        text = {
            "When {C:attention}Blind{} is selected,",
            "destroys every Joker to the {C:attention}right{ and",
            "permanently add {C:attention}double{} their sell values to this {C:mult}Mult{}",
            "{C:inactive}(Currently {C:mult}+#1#{} {C:inactive}Mult){}"
        }
    },

    in_pool = function(self)
        return true
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.mult
        } }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            -- detect slot #
            local card_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    card_pos = i
                    break
                end
            end
            local jokers_to_slice = {}
            for i = card_pos + 1, #G.jokers.cards, 1 do
                jokers_to_slice[#jokers_to_slice+1] = G.jokers.cards[i]
            end
            if card_pos and jokers_to_slice and not SMODS.is_eternal(G.jokers.cards[card_pos + 1], card) and not G.jokers.cards[card_pos + 1].getting_sliced then
                local net_mult = 0
                for _, joker in ipairs(jokers_to_slice) do
                    joker.getting_sliced = true
                    G.GAME.joker_buffer = G.GAME.joker_buffer - 1
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.GAME.joker_buffer = 0
                            card.ability.extra.mult = card.ability.extra.mult + (joker.sell_cost * 2)
                            net_mult = net_mult + (joker.sell_cost * 2)
                            card:juice_up(0.8, 0.8)
                            joker:start_dissolve({ HEX("57ecab") }, nil, 1.6)
                            play_sound('slice1', 0.96 + pseudorandom() * 0.08)
                            return true
                        end
                    }))
                end
                return {
                    message = localize { type = 'variable', key = 'a_mult', vars = { net_mult } },
                    colour = G.C.RED,
                    no_juice = true
                }
            end
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

-- Revolutionary
SMODS.Joker {
    key = "revolutionary",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = 1,
    cost = 5,
    atlas = "Jokers",
    pos = { x = 2, y = 5 },
    config = { extra = {
        raise_by = 1
    }
    },

    loc_vars = function (self, info_queue, card)
        return  {
            vars = {
                card.ability.extra.raise_by
            }
        }
    end,

    loc_txt = {
        name = "Revolutionary",
        text = {
            "Raises the rank of {C:attention}lowest{}",
            "ranked card held in hand by {C:attention}#1#{}"
        }
    },

    in_pool = function(self)
        return true
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            local temp_ID = 15
            local raised_card = nil
            for i = 1, #G.hand.cards do
                if temp_ID >= G.hand.cards[i].base.id and not SMODS.has_no_rank(G.hand.cards[i]) then
                    temp_ID = G.hand.cards[i].base.id
                    raised_card = G.hand.cards[i]
                end
            end
            if raised_card and raised_card == context.other_card and not(raised_card.base.nominal == 11) then
                if context.other_card.debuff then
                    return {
                        message = localize('k_debuffed'),
                        colour = G.C.RED
                    }
                elseif raised_card then
                    print_table(raised_card.base, 1)
                    -- raise card
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.4,
                        func = function()
                            play_sound('tarot1')
                            card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                    local percent = 1.15 - (1 - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            raised_card:flip()
                            play_sound('card1', percent)
                            raised_card:juice_up(0.3, 0.3)
                            return true
                        end
                    }))
                    delay(0.2)
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.1,
                        func = function()
                            assert(SMODS.modify_rank(raised_card, card.ability.extra.raise_by))
                            return true
                        end
                    }))
                    local percent = 0.85 + (1 - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            raised_card:flip()
                            play_sound('tarot2', percent, 0.6)
                            raised_card:juice_up(0.3, 0.3)
                            return true
                        end
                    }))
                end
            end
        end
    end
}