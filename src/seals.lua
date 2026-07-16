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