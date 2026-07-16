--- HELPER FUNCTIONS AND DEFINITIONS

LOGGING_ENABLED = false
SYNERGY_LOGGING_ENABLED = false
JOKER_PLACEHOLDER_ART = { x = 2, y = 3 }

-- joker_categories
joker_categories = {
    food = {
        "j_egg", 
        "j_ice_cream", 
        "j_cavendish", 
        "j_turtle_bean", 
        "j_diet_cola", 
        "j_popcorn", 
        "j_ramen", 
        "j_selzer", 
        "j_gros_michel", 
        "j_mltro_yo_gurt"
    },
    legendary = {
        "j_perkeo", 
        "j_chicot", 
        "j_yorick", 
        "j_triboulet", 
        "j_caino"
    },
    suit = {
        "j_greedy_joker", 
        "j_lusty_joker", 
        "j_wrathful_joker", 
        "j_gluttenous_joker"
    },
    colors = {
        "j_red_card", 
        "j_mltro_blue_card", 
        "j_mltro_yellow_card"
    },
    milatro_base = {
        "j_mltro_planets_vro",
        "j_mltro_ceoofidiot",
        "j_mltro_jobapp",
        "j_mltro_driver",
        "j_mltro_marcelium",
        "j_mltro_fresh_lemon",
        "j_mltro_applebees",
        "j_mltro_blue_card",
        "j_mltro_yellow_card",
        "j_mltro_yo_gurt",
        "j_mltro_spilled_ink",
        "j_mltro_the_deal",
        "j_mltro_teague_westra",
        "j_mltro_fuck_you",
        "j_mltro_brown_card",
        "j_mltro_bodyguard",
        "j_mltro_colorblind",
        "j_mltro_revolutionary",
        "j_mltro_sword",
        "j_mltro_evil_riffraff"
    },
    milatro_synergies = {
        "j_mltro_syn_yaoi",
        "j_mltro_syn_geology",
        "j_mltro_syn_refrigerator",
        "j_mltro_syn_joker_the_movie",
        "j_mltro_syn_pallete",
        "j_mltro_syn_ur_hacking",
        "j_mltro_syn_beelzebub",
        "j_mltro_syn_proletariat",
        "j_mltro_syn_awesome_riffraff",
        "j_mltro_syn_pallete"
    },
    milatro_dogshit = {
        "j_mltro_planets_vro",
        "j_mltro_jobapp",
        "j_mltro_fresh_lemon",
        "j_mltro_blue_card",
        "j_mltro_the_deal",
        "j_mltro_fuck_you",
        "j_mltro_brown_card",
        "j_mltro_bodyguard",
        "j_mltro_revolutionary",
    },
    milatro_syn_pack_blacklist={
        "j_cavendish"
    },
    milatro_good = {},
    milatro_all = {},
    milatro_syn_pack_pool={}
}
local function pseudorandom_joker_choice(pool, seed)
    local key = pseudorandom_element(pool, seed)
    return SMODS.create_card({
        key = key
    })
end



function weighted_choice(weighted_pools)
    local roll = pseudorandom(0,1)
    local cumulative = 0

    for _, entry in ipairs(weighted_pools) do
        cumulative = cumulative + entry.weight
        if roll < cumulative then
            local pool = entry.pool
            return pool[pseudorandom(1, #pool)]
        end
    end
end

function table.choice(pool)
    return pool[pseudorandom(1, #pool)]
end

function table.extend(dest, src)
    for _, v in ipairs(src) do
        table.insert(dest, v)
    end
end

-- Source - https://stackoverflow.com/q/1758991
-- Posted by Wookai, modified by community. See post 'Timeline' for change history
-- Retrieved 2026-03-02, License - CC BY-SA 3.0

function table.removekey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end

table.extend(joker_categories.milatro_all, joker_categories.milatro_base)
table.extend(joker_categories.milatro_all, joker_categories.milatro_synergies)

local dogshitlut = {}
for _, v in ipairs(joker_categories.milatro_dogshit) do
    dogshitlut[v] = true
end

for _, v in ipairs(joker_categories.milatro_base) do
    if not dogshitlut[v] then
        table.insert(joker_categories.milatro_good, v)
    end
end

-- check_jokers
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

-- add_jokers
add_jokers = function (keys)
    for _, key in ipairs(keys) do
        local joker = create_card('Joker', G.jokers, nil, nil, nil, nil, key)
        joker:add_to_deck()
        G.jokers:emplace(joker)
    end
end