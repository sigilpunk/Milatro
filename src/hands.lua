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