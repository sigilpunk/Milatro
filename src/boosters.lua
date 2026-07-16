--- BOOSTER PACKS
-- Synergy Pack - pool contains all required jokers for all synergies
SMODS.Booster {
    key="synergy_pack",
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra,
            card.ability.choose
        }}
    end,
    loc_txt={
        name="Synergy Pack",
        text={
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2# {X:green,C:white}Synergetic{} jokers"
        }
    },
    atlas='Boosters',
    pos={x=0,y=0},
    cost=6,
    config = { extra = 3, choose = 1 },
    discovered=false,
    create_card=function(self, card, context)
        local key = pseudorandom_element(joker_categories.milatro_syn_pack_pool, pseudoseed('mltro_synergy_pack'))
        return SMODS.create_card({
            key = key
        })
    end
}