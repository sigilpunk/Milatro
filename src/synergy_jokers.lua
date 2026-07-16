--- SYNERGY RARITY & SYNERGY JOKERS
--- SYNERGY RARITY
SMODS.Rarity {
    key="synergy_rarity",
    loc_txt={
        name="Synergy"
    },
    pools={
        ["Joker"]=true
    },
    badge_colour=G.C.DARK_EDITION
}


--- SYNERGY JOKERS
-- Yaoi
SMODS.Joker {
    key = "syn_yaoi",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = "mltro_synergy_rarity", 
    cost = 0,
    config = {
        extra = {
            mult = 10,
            chips = 60
        }
    },
    atlas = "Jokers",
    pos = JOKER_PLACEHOLDER_ART,
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


}

-- Geology
SMODS.Joker {
    key = "syn_geology",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = "mltro_synergy_rarity", 
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


}

-- Refrigerator
SMODS.Joker {
    key = "syn_refrigerator",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = "mltro_synergy_rarity", 
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
            add_jokers({joker_categories.food[pseudorandom(1, #joker_categories.food)]})
            return {
                message = "Yummy!",
                card = card
            }
        end
    end,


}

-- "Joker: The Movie"
SMODS.Joker {
    key = "syn_joker_the_movie",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = "mltro_synergy_rarity", 
    cost = 0,
    config = {
        extra = {
            mult = 15,
            valid_ranks = {2, 3, 4, 5}
        }
    },
    atlas = "Jokers",
    pos = { x = 2, y = 4 },
    loc_txt = {
        name = "\"Joker: The Movie\"",
        text = {
            "Retrigger each played {C:attention}2{}, {C:attention}3{}, {C:attention}4{}, or {C:attention}5{}.",
            "Each {C:attention}retriggered{} card gives {C:mult}+#1#{} Mult"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.chips } }
    end,

    in_pool = function(self)
        return false -- Synergy jokers shouldn't appear in normal pools
    end,

    calculate = function (self, card, context)
        if context.individual and context.cardarea == G.play then
            for _, scored_card in ipairs(context.scoring_hand) do
                for _, valid_id in ipairs(card.ability.extra.valid_ranks) do
                    if scored_card:get_id() == valid_id then
                        return {
                            card = card,
                            mult = card.ability.extra.mult,
                            repetitions = 2
                        }
                    end
                end
            end
        end
    end,


}

-- yea, ur hacking buddy
SMODS.Joker {
    key = "syn_ur_hacking",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = "mltro_synergy_rarity", 
    cost = 0,
    atlas = "Jokers",
    pos = { x = 3, y = 5 },
    loc_txt = {
        name = "yea, ur hacking buddy",
        text = {
            "hey what the fuck hey bro fuck you"
        }
    },

    in_pool = function(self)
        return false -- Synergy jokers shouldn't appear in normal pools
    end,

    calculate = function (self, card, context)
        if context.joker_main then
            hand_chips = mod_chips(0)
            
            return {
                message = "fuck you",
                colour = G.C.MULT
            }
        end
    end,


}

-- Beelzebub
SMODS.Joker {
    key = "syn_beelzebub",
    blueprint_compat = true,
    perishable_compat = true,
    discovered = false,
    rarity = "mltro_synergy_rarity", 
    cost = 0,
    atlas = "Jokers",
    pos = { x = 0, y = 6 },
    config = {
        extra={
            mult=6
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.mult
        } }
    end,
    loc_txt = {
        name = "Beelzebub",
        text = {
            "{C:mult}+#1# Mult{} per scored card"
        }
    },

    in_pool = function(self)
        return false -- Synergy jokers shouldn't appear in normal pools
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.end_of_round then
            -- print_table(context.other_card.base)
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

-- Awesome Riff-Raff
SMODS.Joker {
    key = "syn_awesome_riffraff",
    blueprint_compat = false,
    perishable_compat = false,
    discovered = false,
    rarity = "mltro_synergy_rarity",
    cost = 0,
    config = {
        extra = {
            creates = 1
        }
    },
    atlas = "Jokers",
    pos = { x = 0, y = 5 },
    loc_txt = {
        name = "Riff-Raff but awesome",
        text = {
            "When {C:attention}Blind{} is selected,",
            "Creates #1# {X:dark_edition,C:white}Milatro{} joker then {V:1}fucking dies{}",
            "{C:green}100% chance{} of a good {X:dark_edition,C:white}Milatro{} joker",
            "{C:inactive}(must have room){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.creates,
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
    
            G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
    
            if jokers_to_create > 0 then
    
                local chosen_key = pseudorandom_element(joker_categories.milatro_good, pseudoseed('syn_awesome_riffraff'))
                add_jokers({chosen_key})
    
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

-- Dictatorship of the Proletariat
SMODS.Joker {
    key = "syn_proletariat",
    blueprint_compat = false,
    perishable_compat = false,
    discovered = false,
    rarity = "mltro_synergy_rarity",
    cost = 0,
    config = {},
    atlas = "Jokers",
    pos = JOKER_PLACEHOLDER_ART,
    loc_txt = {
        name = "Dictatorship of the Proletariat",
        text = {
            "When {C:attention}Boss Blind{} is selected,",
            "all ranks of cards {C:attention}held in hand{} are {C:attention}mirrored{}",
            "{C:inactive,s:0.8}(A <-> 2, K <-> 3, Q <-> 4, etc.){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return {}
    end,

    in_pool = function(self)
        allow_duplicates = false
        return true
    end,

    calculate = function(self, card, context)
        local mirror_table = {
            [14] = 'King',
            [2] = 'Queen',
            [3] = 'Jack',
            [4] = '10',
            [5] = '9',
            [6] = '8',
            [7] = '7',
            [8] = '6',
            [9] = '5',
            [10] = '4',
            [11] = '3',
            [12] = '2',
            [13] = 'Ace'
        }

        if context.first_hand_drawn then-- and G.GAME.blind.boss then
            for i, held_card in ipairs(G.hand.cards) do
                if held_card then
                    local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            held_card:flip()
                            play_sound('card1', percent)
                            held_card:juice_up(0.3, 0.3)
                            return true
                        end
                    }))
                end
            end
            for _, held_card in ipairs(G.hand.cards) do
                if held_card then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0,
                        func = function()
                            assert(SMODS.change_base(held_card, nil, mirror_table[held_card:get_id()], nil))
                            return true
                        end
                    }))
                end
            end
            for i, held_card in ipairs(G.hand.cards) do
                if held_card then
                    local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            held_card:flip()
                            play_sound('tarot2', percent, 0.6)
                            held_card:juice_up(0.3, 0.3)
                            return true
                        end
                    }))
                end
            end
            return {
                message_card = card,
                message = "Revolution!",
                colour = G.C.RED
            }
        end
    end
}

-- Pallete
SMODS.Joker {
    key = "syn_pallete",
    blueprint_compat = true,
    perishable_compat = false,
    discovered = false,
    rarity = "mltro_synergy_rarity",
    cost = 0,
    atlas = "Jokers",
    pos = JOKER_PLACEHOLDER_ART,
    config = { extra = { 
        chip_mod = 5, 
        chips = 0, 
        mult_mod = 5, 
        mult = 0,  
        dollars_mod = 2, 
        dollars = 0
    } },
    loc_txt = {
        name = "Pallete",
        text = {
            "This Joker gains",
            "{C:chips}+#1#{} Chips, {C:mult}+#3#{} Mult, and {C:money}+$#5#{} when any",
            "{C:attention}Booster Pack{} is skipped",
            "{C:inactive,s:0.8}(currently {}{C:chips,s:0.8}+#2#{} {C:inactive,s:0.8}/{} {C:mult,s:0.8}+#4#{} {C:inactive,s:0.8}/{} {C:money,s:0.8}+$#6#{}{C:inactive,s:0.8}){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.chip_mod, card.ability.extra.chips,
            card.ability.extra.mult_mod, card.ability.extra.mult,
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

            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chip_mod } },
                colour = G.C.BLUE,
            })

            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult_mod } },
                colour = G.C.RED,
            })
            
            card.ability.extra.dollars = card.ability.extra.dollars or 0
            card.ability.extra.dollars_mod = card.ability.extra.dollars_mod or 2
            card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.dollars_mod
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "+$"..card.ability.extra.dollars_mod,
                colour = G.C.MONEY,
            })
        end
        
        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
                mult = card.ability.extra.mult
            }
        end
    end,

    calc_dollar_bonus = function(self, card)
        if card.ability.extra.dollars > 0 then
            return card.ability.extra.dollars
        end
    end,
}