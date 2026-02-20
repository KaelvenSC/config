loadstring(game:HttpGet("https://raw.githubusercontent.com/FnDXueyi/list/refs/heads/main/game"))()

_G.FishItConfig = _G.FishItConfig or {
    ["Fishing"] = {
        ["Auto Perfect"] = false,
        ["Random Result"] = false,

        ["Auto Favorite"] = true,
        ["Auto Unfavorite"] = false,
        ["Fish Name"] = {
            "Sacred Guardian Squid",
            {Name = "Ruby", Variant = "Gemstone"},
            -- {Variant = "Leviathan Rage"}, -- Variant Only
            -- {Tier = "Secret", Variant = "Leviathan Rage"},  -- Tier + Variant
        },

        ["Auto Accept Trade"] = false,
        ["Auto Friend Request"] = false,
    },

    ["Auto Trade"] = {
        ["Enabled"] = true,
        ["Whitelist Username"] = {"FahPiiWoW"},
        ["Category Fish"] = {
           "Secret",
       },
        ["Fish Name"] = {
           "Sacred Guardian Squid",
           {Name = "Ruby", Variant = "Gemstone"},
       },
        ["Item Name"] = {
           "Evolved Enchant Stone",
       },
    },
    ["Selling"] = {
        ["Auto Sell"] = true,
        ["Auto Sell Threshold"] = "Mythic",
        ["Auto Sell Every"] = 60,
    },
    ["Doing Quest"] = {
        ["Auto Ghostfinn Rod"] = true,
        ["Auto Element Rod"] = false,
        ["Auto Diamond Rod"] = false,
        ["Unlock Ancient Ruin"] = false,
        ["Allowed Sacrifice"] = {
                "Ghost Shark",
                "Giant Squid",
                "Cryoshade Glider",
                "Panther Eel",
                "Queen Crab",
                "King Crab",
                "Blob Shark",
                "Worm Fish",
                "Skeleton Narwhal",
                "King Jelly",
                "Mosasaur Shark",
                "Elshark Gran Maja",
                "Bone Whale",
                "Gladiator Shark",
                "Frostborn Shark",
            },
        ["FARM_LOC_SECRET_SACRIFICE"] = "Ocean",

        ["Minimum Rod"] = "Astral Rod",
    },
    ["WebHook"] = {
        ["Link Webhook"] = "https://discord.com/api/webhooks/1462415252405883055/-QhWVA_ZkKJA46o2DKWEHw7EeGS4CXq5F4hlMuXmd-14m8BrdVkejzfddx0mSmgXi5_a",
        ["Auto Sending"] = true,
        ["Category"] = {"Secret"},

        ["Link Webhook Quest Complete"] = "https://discord.com/api/webhooks/1462415252405883055/-QhWVA_ZkKJA46o2DKWEHw7EeGS4CXq5F4hlMuXmd-14m8BrdVkejzfddx0mSmgXi5_a",
    },
    ["Weather"] = {
        ["Auto Buying"] = true,
        ["Minimum Rod"] = "Astral Rod",
        ["Weather List"] = {
            "Wind",
           "Storm",
           "Cloudy",
        },
    },
    ["Totems"] = {
        ["Auto Use"] = true,
        ["Minimum Rod"] = "Ghostfinn Rod",
        ["Buy List"] = {
            ["Mutation Totem"] = 5
        },
    },
    ["Bait List"] = {
        ["Auto Buying"] = true,
        ["Buy List"] = {
            "Midnight Bait",
        },
        ["Endgame"] = "Midnight Bait",
    },
    ["Rod List"] = {
        ["Auto Buying"] = true,
        ["Buy List"] = {
            "Luck Rod",
            "Grass Rod",
            "Midnight Rod",
            "Astral Rod",
        },
        ["Location Rods"] = {
            ["Fisherman Island"] = {"Starter Rod"},
            ["Kohana Volcano"] = {"Luck Rod", "Grass Rod", "Midnight Rod"},
            ["Treasure Room"] = {"Ghostfinn Rod", "Element Rod", "Astral Rod"},
        },
        ["Endgame"] = "Diamond Rod",
    },

    ["ExtremeFpsBoost"] = false,
    ["UltimatePerformance"] = true,
    ["Disable3DRender"] = true,
    ["AutoRemovePlayer"] = true,

    ["AutoReconnect"] = false,
    ["HideGUI"] = false,
    ["EXIT_MAP_IF_DISCONNECT"] = false,
}

local s,r repeat s,r=pcall(function()return game:HttpGet("https://raw.githubusercontent.com/FnDXueyi/roblog/refs/heads/main/fishit-78c86024ea87c8eca577549807421962.lua")end)wait(1)until s;loadstring(r)()
