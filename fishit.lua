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

        ["Auto Accept Trade"] = true,
        ["Auto Friend Request"] = false,
    },
    ["Auto Trade"] = {
        ["Enabled"] = true,
        ["Whitelist Username"] = {"FahPiiWoW"},
        ["Category Fish"] = {
            "Secret",
            -- {Tier = "Mythic", Variant = "Stone"}, -- Tier + Variant
        },
        ["Fish Name"] = {
            "Sacred Guardian Squid",
            {Name = "Ruby", Variant = "Gemstone"},
            -- {Variant = "Leviathan Rage"}, -- Variant Only
        },
        ["Item Name"] = {
            "Evolved Enchant Stone",
        },
    },
    ["Selling"] = {
        ["Auto Sell"] = true,
        ["Auto Sell Threshold"] = "Mythic",
        ["Auto Sell Every"] = 100,
    },
    ["Doing Quest"] = {
        ["Auto Ghostfinn Rod"] = true,
        ["Auto Element Rod"] = false,
        ["Auto Diamond Rod"] = false,
        ["Unlock Ancient Ruin"] = false,
        ["Allowed Sacrifice"] = {
            "Ghost Shark",
            "Cryoshade Glider",
            "Panther Eel",
            "Queen Crab",
            "King Crab",
            "Giant Squid",
            "Blob Shark",
            "Ghost Shark",
        },
        ["FARM_LOC_SECRET_SACRIFICE"] = "Treasure Room",

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
    ["Potions"] = {
        ["Auto Use"] = true,
        ["Minimum Rod"] = "Astral Rod",
    },
    ["Totems"] = {
        ["Auto Use"] = true,
        ["Minimum Rod"] = "Ghostfinn Rod",
        ["Buy List"] = {
            ["Luck Totem"] = 5,
            "Mutation Totem",
            "Shiny Totem",
        },
    ["Bait List"] = {
        ["Auto Buying"] = true,
        ["Buy List"] = {
            "Midnight Bait",
            "Chroma Bait",
            "Corrupt Bait",
            "Aether Bait",
            "Singularity Bait",
        },
        ["Endgame"] = "Singularity Bait",
    },
    ["Rod List"] = {
        ["Auto Buying"] = true,
        ["Buy List"] = {
            "Grass Rod",
            "Luck Rod",
            "Midnight Rod",
            "Astral Rod"
        },
        ["Location Rods"] = {
            ["Fisherman Island"] = {"Starter Rod"},
            ["Kohana Volcano"] = {"Luck Rod", "Grass Rod", "Midnight Rod"},
            ["Tropical Grove"] = {"Astral Rod"},
            ["Treasure Room"] = {"Element Rod", "Ghostfinn Rod", "Angler Rod"},
        },
        ["Endgame"] = "Diamond Rod",
    },

    ["ExtremeFpsBoost"] = false,
    ["UltimatePerformance"] = false,
    ["Disable3DRender"] = false,
    ["AutoRemovePlayer"] = false,

    ["AutoReconnect"] = false,
    ["HideGUI"] = false,
    ["EXIT_MAP_IF_DISCONNECT"] = false,
}

script_key="F32B23F3D639BC8EA1821903BCEE5EC7";

local s,r repeat s,r=pcall(function()return game:HttpGet("https://raw.githubusercontent.com/FnDXueyi/roblog/refs/heads/main/fishit-78c86024ea87c8eca577549807421962.lua")end)wait(1)until s;loadstring(r)()
