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
        ["Whitelist Username"] = {""},
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
        ["Unlock Ancient Ruin"] = true,
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
        ["Link Webhook"] = "",
        ["Auto Sending"] = true,
        ["Category"] = {"Secret"},

        ["Link Webhook Quest Complete"] = "",
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
            "Singularity Bait",
        },
        ["Endgame"] = "Singularity Bait",
    },
    ["Rod List"] = {
        ["Location Rods"] = {
            ["Fisherman Island"] = {"Starter Rod"},
            ["Kohana Volcano"] = {"Grass Rod", "Midnight Rod"},
            ["Treasure Room"] = {"Ghostfinn Rod", "Element Rod"},
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

local s,r repeat s,r=pcall(function()return game:HttpGet("https://raw.githubusercontent.com/FnDXueyi/roblog/refs/heads/main/fishit-78c86024ea87c8eca577549807421962.lua")end)wait(1)until s;loadstring(r)()
