--- STEAMODDED HEADER
--- MOD_NAME: Milatro
--- MOD_ID: milatro
--- MOD_AUTHOR: [sigilpunk]
--- MOD_DESCRIPTION: balatro but milo
--- PREFIX: mltro
----------------------------------------------
------------MOD CODE -------------------------
---

--- TODO:
--- -> [!] Create Spectral Card for Starman Seal
--- -> [!] Create Planet Card for Four Of A Four
--- -> [!] Art for Sanctified Sword (and others)
--- -> [!] Badge Synergetic Jokers (Syngery requirements)
--- -> [!] riff-raff variants not spawning jokers
--- 
--- Joker Synergies: create new joker when certain jokers are obtained, destroys synergized jokers
---     - balatro
---    -> Pallete: Red Card + Yellow Card + Blue Card = Gives $2, +5 chips, +5 mult per booster pack skipped
---     - DONE | yea, ur hacking buddy: All Legendary jokers = sets base chips to 0 after all scoring and jokers
---     - DONE | Beelzebub: All suit jokers = +6 mult on every card (Art: all four jokers in quadrents)
---     - DONE | Dictatorship of the Proletariat: Revolutionary, Raised Fist: Every Boss Blind, all cards ranks are mirrored (A <-> 2, K <-> 3, Q <-> 4, etc.)
--- 
--- Joker Ideas:
---     - DONE | Riff Raff but awesome: spawns one random Milatro joker then fucking dies
---     - DONE |    UPDATE: Rename cange to riff-raff but evil, 90% chance to spawn a dogshit milatro joker
---     - DONE | Riff Raff but awesome: spawns one random good Milatro joker then fucking dies   
---     - DONE | Tritanopia: Cards give the same amount of mult as they do chips
---     - DONE | Revolutionary: (synergy with raised fist) raise lowest card in hand by one rank
---    -> Milk Carton: food joker, has time limit
---             "Drink" button: Start timer
---             +1 mult per second left on the timer (60sec maybe)
            --- 0-10 seconds remaining: +6 mult (fresh)
            -- 10-30 seconds: +4 mult (good)
            -- 30-50 seconds: +2 mult (aging)
            -- 50-60 seconds: +1 mult (nearly expired)
            -- 60+ seconds: Dissolves automatically
---            
---             "Spoils" after 30sec? -1 mult per hand played (add badge and show status text)
---             if i decide on the spoiling mechanic +2 mult flat or smth idk
---     - DONE (no art) | Sanctified Sword: When Blind is selected, Destroys every joker to the right and permanently adds double its sell value to this mult 

-- Load order matters: core defines globals/helpers that later files depend on,
-- synergy sets up joker_categories.milatro_syn_pack_pool before jokers reference it.
SMODS.load_file("src/core.lua")()
SMODS.load_file("src/synergy.lua")()
SMODS.load_file("src/atlases.lua")()
SMODS.load_file("src/sounds.lua")()
SMODS.load_file("src/jokers.lua")()
SMODS.load_file("src/synergy_jokers.lua")()
SMODS.load_file("src/tarots.lua")()
SMODS.load_file("src/seals.lua")()
SMODS.load_file("src/hands.lua")()
SMODS.load_file("src/blinds.lua")()
SMODS.load_file("src/boosters.lua")()

----------------------------------------------
------------MOD CODE END----------------------