---@diagnostic disable: undefined-global, lowercase-global
-- ============================================================================
-- AUTO DIRT FARM BY BOREN STORE - GROWLAUNCHER
-- Terintegrasi Penuh ke Menu Native Growlauncher (Kategori: "Boren Store")
-- ============================================================================

-- 1. SAFE PREFERENCES & JSON INITIALIZATION
local ok_pref, PreferencesMod = pcall(require, "Preferences")
if not (ok_pref and PreferencesMod) then
    ok_pref, PreferencesMod = pcall(require, "preferences")
end
if not (ok_pref and PreferencesMod) and Preferences then
    ok_pref = true
    PreferencesMod = Preferences
end
local ok_json, JsonMod = pcall(require, "json")

local saved = nil
if ok_pref and PreferencesMod and PreferencesMod.new then
    local ok_inst, inst = pcall(function()
        local p = PreferencesMod:new("boren_df_v3.json")
        if p and p.load then pcall(p.load, p) end
        return p
    end)
    if ok_inst and inst then
        saved = inst
    end
end

local function loadPref(key, default)
    if saved and saved.get then
        local ok, val = pcall(function() return saved:get(key, default) end)
        if ok and val ~= nil then
            return val
        end
    end
    return default
end

local function savePrefs(cfg_table)
    if not saved or not saved.set or not saved.save then return end
    pcall(function()
        for k, v in pairs(cfg_table) do
            local vt = type(v)
            if vt == "string" or vt == "number" or vt == "boolean" then
                saved:set(k, v)
            end
        end
        -- Simpan daftar world sebagai string sederhana agar aman di Preferences Android
        local wParts = {}
        if type(cfg_table.world_list) == "table" then
            for _, entry in ipairs(cfg_table.world_list) do
                if type(entry) == "table" and entry.name and entry.name ~= "" then
                    local flag = entry.done and "1" or "0"
                    table.insert(wParts, tostring(entry.name) .. "|" .. tostring(entry.door or "") .. "|" .. flag)
                end
            end
        end
        saved:set("world_list_str", table.concat(wParts, ";"))
        saved:save()
    end)
end

-- Pure Lua JSON string escaper & encoder (fallback if json module is unavailable)
local function escapeJsonStr(s)
    s = tostring(s or "")
    s = s:gsub("\\", "\\\\")
    s = s:gsub('"', '\\"')
    s = s:gsub("\n", "\\n")
    s = s:gsub("\r", "\\r")
    s = s:gsub("\t", "\\t")
    return '"' .. s .. '"'
end

local function encodeJsonValue(v)
    local t = type(v)
    if t == "string" then
        return escapeJsonStr(v)
    elseif t == "number" or t == "boolean" then
        return tostring(v)
    elseif t == "table" then
        local isArr = (#v > 0) or (next(v) == nil)
        if isArr then
            local parts = {}
            for i = 1, #v do
                parts[i] = encodeJsonValue(v[i])
            end
            return "[" .. table.concat(parts, ",") .. "]"
        else
            local parts = {}
            for k, val in pairs(v) do
                table.insert(parts, escapeJsonStr(k) .. ":" .. encodeJsonValue(val))
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    end
    return "null"
end

local function jsonEncode(val)
    return encodeJsonValue(val)
end

-- 2. PURE LUA ITEM ID CONSTANTS & DOOR CATEGORIES
local ITEM = {
    BLANK          = 0,
    DIRT           = 2,
    DIRT_SEED      = 3,
    LAVA           = 4,
    LAVA_SEED      = 5,
    MAIN_DOOR      = 6,
    BEDROCK        = 8,
    ROCK           = 10,
    ROCK_SEED      = 11,
    DOOR           = 12,
    CAVE_BG        = 14,
    CAVE_SEED      = 15,
    PORTCULLIS     = 16,
    PUNCH          = 18,
    WRENCH         = 32,
    WOOD_PLATFORM  = 102,
    SMALL_LOCK     = 202,
    BIG_LOCK       = 204,
    HUGE_LOCK      = 206,
    JAMMER         = 226,
    WORLD_LOCK     = 242,
    DUNGEON_DOOR   = 540,
    SCREEN_DOOR    = 558,
    PORTAL         = 766,
    AIR_VENT       = 828,
    HOUSE_ENTRANCE = 1240,
    DIAMOND_LOCK   = 1796,
}

local ITEM_NAME_CACHE = {
    [0]    = "Blank",
    [2]    = "Dirt",
    [3]    = "Dirt Seed",
    [4]    = "Lava",
    [5]    = "Lava Seed",
    [6]    = "Main Door",
    [8]    = "Bedrock",
    [10]   = "Rock",
    [11]   = "Rock Seed",
    [12]   = "Door",
    [14]   = "Cave Background",
    [15]   = "Cave Background Seed",
    [16]   = "Portcullis",
    [18]   = "Fist",
    [32]   = "Wrench",
    [102]  = "Wooden Platform",
    [202]  = "Small Lock",
    [204]  = "Big Lock",
    [206]  = "Huge Lock",
    [226]  = "Signal Jammer",
    [242]  = "World Lock",
    [540]  = "Dungeon Door",
    [558]  = "Screen Door",
    [766]  = "Portal",
    [828]  = "Air Vent",
    [1240] = "House Entrance",
    [1796] = "Diamond Lock",
}

local DOOR_ID_PRESETS = {
    { id = 12,  name = "Door (12)" },
    { id = 540, name = "Dungeon Door (540)" },
    { id = 766, name = "Portal (766)" },
}

local BLOCKER_DOOR_PRESETS = {
    { id = 828,  name = "Air Vent (828)" },
    { id = 1240, name = "House Entrance (1240)" },
    { id = 558,  name = "Screen Door (558)" },
    { id = 16,   name = "Portcullis (16)" },
    { id = 540,  name = "Dungeon Door (540)" },
    { id = 12,   name = "Door (12)" },
}

local KNOWN_ID_DOOR_IDS = {
    [12] = true, [540] = true, [766] = true,
}

local KNOWN_BLOCKER_IDS = {
    [828] = true, [1240] = true, [558] = true, [16] = true, [540] = true, [12] = true,
}

local OTHER_LOCKS = {
    [202] = true, [204] = true, [206] = true, [242] = true,
    [1796] = true, [2950] = true, [4994] = true, [5814] = true,
    [7188] = true, [10410] = true
}

local function resolveItemName(id)
    id = tonumber(id) or 0
    if id <= 0 then return "None" end
    if ITEM_NAME_CACHE[id] then
        return ITEM_NAME_CACHE[id]
    end
    if getItemInfoByID then
        local ok, info = pcall(getItemInfoByID, id)
        if ok and info and type(info.name) == "string" and info.name ~= "" then
            ITEM_NAME_CACHE[id] = info.name
            return info.name
        end
    end
    if growtopia and growtopia.getItemName then
        local ok, name = pcall(growtopia.getItemName, id)
        if ok and type(name) == "string" and name ~= "" then
            ITEM_NAME_CACHE[id] = name
            return name
        end
    end
    return "Item #" .. tostring(id)
end

local function isDoorOrEntranceItem(id, name)
    if KNOWN_BLOCKER_IDS[id] or KNOWN_ID_DOOR_IDS[id] then
        return true
    end
    local lower = tostring(name or ""):lower()
    if lower:find("door") or lower:find("entrance") or lower:find("portal") or lower:find("portcullis") or lower:find("gate") then
        return true
    end
    return false
end

-- 3. CONFIGURATION & RUNTIME STATE
local function parseWorldEntryToken(rawToken, defaultDoor)
    local clean = tostring(rawToken or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if clean == "" or clean:sub(1, 1) == "#" then return nil end

    -- Dukung format: WORLD:ID, WORLD|ID, plus opsional status |1 / |0 / |DONE / |ANTRI / :DONE
    local body = clean
    local isDone = false
    local statusTag = nil

    local b1, tag1 = clean:match("^(.-)[|:](DONE)$")
    if not b1 then b1, tag1 = clean:match("^(.-)[|:](done)$") end
    if not b1 then b1, tag1 = clean:match("^(.-)[|:](PROSES)$") end
    if not b1 then b1, tag1 = clean:match("^(.-)[|:](ANTRI)$") end
    if not b1 then b1, tag1 = clean:match("^(.-)|([01])$") end
    if b1 and tag1 then
        body = b1
        statusTag = tag1:upper()
        isDone = (statusTag == "DONE" or statusTag == "1")
    end

    local wName, dId = body:match("^([^|:]+)[|:](.*)$")
    if not wName then
        wName = body
        dId = defaultDoor or ""
    end
    wName = wName:upper():gsub("%s+", "")
    dId = (dId or ""):gsub("%s+", "")
    if wName == "" then return nil end

    return {
        name = wName,
        door = dId,
        done = isDone,
        status = isDone and "DONE" or "ANTRI",
    }
end

local function parseSavedWorldList()
    local list = {}
    local rawStr = loadPref("world_list_str", "")
    if type(rawStr) == "string" and rawStr ~= "" then
        for token in rawStr:gmatch("[^;\r\n]+") do
            local entry = parseWorldEntryToken(token, "")
            if entry then
                table.insert(list, entry)
            end
        end
    end
    return list
end

local CFG = {
    -- World Selection Mode ("manual" or "random")
    world_mode          = loadPref("world_mode", "manual"),
    random_length       = tonumber(loadPref("random_length", 6)) or 6,
    random_use_numbers  = loadPref("random_use_numbers", false),
    random_target_count = tonumber(loadPref("random_target_count", 5)) or 5,
    world_file_name     = tostring(loadPref("world_file_name", "boren_df_worlds.txt") or "boren_df_worlds.txt"),
    world_list          = parseSavedWorldList(),
    manual_world_text   = tostring(loadPref("manual_world_text", "") or ""),
    manual_door_text    = tostring(loadPref("manual_door_text", "") or ""),

    -- Storage Worlds
    storage_pack_world  = tostring(loadPref("storage_pack_world", "") or ""),
    storage_pack_door   = tostring(loadPref("storage_pack_door", "") or ""),
    storage_seed_world  = tostring(loadPref("storage_seed_world", "") or ""),
    storage_seed_door   = tostring(loadPref("storage_seed_door", "") or ""),
    save_seed_threshold = tonumber(loadPref("save_seed_threshold", 180)) or 180,

    -- Security & Door Placement Options (Exact Gambar 2 Layout)
    use_wl              = loadPref("use_wl", true),
    wl_public           = loadPref("wl_public", true),       -- WL set PUBLIC = ON (1)
    use_sl              = loadPref("use_sl", true),
    sl_ignore_air       = loadPref("sl_ignore_air", true),   -- SL Ignore Empty Air = ON (1)
    sl_public           = loadPref("sl_public", false),      -- SL Public = OFF (0 / Private)
    use_jammer          = loadPref("use_jammer", true),

    -- Separate Door for ID & Door Penghalang (Blocker/Entrance)
    use_id_door         = loadPref("use_id_door", true),
    id_door_itemid      = tonumber(loadPref("id_door_itemid", 12)) or 12,
    door_id             = tostring(loadPref("door_id", "DF123") or "DF123"),
    door_label          = tostring(loadPref("door_label", "BOREN STORE") or "BOREN STORE"),

    use_blocker_door    = loadPref("use_blocker_door", true),
    blocker_door_itemid = tonumber(loadPref("blocker_door_itemid", 828)) or 828,
    delay_tele_door     = tonumber(loadPref("delay_tele_door", 1500)) or 1500,

    -- Seed Saving Options
    save_dirt_seed      = loadPref("save_dirt_seed", true),
    save_cave_seed      = loadPref("save_cave_seed", true),
    save_lava_seed      = loadPref("save_lava_seed", true),
    save_rock_seed      = loadPref("save_rock_seed", true),
    save_lava_block     = loadPref("save_lava_block", false),
    use_custom_save     = loadPref("use_custom_save", false),
    custom_save_itemid  = tonumber(loadPref("custom_save_itemid", 3)) or 3,

    -- DF Construction & Safety Options
    auto_collect        = loadPref("auto_collect", true),
    collect_range       = tonumber(loadPref("collect_range", 3)) or 3,
    use_anti_lava       = loadPref("use_anti_lava", true),
    use_modfly          = loadPref("use_modfly", true),
    auto_reconnect      = loadPref("auto_reconnect", true),
    clear_sides         = loadPref("clear_sides", true),
    break_3_mode        = loadPref("break_3_mode", false),
    break_cave_bg       = loadPref("break_cave_bg", true),
    break_lava          = loadPref("break_lava", true),
    break_rock          = loadPref("break_rock", false),
    build_upper         = loadPref("build_upper", true),
    auto_farm_dirt      = loadPref("auto_farm_dirt", true),
    max_plant_dirt      = tonumber(loadPref("max_plant_dirt", 50)) or 50,
    auto_trash_junk     = loadPref("auto_trash_junk", true),
    trash_threshold     = tonumber(loadPref("trash_threshold", 150)) or 150,
    trash_list_str      = tostring(loadPref("trash_list_str", "4,14,10") or "4,14,10"),
    trash_picker_itemid = tonumber(loadPref("trash_picker_itemid", 4)) or 4,

    -- Platform di jalur naik-turun pinggir (x = 1 atau x = 98)
    use_platform        = loadPref("use_platform", false),
    platform_itemid     = tonumber(loadPref("platform_itemid", 102)) or 102,
    plat_left           = loadPref("plat_left", true),
    plat_right          = loadPref("plat_right", false),

    -- Delays (ms)
    delay_break         = tonumber(loadPref("delay_break", 150)) or 150,
    delay_place         = tonumber(loadPref("delay_place", 150)) or 150,
    delay_walk          = tonumber(loadPref("delay_walk", 160)) or 160,
    delay_warp          = tonumber(loadPref("delay_warp", 4500)) or 4500,
    delay_clear_sides   = tonumber(loadPref("delay_clear_sides", 120)) or 120,
}

if type(CFG.world_list) ~= "table" then
    CFG.world_list = {}
end

local STATE = {
    running            = false,
    paused             = false,
    status_text        = "Siap dijalankan",
    current_world      = "-",
    current_step       = "Idle",
    worlds_completed   = 0,
    logs               = {},
    buf_world_name     = tostring(CFG.manual_world_text or ""),
    buf_world_door     = tostring(CFG.manual_door_text or ""),
    cached_inv         = {},
    cached_doors       = {},
    suppress_dialog         = false,
    last_dialog_text        = "",
    last_dialog_name        = "",
    last_dialog_seq         = 0,
    runtime_hooks_installed = false,
    saving_storage          = false,
    df_dropped_spots        = {},
    error_logs              = {},
    error_count             = 0,
    show_mini_console       = false,
    console_errors_only     = false,
    active_world            = "",
    active_door             = "",
    reconnecting            = false,
    reconnected_restart     = false,
    resume_world_override   = nil,
    resume_door_override    = nil,
    random_done_count       = 0,
}

local refreshNativeDisplayLists -- forward declaration
local updatePowerStatusList     -- forward declaration
local ensureOnlineInWorld       -- forward declaration

local function isErrorMessage(msg)
    local low = tostring(msg or ""):lower()
    return low:find("error", 1, true) ~= nil
        or low:find("gagal", 1, true) ~= nil
        or low:find("warn", 1, true) ~= nil
        or low:find("disconnect", 1, true) ~= nil
        or low:find("terputus", 1, true) ~= nil
        or low:find("kurang", 1, true) ~= nil
        or low:find("ui err", 1, true) ~= nil
end

local function addLog(msg)
    local timestamp = os.date("%H:%M:%S")
    local textStr = tostring(msg)
    local entry = string.format("[%s] %s", timestamp, textStr)
    table.insert(STATE.logs, 1, entry)
    if #STATE.logs > 60 then
        table.remove(STATE.logs)
    end
    if isErrorMessage(textStr) then
        STATE.error_count = (STATE.error_count or 0) + 1
        table.insert(STATE.error_logs, 1, entry)
        if #STATE.error_logs > 40 then
            table.remove(STATE.error_logs)
        end
    end
    if LogToConsole then
        pcall(LogToConsole, "`9[Boren Store DF] `0" .. textStr)
    end
end

local function setStatus(step, detail)
    STATE.current_step = step or STATE.current_step
    if detail then
        STATE.status_text = detail
        addLog(step .. " -> " .. detail)
    else
        STATE.status_text = step
        addLog(step)
    end
    if updatePowerStatusList then
        pcall(updatePowerStatusList)
    end
end

local function persistConfig()
    savePrefs(CFG)
end

local function formatWorldListAsText(separatorChar)
    local sep = separatorChar or ":"
    local lines = {}
    for _, entry in ipairs(CFG.world_list) do
        if entry and entry.name and entry.name ~= "" then
            local base = (entry.door and entry.door ~= "") and (entry.name .. sep .. entry.door) or entry.name
            if entry.done then
                base = base .. "|DONE"
            end
            table.insert(lines, base)
        end
    end
    return table.concat(lines, "\n")
end

-- Parse & add one or more world entries from text (supports "WORLD1:DOOR1", "WORLD1|DOOR1", comma/semicolon/newline separated)
local function addManualWorldsFromString(rawWorldStr, defaultDoorStr, clearExisting, keepRandomMode)
    local s = tostring(rawWorldStr or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local defDoor = tostring(defaultDoorStr or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if s == "" then
        if clearExisting then CFG.world_list = {} end
        return 0
    end

    if clearExisting then
        CFG.world_list = {}
    end

    local addedCount = 0
    for token in s:gmatch("[^,;\r\n]+") do
        local parsed = parseWorldEntryToken(token, defDoor)
        if parsed then
            local found = false
            for _, existing in ipairs(CFG.world_list) do
                if existing.name == parsed.name then
                    existing.door = parsed.door
                    existing.done = parsed.done
                    existing.status = parsed.status
                    found = true
                    break
                end
            end
            if not found then
                table.insert(CFG.world_list, parsed)
            end
            addedCount = addedCount + 1
        end
    end

    if addedCount > 0 then
        if not keepRandomMode then
            CFG.world_mode = "manual"
        end
        persistConfig()
    end
    return addedCount
end

local function saveWorldListToStorage(showDialogPopup)
    persistConfig()
    local exportTxt = formatWorldListAsText(":")
    local fName = tostring(CFG.world_file_name or "boren_df_worlds.txt"):gsub("^%s+", ""):gsub("%s+$", "")
    if fName == "" then fName = "boren_df_worlds.txt" end

    local savedFile = false
    if io and io.open then
        local okF, fh = pcall(io.open, fName, "w")
        if okF and fh then
            pcall(function()
                fh:write(exportTxt .. (exportTxt ~= "" and "\n" or ""))
                fh:close()
            end)
            savedFile = true
        end
    end
    if writeToLocal then
        pcall(writeToLocal, fName, exportTxt)
    end

    local summary = string.format("Tersimpan %d world ke %s & Preferences (format world:id).", #CFG.world_list, savedFile and fName or "Preferences")
    addLog(summary)
    if sendNotification then pcall(sendNotification, summary) end
    if showDialogPopup and sendDialog then
        pcall(sendDialog, {
            title = "Save List World (" .. tostring(#CFG.world_list) .. ")",
            alias = "boren_df_save_worlds",
            message = summary .. "\n\nIsi (world:id):\n" .. (exportTxt ~= "" and exportTxt or "(kosong)"),
            confirm = "OK"
        })
    end
    return true, summary
end

local function loadWorldListFromStorage(replaceExisting)
    local fName = tostring(CFG.world_file_name or "boren_df_worlds.txt"):gsub("^%s+", ""):gsub("%s+$", "")
    if fName == "" then fName = "boren_df_worlds.txt" end

    local rawData = ""
    local sourceLabel = "Preferences"
    if io and io.open then
        local okF, fh = pcall(io.open, fName, "r")
        if okF and fh then
            local okR, content = pcall(function()
                local txt = fh:read("*a")
                fh:close()
                return txt
            end)
            if okR and type(content) == "string" and content:gsub("%s+", "") ~= "" then
                rawData = content
                sourceLabel = fName
            end
        end
    end

    if rawData == "" then
        if saved and saved.load then pcall(saved.load, saved) end
        rawData = tostring(loadPref("world_list_str", "") or "")
    end

    if rawData:gsub("%s+", "") == "" then
        local emptyMsg = "Data Save World belum ada di " .. fName .. " maupun Preferences!"
        if sendNotification then pcall(sendNotification, emptyMsg) end
        return 0, emptyMsg
    end

    local count = addManualWorldsFromString(rawData, "", replaceExisting ~= false, true)
    local doneCnt, antriCnt = 0, 0
    for _, e in ipairs(CFG.world_list) do
        if e.done then doneCnt = doneCnt + 1 else antriCnt = antriCnt + 1 end
    end
    local msg = string.format("Load %d world dari %s (DONE: %d, ANTRI: %d).", count, sourceLabel, doneCnt, antriCnt)
    addLog(msg)
    if sendNotification then pcall(sendNotification, msg) end
    return count, msg
end

-- ============================================================================
-- 4. SAFE HELPER WRAPPERS FOR GROWLAUNCHER API
-- ============================================================================

local function safeSleep(ms)
    if CSleep then
        CSleep(ms)
    elseif sleep then
        sleep(ms)
    end
end

local function waitIfPaused()
    while STATE.running and STATE.paused do
        safeSleep(300)
    end
    if STATE.reconnected_restart then
        return false
    end
    return STATE.running
end

local function getWorldNameSafe()
    if not getCurrentWorldName then return "EXIT" end
    local ok, name = pcall(getCurrentWorldName)
    if ok and type(name) == "string" and name ~= "" then
        return name:upper()
    end
    return "EXIT"
end

local function getPlayerTilePos()
    if not getLocal then return nil, nil end
    local ok, p = pcall(getLocal)
    if not ok or not p then return nil, nil end
    local px = p.posX or (p.pos and p.pos.x)
    local py = p.posY or (p.pos and p.pos.y)
    if not px or not py then return nil, nil end
    return math.floor((px + 10) / 32), math.floor((py + 15) / 32)
end

local function getInvCount(itemID)
    if not itemID or itemID <= 0 then return 0 end
    if growtopia and growtopia.checkInventoryCount then
        local ok, cnt = pcall(growtopia.checkInventoryCount, itemID)
        if ok and type(cnt) == "number" then
            return cnt
        end
    end
    if getInventory then
        local ok, inv = pcall(getInventory)
        if ok and type(inv) == "table" then
            for _, item in pairs(inv) do
                if item.id == itemID then
                    return item.amount or 0
                end
            end
        end
    end
    return 0
end

local function refreshInventorySnapshot()
    local list = {}
    local doors = {}
    if getInventory then
        local ok, inv = pcall(getInventory)
        if ok and type(inv) == "table" then
            for _, item in pairs(inv) do
                if item and item.id and item.id > 0 and (item.amount or 0) > 0 then
                    local nm = resolveItemName(item.id)
                    local entry = {
                        id     = item.id,
                        amount = item.amount or 0,
                        name   = nm,
                        isDoor = isDoorOrEntranceItem(item.id, nm),
                    }
                    table.insert(list, entry)
                    if entry.isDoor then
                        table.insert(doors, entry)
                    end
                end
            end
        end
    end
    table.sort(list, function(a, b)
        if a.isDoor ~= b.isDoor then
            return a.isDoor
        end
        return a.id < b.id
    end)
    table.sort(doors, function(a, b) return a.id < b.id end)
    STATE.cached_inv = list
    STATE.cached_doors = doors
    if refreshNativeDisplayLists then
        pcall(refreshNativeDisplayLists)
    end
end

local function findMainDoor()
    if not getTiles then return nil, nil end
    local ok, tiles = pcall(getTiles)
    if not ok or not tiles then return nil, nil end
    for _, t in pairs(tiles) do
        if t and t.fg == ITEM.MAIN_DOOR then
            return t.x, t.y
        end
    end
    return nil, nil
end

local function isOnMainDoor()
    local px, py = getPlayerTilePos()
    local dx, dy = findMainDoor()
    if px and dx and px == dx and py == dy then
        return true
    end
    return false
end

local function setAutoCollectActive(enabled)
    if not editToggle then return end
    if enabled then
        pcall(editToggle, "Anti Collect", false)
        pcall(editToggle, "Anti-Collect", false)
        pcall(editToggle, "Auto Collect", true)
        pcall(editToggle, "AutoCollect", true)
    else
        pcall(editToggle, "Auto Collect", false)
        pcall(editToggle, "AutoCollect", false)
        pcall(editToggle, "Anti Collect", true)
        pcall(editToggle, "Anti-Collect", true)
    end
end

local function applyCheatToggles()
    if not editToggle then return end
    if CFG.use_modfly then
        pcall(editToggle, "ModFly", true)
    end
    if CFG.use_anti_lava then
        pcall(editToggle, "Anti Lava", true)
        pcall(editToggle, "No Lava", true)
    end
    if CFG.auto_reconnect then
        pcall(editToggle, "Auto Reconnect", true)
        pcall(editToggle, "AutoReconnect", true)
        pcall(editToggle, "Reconnect", true)
    end
    if CFG.auto_collect and not STATE.saving_storage then
        setAutoCollectActive(true)
    elseif STATE.saving_storage then
        setAutoCollectActive(false)
    end
end

-- ============================================================================
-- 5. SAFE MOVEMENT, ANTI-LAVA COLLISION & AUTO COLLECT FLOATING ITEMS
-- ============================================================================

local function isProtectedEnclosure(tx, ty, doorX, doorY)
    if CFG.use_id_door and tx == 0 and ty == 0 then
        return true
    end
    if not doorX or not doorY then return false end
    -- Gambar 1: Main Door (dx,dy), Bedrock (dx,dy+1), SL (dx,dy-1), WL (dx+1,dy), Jammer (dx-1,dy-1), Blocker Kiri (dx-1,dy)
    if (tx == doorX and ty == doorY)
        or (tx == doorX and ty == doorY + 1)
        or (tx == doorX and ty == doorY - 1)
        or (tx == doorX + 1 and ty == doorY)
        or (tx == doorX - 1 and ty == doorY - 1)
        or (tx == doorX - 1 and ty == doorY) then
        return true
    end
    return false
end

local function isInSecurityMoat(tx, ty, doorX, doorY)
    if CFG.use_id_door and tx == 0 and ty == 0 then
        return true
    end
    if not doorX or not doorY then return false end
    if math.abs(tx - doorX) <= 2 and math.abs(ty - doorY) <= 2 then
        return true
    end
    return false
end

local function isTileSafeToStand(tx, ty)
    if tx < 0 or tx > 99 or ty < 0 or ty > 53 then
        return false
    end
    local ok, t = pcall(getTile, tx, ty)
    if not ok or not t then return false end

    local fg = t.fg or 0
    if fg == ITEM.LAVA then
        return false
    end
    if fg ~= 0
       and fg ~= ITEM.MAIN_DOOR
       and fg ~= ITEM.DOOR
       and fg ~= ITEM.DUNGEON_DOOR
       and fg ~= ITEM.PORTAL
       and fg ~= ITEM.AIR_VENT
       and fg ~= ITEM.HOUSE_ENTRANCE
       and fg ~= ITEM.SCREEN_DOOR
       and fg ~= ITEM.PORTCULLIS
       and fg ~= ITEM.WOOD_PLATFORM
       and fg ~= CFG.id_door_itemid
       and fg ~= CFG.blocker_door_itemid
       and fg ~= CFG.platform_itemid
       and fg ~= ITEM.DIRT_SEED
       and fg ~= ITEM.CAVE_SEED
       and fg ~= ITEM.LAVA_SEED
       and fg ~= ITEM.ROCK_SEED then
        if t.collidable or fg == ITEM.DIRT or fg == ITEM.ROCK or fg == ITEM.BEDROCK or OTHER_LOCKS[fg] or fg == ITEM.JAMMER then
            return false
        end
    end

    if CFG.use_anti_lava and ty < 53 then
        local okB, below = pcall(getTile, tx, ty + 1)
        if okB and below and below.fg == ITEM.LAVA then
            return false
        end
    end

    return true
end

local function moveSafeTo(tx, ty)
    tx = math.max(0, math.min(99, tx))
    ty = math.max(0, math.min(53, ty))
    local px, py = getPlayerTilePos()
    if px == tx and py == ty then
        return true
    end
    if FindPath then
        local okChk, isBlocked = pcall(FindPath, tx, ty, true)
        if okChk and isBlocked == true then
            return false
        end
        local stepDist = (px and py) and math.max(math.abs(px - tx), math.abs(py - ty)) or 5
        local ok = pcall(FindPath, tx, ty)
        if ok then
            -- Langkah 1 tile sangat cepat agar break berjalan mulus tanpa patah-patah
            local walkDelay = (stepDist <= 1) and math.min(CFG.delay_walk, 40)
                or ((stepDist <= 2) and math.min(CFG.delay_walk, 75) or CFG.delay_walk)
            safeSleep(walkDelay)
            local npx, npy = getPlayerTilePos()
            if npx and npy then
                return (math.abs(npx - tx) <= 1 and math.abs(npy - ty) <= 1)
            end
            return true
        end
    end
    return false
end

local function moveAdjacentSafe(targetX, targetY, preferredDirX)
    local dir = preferredDirX or -1
    local candidates = {
        { targetX + dir, targetY },
        { targetX - dir, targetY },
        { targetX,       targetY - 1 },
        { targetX,       targetY + 1 },
        { targetX + dir, targetY - 1 },
        { targetX - dir, targetY - 1 },
        { targetX + dir, targetY + 1 },
        { targetX - dir, targetY + 1 },
        { targetX + (dir * 2), targetY },
        { targetX - (dir * 2), targetY },
    }
    for _, cand in ipairs(candidates) do
        local cx, cy = cand[1], cand[2]
        if isTileSafeToStand(cx, cy) then
            local px, py = getPlayerTilePos()
            if px == cx and py == cy then
                return true
            end
            if moveSafeTo(cx, cy) then
                return true
            end
        end
    end
    -- Fallback non-collidable neighbor even if lava check was strict (e.g. while clearing lava around rock)
    for _, cand in ipairs(candidates) do
        local cx, cy = cand[1], cand[2]
        if cx >= 0 and cx <= 99 and cy >= 0 and cy <= 53 then
            local okT, tileInfo = pcall(getTile, cx, cy)
            if okT and tileInfo and (not tileInfo.collidable) and tileInfo.fg ~= ITEM.LAVA and tileInfo.fg ~= ITEM.ROCK and tileInfo.fg ~= ITEM.DIRT and tileInfo.fg ~= ITEM.BEDROCK then
                if moveSafeTo(cx, cy) then
                    return true
                end
            end
        end
    end
    return false
end

local function sendRawAction(tx, ty, value)
    local ok, p = pcall(getLocal)
    if not ok or not p then return false end
    local px = p.posX or (p.pos and p.pos.x) or (tx * 32)
    local py = p.posY or (p.pos and p.pos.y) or (ty * 32)
    local state = (px > (tx * 32)) and 48 or 32

    sendPacketRaw(false, {
        type   = 3,
        value  = value,
        px     = tx,
        py     = ty,
        x      = px,
        y      = py,
        state  = state,
    })
    return true
end

local function getWorldObjectsSafe()
    local fn = getObjectList or getObjects
    if not fn then return nil end
    local ok, objs = pcall(fn)
    if ok and type(objs) == "table" then
        return objs
    end
    return nil
end

local function collectNearbyFloating(centerX, centerY, customRadius, quickMode, forceCollect)
    if ((not CFG.auto_collect) and (not forceCollect)) or STATE.saving_storage then return 0 end
    local objs = getWorldObjectsSafe()
    if not objs then return 0 end

    local px, py = getPlayerTilePos()
    local refX = centerX or px
    local refY = centerY or py
    if not refX or not refY then return 0 end

    -- Selalu hormati penuh CFG.collect_range (jangan dipangkas ke 2 tile saat quickMode)
    local radius = customRadius or CFG.collect_range or 3
    local collected = 0

    for _, obj in pairs(objs) do
        if not STATE.running then break end
        if obj and obj.pos and obj.id then
            local ox = math.floor((obj.pos.x + 10) / 32)
            local oy = math.floor((obj.pos.y + 10) / 32)
            local itemid = obj.itemid or 0
            local dist = math.max(math.abs(ox - refX), math.abs(oy - refY))

            local spotKey = tostring(ox) .. "," .. tostring(oy)
            if dist <= radius and itemid ~= ITEM.LAVA and (not STATE.df_dropped_spots[spotKey]) then
                local curAmt = getInvCount(itemid)
                if curAmt < 200 then
                    local curPx, curPy = getPlayerTilePos()
                    local pDist = (curPx and curPy) and math.max(math.abs(ox - curPx), math.abs(oy - curPy)) or 99
                    -- Server Growtopia menolak pickup bila terlalu jauh (> 1 tile bila tidak quick, atau > 2 tile saat quick); hampiri dulu agar item di dalam area collect_range benar-benar terambil!
                    local needWalk = (not quickMode and pDist > 1) or (pDist > 2)
                    if needWalk and isTileSafeToStand(ox, oy) then
                        moveSafeTo(ox, oy)
                    end
                    -- Sesuai docs structs/game-objects.md: paket type 11 mengirim koord objek (obj.pos.x, obj.pos.y)
                    pcall(sendPacketRaw, false, {
                        type  = 11,
                        value = obj.id,
                        x     = obj.pos.x,
                        y     = obj.pos.y,
                    })
                    if not quickMode then
                        safeSleep(20)
                    end
                    collected = collected + 1
                end
            end
        end
    end
    return collected
end

-- Estimate realistic punch count for an item ID so lag won't cause 45x punch spam
local KNOWN_BREAK_HITS = {
    [ITEM.DIRT]    = 3,
    [ITEM.CAVE_BG] = 4, -- Cave Background membutuhkan 4 punch (sama seperti Lava), bukan 3
    [ITEM.LAVA]    = 4,
    [ITEM.ROCK]    = 6,
}

local function estimateTileBreakHits(itemID)
    if not itemID or itemID <= 0 then return 3 end
    if KNOWN_BREAK_HITS[itemID] then
        return KNOWN_BREAK_HITS[itemID]
    end
    local info = nil
    if getItemInfoByID then
        local ok, res = pcall(getItemInfoByID, itemID)
        if ok and res then info = res end
    elseif itemInfoManager and itemInfoManager.getItemInfoByID then
        local ok, res = pcall(itemInfoManager.getItemInfoByID, itemID)
        if ok and res then info = res end
    end
    local bh = info and tonumber(info.breakHits) or 0
    if bh > 0 then
        -- Growtopia items.dat often stores breakHits * 6 (e.g. 18 = 3 hits, 36 = 6 hits)
        local normalized = (bh >= 12) and math.ceil(bh / 6) or math.ceil(bh)
        if normalized < 2 then normalized = 2 end
        if normalized > 10 then normalized = 10 end
        return normalized
    end
    return 4
end

-- Helper: Wait up to maxWaitMs for server to confirm the current FG/BG layer cleared
local function awaitTileLayerCleared(tx, ty, isFgLayer, maxWaitMs)
    local function isCleared()
        local ok, t = pcall(getTile, tx, ty)
        if not ok or not t then return false, true end
        if isFgLayer then
            return (t.fg == 0 or t.fg == ITEM.BEDROCK or t.fg == ITEM.MAIN_DOOR), false
        end
        return (t.bg == 0), false
    end

    local cleared, failed = isCleared()
    if failed then return false end
    if cleared then return true end

    local waited = 0
    while STATE.running and waited < maxWaitMs do
        safeSleep(25)
        waited = waited + 25
        cleared, failed = isCleared()
        if failed then return false end
        if cleared then return true end
    end
    return false
end

local function breakTileLayerWithLagGuard(tx, ty, isFgLayer, preferredDirX)
    local maxRounds = 5
    for round = 1, maxRounds do
        if not waitIfPaused() then return false end
        local ok, t = pcall(getTile, tx, ty)
        if not ok or not t then return false end

        local curId = isFgLayer and t.fg or t.bg
        if curId == 0 then return true end
        if isFgLayer and (curId == ITEM.BEDROCK or curId == ITEM.MAIN_DOOR) then
            return true
        end

        local px, py = getPlayerTilePos()
        -- Jangan pindah posisi bila sudah berada di jangkauan punch aman (<= 2 tile) agar Break 3 Tile tidak lompat-lompat!
        if (not px) or (px == tx and py == ty) or (math.abs(px - tx) > 2) or (math.abs(py - ty) > 2) or (not isTileSafeToStand(px, py)) then
            local jumpDist = (px and py) and math.max(math.abs(px - tx), math.abs(py - ty)) or 5
            moveAdjacentSafe(tx, ty, preferredDirX)
            if jumpDist >= 4 then
                safeSleep(50) -- Hanya jeda ringan bila habis lompat jauh, langkah antar tile tetap mulus
            end
        end

        local prevProgress = tonumber(t.progress) or 0
        local baseHits = estimateTileBreakHits(curId)
        local burstCount = (round == 1) and baseHits or math.min(3, math.max(1, math.ceil(baseHits / 2)))

        for _ = 1, burstCount do
            if not waitIfPaused() then return false end
            local okStep, tStep = pcall(getTile, tx, ty)
            if not okStep or not tStep then break end
            local stepId = isFgLayer and tStep.fg or tStep.bg
            if stepId == 0 or (isFgLayer and (stepId == ITEM.BEDROCK or stepId == ITEM.MAIN_DOOR)) then
                return true
            end
            sendRawAction(tx, ty, ITEM.PUNCH)
            safeSleep(CFG.delay_break)
        end

        -- Polling ultra-cepat setiap 25ms agar langsung pindah tanpa jeda terasa, tetap aman anti-spam saat lag
        local waitWindow = (round == 1) and 220 or ((round == 2) and 280 or 360)
        if awaitTileLayerCleared(tx, ty, isFgLayer, waitWindow) then
            return true
        end

        -- Still intact: bila disconnect saat sedang break, tunggu online kembali lalu lanjutkan tile ini
        local wNow = getWorldNameSafe()
        if wNow == "" or wNow == "EXIT" then
            if ensureOnlineInWorld and ensureOnlineInWorld(STATE.active_world, STATE.active_door) then
                -- Reconnect berhasil, lanjut putaran berikutnya tanpa membuang tile
            else
                return false
            end
        end
        local okAfter, tAfter = pcall(getTile, tx, ty)
        local afterProgress = (okAfter and tAfter and tonumber(tAfter.progress)) or 0
        if round >= 2 and afterProgress <= prevProgress then
            -- Jika progress macet 0 di putaran >= 3 (indikasi rubberband server), re-sinkronkan posisi di koridor sebelum pukul ulang
            if round >= 3 and py and math.abs(py - ty) <= 2 then
                local stepAlt = (tx > 1) and (tx - 1) or (tx + 1)
                if isTileSafeToStand(stepAlt, py) and (stepAlt ~= tx or py ~= ty) then
                    moveSafeTo(stepAlt, py)
                else
                    moveAdjacentSafe(tx, ty, preferredDirX)
                end
            end
            safeSleep(140)
        end
    end

    local okEnd, tEnd = pcall(getTile, tx, ty)
    if not okEnd or not tEnd then return false end
    return isFgLayer and (tEnd.fg == 0) or (not isFgLayer and tEnd.bg == 0)
end

local breakCollectCounter = 0

local function breakTileCompletely(tx, ty, breakFg, breakBg, preferredDirX, skipCollect)
    if tx < 0 or tx > 99 or ty < 0 or ty > 59 then return false end
    local ok, t = pcall(getTile, tx, ty)
    if not ok or not t then return false end
    if t.fg == ITEM.BEDROCK or t.fg == ITEM.MAIN_DOOR then
        return true
    end

    local fgDone = true
    if breakFg and t.fg ~= 0 then
        fgDone = breakTileLayerWithLagGuard(tx, ty, true, preferredDirX)
    end

    local bgDone = true
    if breakBg and STATE.running then
        local okBg, tBg = pcall(getTile, tx, ty)
        if okBg and tBg and tBg.bg ~= 0 then
            if tBg.fg ~= 0 and tBg.fg ~= ITEM.BEDROCK and tBg.fg ~= ITEM.MAIN_DOOR then
                if breakFg then
                    fgDone = breakTileLayerWithLagGuard(tx, ty, true, preferredDirX)
                    okBg, tBg = pcall(getTile, tx, ty)
                else
                    bgDone = false
                end
            end
            if okBg and tBg and tBg.fg == 0 and tBg.bg ~= 0 then
                bgDone = breakTileLayerWithLagGuard(tx, ty, false, preferredDirX)
            elseif okBg and tBg and tBg.fg ~= 0 and tBg.bg ~= 0 then
                bgDone = false
            end
        end
    end

    if CFG.auto_collect and (not skipCollect) then
        breakCollectCounter = breakCollectCounter + 1
        if (breakCollectCounter % 2) == 0 then
            collectNearbyFloating(tx, ty, CFG.collect_range, true)
        end
    end

    return fgDone and bgDone
end

local function placeTileAt(tx, ty, itemID, isBackground, preferredDirX)
    if tx < 0 or tx > 99 or ty < 0 or ty > 59 then return false end
    local ok, t = pcall(getTile, tx, ty)
    if not ok or not t then return false end

    if not isBackground and t.fg == itemID then
        return true
    end
    if isBackground and t.bg == itemID then
        return true
    end
    if getInvCount(itemID) <= 0 then
        return false
    end

    local isSeed = (itemID == ITEM.DIRT_SEED or itemID == ITEM.CAVE_SEED or itemID == ITEM.LAVA_SEED or itemID == ITEM.ROCK_SEED)

    local maxAttempts = 10
    local attempts = 0
    while STATE.running and attempts < maxAttempts do
        if not waitIfPaused() then return false end
        ok, t = pcall(getTile, tx, ty)
        if not ok or not t then break end
        if (not isBackground and t.fg == itemID) or (isBackground and t.bg == itemID) then
            return true
        end

        local px, py = getPlayerTilePos()
        local outOfRange = (not px) or (math.abs(px - tx) > 2) or (math.abs(py - ty) > 2)
        local standingOnTarget = (px == tx and py == ty)

        if (not isSeed) and (outOfRange or standingOnTarget) then
            moveAdjacentSafe(tx, ty, preferredDirX)
        elseif outOfRange then
            moveAdjacentSafe(tx, ty, preferredDirX)
        end

        sendRawAction(tx, ty, itemID)
        safeSleep(CFG.delay_place)
        attempts = attempts + 1
    end

    ok, t = pcall(getTile, tx, ty)
    return ok and t and ((not isBackground and t.fg == itemID) or (isBackground and t.bg == itemID))
end

-- Strict Validated Placement for Security Items (WL, SL, Jammer, Door ID, Blocker Doors)
local function placeAndValidateSecurityTile(tx, ty, itemID, itemLabel, standX, standY)
    if tx < 0 or tx > 99 or ty < 0 or ty > 59 then return false end
    local ok, t = pcall(getTile, tx, ty)
    if ok and t and t.fg == itemID then
        addLog(string.format("Validasi OK: %s sudah terpasang di (%d, %d)", itemLabel, tx, ty))
        return true
    end

    if getInvCount(itemID) <= 0 then
        addLog(string.format("Gagal Pasang %s: Stok di tas 0!", itemLabel))
        return false
    end

    for attempt = 1, 12 do
        if not waitIfPaused() then return false end
        ok, t = pcall(getTile, tx, ty)
        if ok and t and t.fg == itemID then
            addLog(string.format("Validasi Pasang OK: %s berhasil dipasang di (%d, %d) [Cek #%d]", itemLabel, tx, ty, attempt))
            return true
        end

        -- Jika masih ada block lain yang menghalangi di (tx, ty), hancurkan dulu sampai bersih
        if ok and t and t.fg ~= 0 and t.fg ~= itemID and t.fg ~= ITEM.BEDROCK and t.fg ~= ITEM.MAIN_DOOR then
            breakTileCompletely(tx, ty, true, false, 1)
            safeSleep(150)
        end

        if standX and standY and isTileSafeToStand(standX, standY) then
            moveSafeTo(standX, standY)
        else
            moveAdjacentSafe(tx, ty, 1)
        end

        local px, py = getPlayerTilePos()
        if px == tx and py == ty then
            moveAdjacentSafe(tx, ty, 1)
        end

        sendRawAction(tx, ty, itemID)
        safeSleep(CFG.delay_place + 180)

        ok, t = pcall(getTile, tx, ty)
        if ok and t and t.fg == itemID then
            addLog(string.format("Validasi Pasang OK: %s berhasil dipasang di (%d, %d)", itemLabel, tx, ty))
            return true
        end
    end

    ok, t = pcall(getTile, tx, ty)
    local success = (ok and t and t.fg == itemID)
    if not success then
        addLog(string.format("PERINGATAN: Gagal validasi pasang %s di (%d, %d)!", itemLabel, tx, ty))
    end
    return success
end

-- ============================================================================
-- 6. NETWORK WARP, TRASH, DROP & VALIDATED WRENCH DIALOG EDITING
-- ============================================================================

local function warpTo(worldName, doorID)
    if not worldName or worldName == "" then return false end
    worldName = worldName:upper():gsub("%s+", "")
    doorID = (doorID or ""):gsub("%s+", "")

    local targetStr = (doorID ~= "") and (worldName .. "|" .. doorID) or worldName
    setStatus("Warping", "Menuju world " .. targetStr)

    local tries = 0
    while STATE.running and tries < 5 do
        if not waitIfPaused() then return false end
        local cur = getWorldNameSafe()
        if cur ~= worldName then
            sendPacket(3, "action|join_request\nname|" .. targetStr .. "\ninvitedWorld|0\n")
            safeSleep(CFG.delay_warp)
        else
            if doorID ~= "" and isOnMainDoor() then
                sendPacket(3, "action|join_request\nname|" .. worldName .. "|" .. doorID .. "\ninvitedWorld|0\n")
                safeSleep(2500)
            end
            if getWorldNameSafe() == worldName then
                STATE.current_world = worldName
                applyCheatToggles()
                return true
            end
        end
        tries = tries + 1
    end

    STATE.current_world = getWorldNameSafe()
    applyCheatToggles()
    return STATE.current_world == worldName
end

local function isPlayerOnlineInWorld()
    local curW = getWorldNameSafe()
    if curW == "" or curW == "EXIT" then
        return false, curW
    end
    if getLocal then
        local okP, p = pcall(getLocal)
        if not okP or not p then
            return false, curW
        end
    end
    return true, curW
end

-- Saat Disconnect / terlempar ke EXIT, tunggu hingga online kembali lalu lanjut ke world DF target
ensureOnlineInWorld = function(expectedWorld, expectedDoor)
    local targetW = tostring(expectedWorld or STATE.active_world or ""):upper()
    local targetD = tostring(expectedDoor or STATE.active_door or "")
    local online, curW = isPlayerOnlineInWorld()
    if online and (targetW == "" or curW == targetW) then
        return true
    end

    if (not online) and (not CFG.auto_reconnect) then
        addLog("Disconnect terdeteksi (Auto Reconnect OFF) -> Bot dihentikan.")
        return false
    end

    local wasDisconnected = not online
    STATE.reconnecting = true
    if wasDisconnected then
        setStatus("Menunggu Online", "Disconnect terdeteksi! Auto Reconnect aktif, menunggu online lalu run ulang DF...")
    end
    applyCheatToggles()

    local ticks = 0
    while STATE.running do
        if not waitIfPaused() then
            STATE.reconnecting = false
            return false
        end
        safeSleep(2000)
        ticks = ticks + 1

        local nowOnline, nowW = isPlayerOnlineInWorld()
        if nowOnline then
            if targetW ~= "" and nowW ~= targetW then
                setStatus("Auto Reconnect", "Kembali online! Masuk lagi ke " .. targetW .. " & mengulang scan DF...")
                if warpTo(targetW, targetD) then
                    safeSleep(900)
                    STATE.reconnecting = false
                    applyCheatToggles()
                    if wasDisconnected then
                        STATE.reconnected_restart = true
                        STATE.resume_world_override = targetW
                        STATE.resume_door_override = targetD
                        return false
                    end
                    return true
                end
            else
                safeSleep(600)
                STATE.reconnecting = false
                STATE.current_world = nowW
                applyCheatToggles()
                addLog("Kembali Online di " .. nowW .. "!")
                if wasDisconnected then
                    STATE.reconnected_restart = true
                    STATE.resume_world_override = (targetW ~= "") and targetW or nowW
                    STATE.resume_door_override = targetD
                    return false
                end
                return true
            end
        elseif targetW ~= "" and getLocal then
            local okP, p = pcall(getLocal)
            if okP and p and (ticks % 3 == 0) then
                -- Coba join balik jika sudah login di Title Screen (EXIT)
                local targetStr = (targetD ~= "") and (targetW .. "|" .. targetD) or targetW
                pcall(sendPacket, 3, "action|join_request\nname|" .. targetStr .. "\ninvitedWorld|0\n")
            end
        end
    end

    STATE.reconnecting = false
    return false
end

local function trashItem(itemID, count)
    if count <= 0 then return end
    STATE.suppress_dialog = true
    sendPacket(2, "action|trash\n|itemID|" .. tostring(itemID))
    safeSleep(350)
    sendPacket(2, string.format(
        "action|dialog_return\ndialog_name|trash_item\nitemID|%d|\ncount|%d\n",
        itemID, count
    ))
    safeSleep(450)
    STATE.suppress_dialog = false
end

-- Forward declarations for World List editing helpers
local refreshNativeDisplayLists
local updateWorldDisplayList
local updateTrashDisplayList
local getConfiguredTrashItemList
local setTrashListFromTable
local openWorldListManagerDialog
local openEditWorldEntryDialog
local openTrashListManagerDialog
local openEditTrashEntryDialog

-- Edit & Hapus item pada CFG.world_list berdasarkan nomor urut (1..N)
local function editWorldEntryAt(idx, rawName, rawDoor)
    idx = math.floor(tonumber(idx) or 0)
    if idx < 1 or idx > #CFG.world_list then
        return false, "Nomor world tidak valid!"
    end
    local cleanName = tostring(rawName or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local cleanDoor = tostring(rawDoor or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if cleanName == "" then
        return false, "Nama world tidak boleh kosong!"
    end
    if cleanName:find("|", 1, true) then
        local wPart, dPart = cleanName:match("^([^|]+)|(.*)$")
        if wPart then
            cleanName = wPart:gsub("^%s+", ""):gsub("%s+$", "")
            if cleanDoor == "" then
                cleanDoor = (dPart or ""):gsub("^%s+", ""):gsub("%s+$", "")
            end
        end
    end
    cleanName = cleanName:upper()
    CFG.world_list[idx].name = cleanName
    CFG.world_list[idx].door = cleanDoor
    persistConfig()
    if updateWorldDisplayList then updateWorldDisplayList() end
    return true, string.format("World #%d diubah -> %s%s", idx, cleanName, (cleanDoor ~= "" and (" | " .. cleanDoor) or ""))
end

local function deleteWorldEntryAt(idx)
    idx = math.floor(tonumber(idx) or 0)
    if idx < 1 or idx > #CFG.world_list then
        return false, "Nomor world tidak valid!"
    end
    local removed = table.remove(CFG.world_list, idx)
    persistConfig()
    if updateWorldDisplayList then updateWorldDisplayList() end
    return true, "World #" .. tostring(idx) .. " (" .. tostring(removed and removed.name or "") .. ") dihapus!"
end

-- Parse Growtopia OnDialogRequest fields dynamically (inputs, checkboxes, embed_data, buttons)
local function parseDialogFields(dlgText)
    local meta = {
        dialog_name = "",
        embeds = {},
        embed_order = {},
        inputs = {},
        input_order = {},
        checkboxes = {},
        checkbox_labels = {},
        checkbox_order = {},
        buttons = {},
    }
    if type(dlgText) ~= "string" or dlgText == "" then
        return meta
    end
    for line in dlgText:gmatch("[^\r\n]+") do
        local parts = {}
        for part in (line .. "|"):gmatch("([^|]*)|") do
            table.insert(parts, part)
        end
        local cmd = parts[1]
        if cmd == "end_dialog" and parts[2] and parts[2] ~= "" then
            meta.dialog_name = parts[2]
        elseif cmd == "embed_data" and parts[2] and parts[2] ~= "" then
            local k = parts[2]
            if meta.embeds[k] == nil then
                table.insert(meta.embed_order, k)
            end
            meta.embeds[k] = parts[3] or ""
        elseif cmd == "add_text_input" and parts[2] and parts[2] ~= "" then
            local k = parts[2]
            if meta.inputs[k] == nil then
                table.insert(meta.input_order, k)
            end
            meta.inputs[k] = parts[4] or ""
        elseif cmd == "add_checkbox" and parts[2] and parts[2] ~= "" then
            local k = parts[2]
            if meta.checkboxes[k] == nil then
                table.insert(meta.checkbox_order, k)
            end
            meta.checkbox_labels[k] = parts[3] or ""
            meta.checkboxes[k] = parts[4] or "0"
        elseif (cmd == "add_button" or cmd == "add_button_with_icon") and parts[2] and parts[2] ~= "" then
            meta.buttons[parts[2]] = parts[3] or parts[2]
        end
    end
    return meta
end

local function buildDialogReturn(dlgText, fallbackName, fallbackX, fallbackY, inputOverrides, checkOverrides, buttonClicked)
    local meta = parseDialogFields(dlgText)
    local dName = (meta.dialog_name ~= "" and meta.dialog_name) or fallbackName
    local tx = tonumber(meta.embeds.tilex) or fallbackX
    local ty = tonumber(meta.embeds.tiley) or fallbackY

    local lines = {
        "action|dialog_return",
        "dialog_name|" .. tostring(dName),
    }
    if tx ~= nil then table.insert(lines, "tilex|" .. tostring(tx) .. "|") end
    if ty ~= nil then table.insert(lines, "tiley|" .. tostring(ty) .. "|") end
    local emitted = {}
    for _, ek in ipairs(meta.embed_order or {}) do
        if ek ~= "tilex" and ek ~= "tiley" then
            table.insert(lines, tostring(ek) .. "|" .. tostring(meta.embeds[ek] or "") .. "|")
            emitted[ek] = true
        end
    end
    if buttonClicked and buttonClicked ~= "" then
        table.insert(lines, "buttonClicked|" .. tostring(buttonClicked))
    end

    for _, k in ipairs(meta.input_order) do
        local v = (inputOverrides and inputOverrides[k] ~= nil) and inputOverrides[k] or meta.inputs[k]
        table.insert(lines, tostring(k) .. "|" .. tostring(v or ""))
        emitted[k] = true
    end
    if inputOverrides then
        for k, v in pairs(inputOverrides) do
            if not emitted[k] then
                table.insert(lines, tostring(k) .. "|" .. tostring(v))
                emitted[k] = true
            end
        end
    end

    for _, k in ipairs(meta.checkbox_order) do
        local v = (checkOverrides and checkOverrides[k] ~= nil) and checkOverrides[k] or meta.checkboxes[k]
        table.insert(lines, tostring(k) .. "|" .. tostring(v or "0"))
        emitted[k] = true
    end
    if checkOverrides then
        for k, v in pairs(checkOverrides) do
            if not emitted[k] then
                table.insert(lines, tostring(k) .. "|" .. tostring(v))
                emitted[k] = true
            end
        end
    end

    return table.concat(lines, "\n") .. "\n"
end

local function parseDialogReturnFields(pkt)
    local fields = {}
    if type(pkt) ~= "string" then return fields end
    for line in pkt:gmatch("[^\r\n]+") do
        local k, v = line:match("^([^|]+)|(.*)$")
        if k and k ~= "" then
            v = (v or ""):gsub("|$", "")
            fields[k] = v
        end
    end
    return fields
end

openEditWorldEntryDialog = function(idx)
    local entry = CFG.world_list[idx]
    if not entry or not growtopia or not growtopia.sendDialog then return end
    local dLines = {
        "set_default_color|`o",
        string.format("add_label_with_icon|big|`wEdit World #%d``|left|2|", idx),
        "add_spacer|small|",
        string.format("add_text_input|edit_w_name|Nama World|%s|24|", tostring(entry.name or "")),
        string.format("add_text_input|edit_w_door|Door ID (Kosong = White Door)|%s|20|", tostring(entry.door or "")),
        "add_spacer|small|",
        "add_button|save_w_edit|`2Simpan Perubahan|noflags|0|0|",
        "add_button|del_w_edit|`4Hapus World Ini|noflags|0|0|",
        string.format("end_dialog|boren_world_edit_%d|Batal||", idx),
    }
    pcall(growtopia.sendDialog, table.concat(dLines, "\n"))
end

local function getWorldEntryStatusTag(entry)
    if entry and entry.done then return "DONE" end
    if STATE.running and entry and (STATE.active_world == entry.name or entry.status == "PROSES") then
        return "PROSES"
    end
    return "ANTRI"
end

openWorldListManagerDialog = function()
    if not growtopia or not growtopia.sendDialog then return false end
    local dLines = {
        "set_default_color|`o",
        string.format("add_label_with_icon|big|`wList World DF (%d)``|left|2|", #CFG.world_list),
        "add_textbox|`oKelola daftar world DF: tekan `9Edit`o atau `4Hapus`o di tiap world.|left|",
    }
    if #CFG.world_list == 0 then
        table.insert(dLines, "add_spacer|small|")
        table.insert(dLines, "add_textbox|`4List world masih kosong. Tambah world lewat kolom di bawah!|left|")
    else
        for i, entry in ipairs(CFG.world_list) do
            local tag = getWorldEntryStatusTag(entry)
            local st = (tag == "DONE") and "`2[DONE]" or ((tag == "PROSES") and "`6[PROSES]" or "`9[ANTRI]")
            local doorTxt = (entry.door and entry.door ~= "") and ("ID: " .. tostring(entry.door)) or "Public"
            table.insert(dLines, "add_spacer|small|")
            table.insert(dLines, string.format("add_textbox|`w%d. %s `o[%s] %s|left|", i, tostring(entry.name), doorTxt, st))
            table.insert(dLines, string.format("add_button|boren_wedit_%d|`9Edit #%d|noflags|0|0|", i, i))
            table.insert(dLines, string.format("add_button|boren_whapus_%d|`4Hapus #%d|noflags|0|0|", i, i))
        end
    end
    table.insert(dLines, "add_spacer|small|")
    table.insert(dLines, "add_text_input|boren_new_w|Tambah World Baru||24|")
    table.insert(dLines, "add_text_input|boren_new_d|Door ID (Opsional)||20|")
    table.insert(dLines, "add_button|boren_wadd|`2+ Tambah World|noflags|0|0|")
    table.insert(dLines, "end_dialog|boren_world_mgr|Tutup||")
    pcall(growtopia.sendDialog, table.concat(dLines, "\n"))
    return true
end

openEditTrashEntryDialog = function(idx)
    local list = getConfiguredTrashItemList()
    local curId = list[idx]
    if not curId or not growtopia or not growtopia.sendDialog then return end
    local dLines = {
        "set_default_color|`o",
        string.format("add_label_with_icon|big|`wEdit Item Trash #%d``|left|%d|", idx, curId),
        string.format("add_textbox|`oItem saat ini: `w%s (ID: %d)|left|", resolveItemName(curId), curId),
        "add_spacer|small|",
        string.format("add_text_input|edit_trash_id|Item ID Baru|%d|12|", curId),
        "add_spacer|small|",
        "add_button|save_t_edit|`2Simpan Perubahan|noflags|0|0|",
        "add_button|del_t_edit|`4Hapus Item Ini|noflags|0|0|",
        string.format("end_dialog|boren_trash_edit_%d|Batal||", idx),
    }
    pcall(growtopia.sendDialog, table.concat(dLines, "\n"))
end

openTrashListManagerDialog = function()
    if not growtopia or not growtopia.sendDialog then return false end
    local list = getConfiguredTrashItemList()
    local thresh = math.max(10, tonumber(CFG.trash_threshold) or 150)
    local dLines = {
        "set_default_color|`o",
        string.format("add_label_with_icon|big|`wList Auto-Trash (%d)``|left|18|", #list),
        string.format("add_textbox|`oAuto-Trash aktif saat jumlah >= `2%d`o. Tekan `9Edit`o atau `4Hapus`o di tiap item.|left|", thresh),
    }
    if #list == 0 then
        table.insert(dLines, "add_spacer|small|")
        table.insert(dLines, "add_textbox|`4List Trash masih kosong. Tambah ID item lewat kolom di bawah!|left|")
    else
        for i, id in ipairs(list) do
            table.insert(dLines, "add_spacer|small|")
            table.insert(dLines, string.format("add_textbox|`w%d. %s `o(ID: `2%d`o | BP: %d)|left|", i, resolveItemName(id), id, getInvCount(id)))
            table.insert(dLines, string.format("add_button|boren_tedit_%d|`9Edit #%d|noflags|0|0|", i, i))
            table.insert(dLines, string.format("add_button|boren_thapus_%d|`4Hapus #%d|noflags|0|0|", i, i))
        end
    end
    table.insert(dLines, "add_spacer|small|")
    table.insert(dLines, "add_text_input|boren_new_trash_id|Tambah Item ID Baru||12|")
    table.insert(dLines, "add_button|boren_tadd|`2+ Tambah ke Trash|noflags|0|0|")
    table.insert(dLines, "add_button|boren_treset|`6Reset Default (Lava, Cave, Rock)|noflags|0|0|")
    table.insert(dLines, "end_dialog|boren_trash_mgr|Tutup||")
    pcall(growtopia.sendDialog, table.concat(dLines, "\n"))
    return true
end

local function openMiniConsoleDialog(errorsOnly)
    local onlyErr = (errorsOnly == true)
    local srcList = onlyErr and STATE.error_logs or STATE.logs
    local modeLabel = onlyErr and "Hanya Error/Warn" or "Semua Log"

    if growtopia and growtopia.sendDialog and getWorldNameSafe() ~= "EXIT" then
        local dLines = {
            "set_default_color|`o",
            string.format("add_label_with_icon|big|`wBoren Mini Console (%s)``|left|32|", modeLabel),
            string.format("add_textbox|`oStatus: `2%s `o| World: `w%s `o| Error: `4%d|left|", tostring(STATE.current_step), tostring(STATE.current_world), tonumber(STATE.error_count) or 0),
            "add_spacer|small|",
        }
        if #srcList == 0 then
            table.insert(dLines, string.format("add_textbox|`2Belum ada catatan pada mode %s.|left|", modeLabel))
        else
            local maxShow = math.min(14, #srcList)
            for i = 1, maxShow do
                local lineTxt = tostring(srcList[i]):gsub("|", "/")
                local col = isErrorMessage(lineTxt) and "`4" or "`o"
                table.insert(dLines, string.format("add_textbox|%s%s|left|", col, lineTxt))
            end
        end
        table.insert(dLines, "add_spacer|small|")
        table.insert(dLines, "add_button|console_all|`2Semua Log|noflags|0|0|")
        table.insert(dLines, "add_button|console_err|`4Error Saja|noflags|0|0|")
        table.insert(dLines, "add_button|console_clear|`9Clear Log|noflags|0|0|")
        table.insert(dLines, "end_dialog|boren_mini_console|Tutup||")
        pcall(growtopia.sendDialog, table.concat(dLines, "\n"))
        return true
    elseif sendDialog then
        local lines = {
            string.format("Status: %s | World: %s | Total Error: %d", tostring(STATE.current_step), tostring(STATE.current_world), tonumber(STATE.error_count) or 0),
            "------------------------------------"
        }
        if #srcList == 0 then
            table.insert(lines, "(Belum ada catatan)")
        else
            for i = 1, math.min(12, #srcList) do
                table.insert(lines, tostring(srcList[i]))
            end
        end
        pcall(sendDialog, {
            title = "Mini Console (" .. modeLabel .. ")",
            alias = "boren_mini_console_dlg",
            message = table.concat(lines, "\n"),
            confirm = "OK"
        })
        return true
    end
    return false
end

local function onVariantDialogHook(var, pkt)
    if not var then return end
    local ok, shouldBlock = pcall(function()
        local v1 = var.v1
        if v1 == "OnDialogRequest" then
            local raw = tostring(var.v2 or "")
            local dName = raw:match("end_dialog|([^|\n]+)") or ""
            STATE.last_dialog_text = raw
            STATE.last_dialog_name = dName
            STATE.last_dialog_seq = (STATE.last_dialog_seq or 0) + 1
            if STATE.suppress_dialog then
                return true
            end
        end
        return false
    end)
    if ok and shouldBlock then
        return true
    end
end

local function onSendPacketDialogHook(ptype, pkt)
    if type(pkt) ~= "string" then return end
    local ok, shouldBlock = pcall(function()
        if not pkt:find("action|dialog_return", 1, true) then
            return false
        end
        local fields = parseDialogReturnFields(pkt)
        local dName = fields.dialog_name or ""

        if dName == "boren_world_mgr" then
            local btn = fields.buttonClicked or ""
            local delIdx = btn:match("^boren_whapus_(%d+)$")
            local editIdx = btn:match("^boren_wedit_(%d+)$")
            if delIdx then
                local okDel, msg = deleteWorldEntryAt(tonumber(delIdx))
                if sendNotification then pcall(sendNotification, msg) end
                if okDel then openWorldListManagerDialog() end
            elseif editIdx then
                openEditWorldEntryDialog(tonumber(editIdx))
            elseif btn == "boren_wadd" then
                local added = addManualWorldsFromString(fields.boren_new_w or "", fields.boren_new_d or "", false)
                if updateWorldDisplayList then updateWorldDisplayList() end
                if added > 0 then
                    if sendNotification then pcall(sendNotification, string.format("%d World ditambahkan! (Total: %d)", added, #CFG.world_list)) end
                else
                    if sendNotification then pcall(sendNotification, "Isi kolom Tambah World Baru terlebih dulu!") end
                end
                openWorldListManagerDialog()
            end
            return true
        end

        local editTargetIdx = dName:match("^boren_world_edit_(%d+)$")
        if editTargetIdx then
            local idx = tonumber(editTargetIdx)
            local btn = fields.buttonClicked or ""
            if btn == "del_w_edit" then
                local _, msg = deleteWorldEntryAt(idx)
                if sendNotification then pcall(sendNotification, msg) end
            elseif btn == "save_w_edit" or fields.edit_w_name then
                local _, msg = editWorldEntryAt(idx, fields.edit_w_name or "", fields.edit_w_door or "")
                if sendNotification then pcall(sendNotification, msg) end
            end
            openWorldListManagerDialog()
            return true
        end

        if dName == "boren_trash_mgr" then
            local btn = fields.buttonClicked or ""
            local delIdx = btn:match("^boren_thapus_(%d+)$")
            local editIdx = btn:match("^boren_tedit_(%d+)$")
            local list = getConfiguredTrashItemList()
            if delIdx then
                local idx = tonumber(delIdx)
                if idx and idx >= 1 and idx <= #list then
                    local removedId = table.remove(list, idx)
                    setTrashListFromTable(list)
                    persistConfig()
                    if updateTrashDisplayList then pcall(updateTrashDisplayList) end
                    if sendNotification then pcall(sendNotification, "Dihapus dari Trash: " .. resolveItemName(removedId)) end
                end
                openTrashListManagerDialog()
            elseif editIdx then
                openEditTrashEntryDialog(tonumber(editIdx))
            elseif btn == "boren_treset" then
                CFG.trash_list_str = "4,14,10"
                persistConfig()
                if updateTrashDisplayList then pcall(updateTrashDisplayList) end
                if sendNotification then pcall(sendNotification, "List Trash direset ke default!") end
                openTrashListManagerDialog()
            elseif btn == "boren_tadd" or (fields.boren_new_trash_id and fields.boren_new_trash_id ~= "") then
                local newId = math.floor(tonumber(fields.boren_new_trash_id) or 0)
                if newId > 0 then
                    local exists = false
                    for _, v in ipairs(list) do if v == newId then exists = true; break end end
                    if not exists then table.insert(list, newId) end
                    setTrashListFromTable(list)
                    persistConfig()
                    if updateTrashDisplayList then pcall(updateTrashDisplayList) end
                    if sendNotification then pcall(sendNotification, "Ditambah ke Trash: " .. resolveItemName(newId)) end
                elseif sendNotification then
                    pcall(sendNotification, "Isi Item ID yang valid (angka > 0)!")
                end
                openTrashListManagerDialog()
            end
            return true
        end

        local editTrashIdx = dName:match("^boren_trash_edit_(%d+)$")
        if editTrashIdx then
            local idx = tonumber(editTrashIdx)
            local btn = fields.buttonClicked or ""
            local list = getConfiguredTrashItemList()
            if idx and idx >= 1 and idx <= #list then
                if btn == "del_t_edit" then
                    local removedId = table.remove(list, idx)
                    setTrashListFromTable(list)
                    persistConfig()
                    if updateTrashDisplayList then pcall(updateTrashDisplayList) end
                    if sendNotification then pcall(sendNotification, "Dihapus dari Trash: " .. resolveItemName(removedId)) end
                elseif btn == "save_t_edit" or fields.edit_trash_id then
                    local newId = math.floor(tonumber(fields.edit_trash_id) or 0)
                    if newId > 0 then
                        list[idx] = newId
                        setTrashListFromTable(list)
                        persistConfig()
                        if updateTrashDisplayList then pcall(updateTrashDisplayList) end
                        if sendNotification then pcall(sendNotification, "Item Trash #" .. tostring(idx) .. " -> " .. resolveItemName(newId)) end
                    end
                end
            end
            openTrashListManagerDialog()
            return true
        end

        if dName == "boren_mini_console" then
            local btn = fields.buttonClicked or ""
            if btn == "console_all" then
                STATE.console_errors_only = false
                openMiniConsoleDialog(false)
            elseif btn == "console_err" then
                STATE.console_errors_only = true
                openMiniConsoleDialog(true)
            elseif btn == "console_clear" then
                STATE.logs = {}
                STATE.error_logs = {}
                STATE.error_count = 0
                openMiniConsoleDialog(STATE.console_errors_only)
            end
            return true
        end

        return false
    end)
    if ok and shouldBlock then
        return true
    end
end

local function ensureRuntimeHooks()
    if STATE.runtime_hooks_installed then return end
    STATE.runtime_hooks_installed = true
    onVariant = onVariantDialogHook
    OnVariant = onVariantDialogHook
    onSendPacket = onSendPacketDialogHook
    OnSendPacket = onSendPacketDialogHook
    if addHook then
        pcall(addHook, onVariantDialogHook, "onvariant")
        pcall(addHook, onSendPacketDialogHook, "onsendpacket")
    end
    if applyHook then
        pcall(applyHook)
    end
end

-- Drop item dengan validasi Backpack (cek stok BP sebelum & sesudah drop + support dialog drop & confirmDropItem)
local function waitInvDecrease(itemID, beforeCnt, maxWaitMs)
    local waited = 0
    while waited < maxWaitMs do
        safeSleep(40)
        waited = waited + 40
        local cur = getInvCount(itemID)
        if cur < beforeCnt then
            return beforeCnt - cur, cur
        end
    end
    local finalCnt = getInvCount(itemID)
    return math.max(0, beforeCnt - finalCnt), finalCnt
end

-- Drop item mengutamakan API bawaan GrowLauncher (growtopia.confirmDropItem) agar seminim mungkin memicu dialog ganda, dengan fallback packet standar
local function dropItemSafe(itemID, count)
    local beforeCnt = getInvCount(itemID)
    if beforeCnt <= 0 or count <= 0 then
        return false, 0, beforeCnt
    end
    local wantDrop = math.min(count, beforeCnt)

    if growtopia and growtopia.confirmDropItem then
        pcall(growtopia.confirmDropItem, itemID, wantDrop)
        local droppedNative, afterNative = waitInvDecrease(itemID, beforeCnt, 1400)
        if droppedNative > 0 then
            return true, droppedNative, afterNative
        end
    end
    if growtopia and growtopia.dropItem and wantDrop == 1 then
        pcall(growtopia.dropItem, itemID)
        local droppedOne, afterOne = waitInvDecrease(itemID, beforeCnt, 900)
        if droppedOne > 0 then
            return true, droppedOne, afterOne
        end
    end

    local prevSuppress = STATE.suppress_dialog
    STATE.suppress_dialog = true

    local prevSeq = STATE.last_dialog_seq or 0
    sendPacket(2, "action|drop\n|itemID|" .. tostring(itemID))
    safeSleep(180)

    local dropped = 0
    local afterCnt = beforeCnt
    if STATE.runtime_hooks_installed and (STATE.last_dialog_seq or 0) > prevSeq then
        local raw = STATE.last_dialog_text or ""
        local dName = STATE.last_dialog_name or ""
        if dName == "drop" or dName == "drop_item" or raw:find("drop", 1, true) then
            local pktStr = buildDialogReturn(raw, "drop_item", nil, nil, { count = tostring(wantDrop) }, nil, nil)
            sendPacket(2, pktStr)
            dropped, afterCnt = waitInvDecrease(itemID, beforeCnt, 800)
        end
    end

    if dropped <= 0 then
        for _, dlgName in ipairs({ "drop_item", "drop" }) do
            sendPacket(2, string.format(
                "action|dialog_return\ndialog_name|%s\nitemID|%d|\ncount|%d\n",
                dlgName, itemID, wantDrop
            ))
            dropped, afterCnt = waitInvDecrease(itemID, beforeCnt, 700)
            if dropped > 0 then break end
        end
    end

    STATE.suppress_dialog = prevSuppress
    return (dropped > 0), dropped, afterCnt
end

-- Wrench tile dan tunggu OnDialogRequest asli dari server lewat hook onvariant
local function wrenchAndAwaitDialog(tx, ty, expectedDialogName, standX, standY)
    ensureRuntimeHooks()
    if standX and standY and isTileSafeToStand(standX, standY) then
        moveSafeTo(standX, standY)
    else
        moveAdjacentSafe(tx, ty, 1)
    end
    local prevSeq = STATE.last_dialog_seq or 0
    sendRawAction(tx, ty, ITEM.WRENCH)

    local waited = 0
    while waited < 1600 do
        safeSleep(40)
        waited = waited + 40
        if (STATE.last_dialog_seq or 0) > prevSeq then
            local raw = STATE.last_dialog_text or ""
            local dName = STATE.last_dialog_name or ""
            if (not expectedDialogName) or dName == expectedDialogName or raw:find(expectedDialogName, 1, true) then
                return true, raw
            end
        end
    end
    return false, ""
end

-- Validated Edit Door ID & Label (tunggu OnDialogRequest, kirim dialog_return exact fields, lalu verifikasi)
local function validateAndEditDoorTile(tx, ty, doorID, doorLabel, standX, standY)
    local targetID = tostring(doorID or "DF123")
    local targetLabel = tostring(doorLabel or "BOREN STORE")
    STATE.suppress_dialog = true

    local validated = false
    for attempt = 1, 3 do
        if not waitIfPaused() then break end
        local ok, t = pcall(getTile, tx, ty)
        if not ok or not t or t.fg == 0 then
            break
        end

        local gotDlg, dlgText = wrenchAndAwaitDialog(tx, ty, "door_edit", standX, standY)
        if gotDlg then
            local meta = parseDialogFields(dlgText)
            local lockedLabel = (meta.checkbox_labels.checkbox_locked or ""):lower()
            -- Di Growtopia: "Is open to public" -> 1 agar Player + Door ID bisa masuk; jika label server "Locked/Private" -> 0
            local openBit = (lockedLabel:find("open", 1, true) or lockedLabel:find("public", 1, true) or lockedLabel == "") and "1" or "0"
            local pktStr = buildDialogReturn(
                dlgText,
                "door_edit",
                tx, ty,
                { door_name = targetLabel, door_target = "", door_id = targetID },
                { checkbox_locked = openBit },
                nil
            )
            sendPacket(2, pktStr)
            safeSleep(550)

            local gotV, verifyText = wrenchAndAwaitDialog(tx, ty, "door_edit", standX, standY)
            local okV, tV = pcall(getTile, tx, ty)
            local vMeta = gotV and parseDialogFields(verifyText) or nil
            if (okV and tV and tV.extra and tV.extra.label == targetLabel) or
               (vMeta and vMeta.inputs.door_name == targetLabel and vMeta.inputs.door_id == targetID) then
                validated = true
                break
            end
        else
            -- Fallback bila server/APK tidak memicu onVariant OnDialogRequest
            sendPacket(2, string.format(
                "action|dialog_return\ndialog_name|door_edit\ntilex|%d|\ntiley|%d|\ndoor_name|%s\ndoor_target|\ndoor_id|%s\ncheckbox_locked|1\n",
                tx, ty, targetLabel, targetID
            ))
            safeSleep(600)
            local okV, tV = pcall(getTile, tx, ty)
            if okV and tV and tV.extra and tV.extra.label == targetLabel then
                validated = true
                break
            end
        end
    end

    STATE.suppress_dialog = false
    addLog(string.format("Validasi Door ID (%d, %d) -> ID='%s' Label='%s' [%s]", tx, ty, targetID, targetLabel, validated and "OK" or "WARN"))
    return validated
end

-- Validated Edit World Lock (WL): Set Public = ON (checkbox_public = 1) & verify
local function validateAndEditWorldLock(tx, ty, isPublic, standX, standY)
    local pubBit = isPublic and "1" or "0"
    STATE.suppress_dialog = true

    local validated = false
    for attempt = 1, 4 do
        if not waitIfPaused() then break end
        local ok, t = pcall(getTile, tx, ty)
        if not ok or not t or t.fg ~= ITEM.WORLD_LOCK then
            break
        end

        local gotDlg, dlgText = wrenchAndAwaitDialog(tx, ty, "lock_edit", standX, standY)
        if gotDlg then
            local meta = parseDialogFields(dlgText)
            if meta.checkboxes.checkbox_public == pubBit then
                validated = true
                break
            end
            local pktStr = buildDialogReturn(
                dlgText,
                "lock_edit",
                tx, ty,
                nil,
                { checkbox_public = pubBit },
                nil
            )
            sendPacket(2, pktStr)
            safeSleep(550)

            local gotVerify, verifyText = wrenchAndAwaitDialog(tx, ty, "lock_edit", standX, standY)
            local vMeta = gotVerify and parseDialogFields(verifyText) or nil
            if vMeta and vMeta.checkboxes.checkbox_public == pubBit then
                validated = true
                break
            end
        else
            sendPacket(2, string.format(
                "action|dialog_return\ndialog_name|lock_edit\ntilex|%d|\ntiley|%d|\ncheckbox_public|%s\ncheckbox_disable_music|0\ntempo|100\ncheckbox_disable_music_render|0\ncheckbox_set_as_home_world|0\nminimum_entry_level|1\n",
                tx, ty, pubBit
            ))
            safeSleep(600)
            if attempt >= 2 then
                validated = true
                break
            end
        end
    end

    STATE.suppress_dialog = false
    addLog(string.format("Validasi WL (%d, %d) -> Public=%s [%s]", tx, ty, tostring(isPublic), validated and "OK" or "WARN"))
    return validated
end

-- Validated Edit Small Lock (SL): Set Public = OFF (0), Ignore Empty Air = ON (1), AND Apply Lock (recalcLock)
local function validateAndApplySmallLock(tx, ty, ignoreAir, isPublic, standX, standY)
    local pubBit = isPublic and "1" or "0"
    local ignBit = ignoreAir and "1" or "0"
    STATE.suppress_dialog = true

    local validated = false
    for attempt = 1, 4 do
        if not waitIfPaused() then break end
        local ok, t = pcall(getTile, tx, ty)
        if not ok or not t or t.fg ~= ITEM.SMALL_LOCK then
            break
        end

        local gotDlg, dlgText = wrenchAndAwaitDialog(tx, ty, "lock_edit", standX, standY)
        if gotDlg then
            -- Step 1: Simpan checkbox_public & checkbox_ignore terlebih dulu
            local step1Pkt = buildDialogReturn(
                dlgText,
                "lock_edit",
                tx, ty,
                nil,
                { checkbox_public = pubBit, checkbox_ignore = ignBit },
                nil
            )
            sendPacket(2, step1Pkt)
            safeSleep(450)

            -- Step 2: Wrench lagi, lalu trigger tombol Re-apply Lock (recalcLock) dengan checkbox tetap aktif
            local gotDlg2, dlgText2 = wrenchAndAwaitDialog(tx, ty, "lock_edit", standX, standY)
            local dlgForRecalc = gotDlg2 and dlgText2 or dlgText
            local meta2 = parseDialogFields(dlgForRecalc)
            local recalcBtn = "recalcLock"
            if not meta2.buttons[recalcBtn] then
                for bName, _ in pairs(meta2.buttons) do
                    if bName:lower():find("recalc", 1, true) then
                        recalcBtn = bName
                        break
                    end
                end
            end
            local step2Pkt = buildDialogReturn(
                dlgForRecalc,
                "lock_edit",
                tx, ty,
                nil,
                { checkbox_public = pubBit, checkbox_ignore = ignBit },
                recalcBtn
            )
            sendPacket(2, step2Pkt)
            safeSleep(550)

            -- Step 3: Verifikasi hasil checkbox tersimpan benar
            local gotVerify, verifyText = wrenchAndAwaitDialog(tx, ty, "lock_edit", standX, standY)
            local vMeta = gotVerify and parseDialogFields(verifyText) or nil
            if vMeta and vMeta.checkboxes.checkbox_ignore == ignBit and vMeta.checkboxes.checkbox_public == pubBit then
                validated = true
                break
            end
        else
            -- Fallback bila OnDialogRequest tidak tertangkap hook
            sendPacket(2, string.format(
                "action|dialog_return\ndialog_name|lock_edit\ntilex|%d|\ntiley|%d|\ncheckbox_public|%s\ncheckbox_ignore|%s\n",
                tx, ty, pubBit, ignBit
            ))
            safeSleep(450)
            sendPacket(2, string.format(
                "action|dialog_return\ndialog_name|lock_edit\ntilex|%d|\ntiley|%d|\nbuttonClicked|recalcLock\ncheckbox_public|%s\ncheckbox_ignore|%s\n",
                tx, ty, pubBit, ignBit
            ))
            safeSleep(600)
            if attempt >= 2 then
                validated = true
                break
            end
        end
    end

    STATE.suppress_dialog = false
    addLog(string.format("Validasi SL (%d, %d) -> IgnoreAir=%s, Public=%s + Apply Lock [%s]", tx, ty, tostring(ignoreAir), tostring(isPublic), validated and "OK" or "WARN"))
    return validated
end

-- ============================================================================
-- 7. INSPECT EXISTING WORLD SECURITY & STORAGE MANAGEMENT
-- ============================================================================

-- Inspect whether the current world ALREADY has WL, SL, Jammer, Door ID, and Blocker Doors installed
local function inspectWorldSecurityState(doorX, doorY)
    local info = {
        has_wl            = false,
        has_sl            = false,
        has_jammer        = false,
        has_id_door       = false,
        has_left_blocker  = false,
        has_left_dirt     = false,
        all_ready         = false,
    }
    if not doorX or not doorY then return info end

    -- 1. Check WL at (doorX + 1, doorY) [kanan White Door sesuai Gambar 1]
    if doorX + 1 <= 99 then
        local ok, t = pcall(getTile, doorX + 1, doorY)
        if ok and t and (t.fg == ITEM.WORLD_LOCK or OTHER_LOCKS[t.fg]) then
            info.has_wl = true
        end
    end

    -- 2. Check SL at (doorX, doorY - 1) [tepat di atas White Door]
    if doorY - 1 >= 0 then
        local ok, t = pcall(getTile, doorX, doorY - 1)
        if ok and t and t.fg == ITEM.SMALL_LOCK then
            info.has_sl = true
        end
    end

    -- 3. Check Jammer at (doorX - 1, doorY - 1) [kiri-atas White Door]
    if doorX - 1 >= 0 and doorY - 1 >= 0 then
        local ok, t = pcall(getTile, doorX - 1, doorY - 1)
        if ok and t and t.fg == ITEM.JAMMER then
            info.has_jammer = true
        end
    end

    -- 4. Check Door ID at (0, 0) [pojok kiri paling atas sesuai Gambar 2]
    do
        local ok, t = pcall(getTile, 0, 0)
        if ok and t and (t.fg == CFG.id_door_itemid or KNOWN_ID_DOOR_IDS[t.fg]) then
            info.has_id_door = true
        end
    end

    -- 5. Check Left Blocker at (doorX - 1, doorY) [hanya sisi kiri White Door]
    if doorX - 1 >= 0 then
        local ok, t = pcall(getTile, doorX - 1, doorY)
        if ok and t and (t.fg == CFG.blocker_door_itemid or KNOWN_BLOCKER_IDS[t.fg]) then
            info.has_left_blocker = true
        end
    end

    -- 6. Check Left Dirt at (doorX - 1, doorY + 1)
    if doorX - 1 >= 0 then
        local ok, t = pcall(getTile, doorX - 1, doorY + 1)
        if ok and t and t.fg ~= 0 then
            info.has_left_dirt = true
        end
    end

    local wlOk  = (not CFG.use_wl) or info.has_wl
    local slOk  = (not CFG.use_sl) or info.has_sl
    local jamOk = (not CFG.use_jammer) or info.has_jammer
    local idOk  = (not CFG.use_id_door) or info.has_id_door
    local blkOk = (not CFG.use_blocker_door) or info.has_left_blocker

    info.all_ready = (wlOk and slOk and jamOk and idOk and blkOk)
    return info
end

local function countDroppedAtTile(tx, ty)
    local objs = getWorldObjectsSafe()
    if not objs then return 0 end
    local total = 0
    for _, obj in pairs(objs) do
        if obj and obj.pos then
            local ox = math.floor((obj.pos.x + 10) / 32)
            local oy = math.floor((obj.pos.y + 10) / 32)
            if ox == tx and oy == ty then
                total = total + (obj.amount or 1)
            end
        end
    end
    return total
end

local function getConfiguredSaveItemList()
    local list = {}
    local seen = {}
    local function addUnique(id)
        if id and id > 0 and not seen[id] then
            seen[id] = true
            table.insert(list, id)
        end
    end
    if CFG.save_dirt_seed then addUnique(ITEM.DIRT_SEED) end
    if CFG.save_cave_seed then addUnique(ITEM.CAVE_SEED) end
    if CFG.save_lava_seed then addUnique(ITEM.LAVA_SEED) end
    if CFG.save_rock_seed then addUnique(ITEM.ROCK_SEED) end
    if CFG.save_lava_block then addUnique(ITEM.LAVA) end
    if CFG.use_custom_save and CFG.custom_save_itemid and CFG.custom_save_itemid > 0 then
        addUnique(CFG.custom_save_itemid)
    end
    return list
end

getConfiguredTrashItemList = function()
    local list = {}
    local seen = {}
    for tok in tostring(CFG.trash_list_str or "4,14,10"):gmatch("%d+") do
        local id = tonumber(tok)
        if id and id > 0 and not seen[id] then
            seen[id] = true
            table.insert(list, math.floor(id))
        end
    end
    return list
end

setTrashListFromTable = function(list)
    local parts = {}
    for _, id in ipairs(list) do
        table.insert(parts, tostring(id))
    end
    CFG.trash_list_str = table.concat(parts, ",")
end

local function isDropTileOpen(tx, ty)
    if tx < 1 or tx > 98 or ty < 0 or ty > 53 then return false end
    local ok, t = pcall(getTile, tx, ty)
    if not ok or not t then return true end
    return (not t.collidable) and t.fg ~= ITEM.BEDROCK and t.fg ~= ITEM.MAIN_DOOR and (not OTHER_LOCKS[t.fg])
end

local function countStacksAtTile(tx, ty)
    local objs = getWorldObjectsSafe()
    if not objs then return 0 end
    local stacks = 0
    for _, obj in pairs(objs) do
        if obj and obj.pos then
            local ox = math.floor((obj.pos.x + 10) / 32)
            local oy = math.floor((obj.pos.y + 10) / 32)
            if ox == tx and oy == ty then
                stacks = stacks + 1
            end
        end
    end
    return stacks
end

local function dropItemsAtOpenSpots(itemsToSave, anchorX, anchorY, minOffset, maxOffset, forceAll, isLocalDF)
    -- Scan spot drop dari TERJAUH ke TERDEKAT (mundur menuju anchor) agar karakter tidak menginjak hasil drop
    local candidateSpots = {}
    for offset = maxOffset, minOffset, -1 do
        local dx = math.min(98, anchorX + offset)
        table.insert(candidateSpots, { dropX = dx, standX = dx - 1, faceState = 32 })
    end
    for offset = maxOffset, minOffset, -1 do
        local dx = math.max(1, anchorX - offset)
        table.insert(candidateSpots, { dropX = dx, standX = dx + 1, faceState = 48 })
    end

    local droppedTiles = {}
    for _, itemID in ipairs(itemsToSave) do
        local beforeBP = getInvCount(itemID)
        local remaining = 0
        if isLocalDF then
            if beforeBP >= 200 then
                remaining = beforeBP
            end
        else
            remaining = beforeBP
            if itemID == ITEM.DIRT_SEED and not forceAll and beforeBP > 60 then
                remaining = beforeBP - 50
            end
        end

        if remaining > 0 then
            local failedTries = 0
            local totalDroppedItem = 0
            for _, spot in ipairs(candidateSpots) do
                if remaining <= 0 or failedTries >= 4 then break end
                local standKey = tostring(spot.standX) .. "," .. tostring(anchorY)
                if (not droppedTiles[standKey]) and isDropTileOpen(spot.dropX, anchorY) and isTileSafeToStand(spot.standX, anchorY)
                   and countDroppedAtTile(spot.dropX, anchorY) < 180 and countStacksAtTile(spot.dropX, anchorY) < 18 then
                    setAutoCollectActive(false)
                    if moveSafeTo(spot.standX, anchorY) then
                        safeSleep(220)
                        local okP, p = pcall(getLocal)
                        local px = (okP and p and (p.posX or (p.pos and p.pos.x))) or (spot.standX * 32)
                        local py = (okP and p and (p.posY or (p.pos and p.pos.y))) or (anchorY * 32)
                        sendPacketRaw(false, {
                            type  = 0,
                            state = spot.faceState,
                            x     = px,
                            y     = py
                        })
                        safeSleep(160)

                        local okDrop, droppedNow, afterBP = dropItemSafe(itemID, remaining)
                        if okDrop and droppedNow > 0 then
                            remaining = remaining - droppedNow
                            totalDroppedItem = totalDroppedItem + droppedNow
                            local dropKey = tostring(spot.dropX) .. "," .. tostring(anchorY)
                            droppedTiles[dropKey] = true
                            if isLocalDF then
                                STATE.df_dropped_spots[dropKey] = true
                            end
                            addLog(string.format("%s OK: Drop %d %s (Sisa BP: %d) di (%d, %d)", isLocalDF and "Drop DF (BP 200)" or "Validasi BP", droppedNow, resolveItemName(itemID), afterBP, spot.dropX, anchorY))
                        else
                            failedTries = failedTries + 1
                            addLog(string.format("Drop %s di (%d, %d) belum mengurangi BP (Stok BP: %d), pindah spot...", resolveItemName(itemID), spot.dropX, anchorY, afterBP))
                        end
                    end
                end
            end

            if totalDroppedItem == 0 then
                local warnMsg = string.format("Gagal save %s! Stok BP masih %d (cek akses lock/spot kosong).", resolveItemName(itemID), getInvCount(itemID))
                addLog(warnMsg)
                if sendNotification then pcall(sendNotification, warnMsg) end
            end
        end
    end

    if isTileSafeToStand(anchorX, anchorY) then
        moveSafeTo(anchorX, anchorY)
        safeSleep(150)
    end
end

local function hasAnyDroppedBackupInDF()
    if next(STATE.df_dropped_spots) == nil then return false end
    local objs = getWorldObjectsSafe()
    if not objs then return false end
    for _, obj in pairs(objs) do
        if obj and obj.pos then
            local ox = math.floor((obj.pos.x + 10) / 32)
            local oy = math.floor((obj.pos.y + 10) / 32)
            if STATE.df_dropped_spots[tostring(ox) .. "," .. tostring(oy)] then
                return true
            end
        end
    end
    return false
end

local function collectBackupDropsFromDF(filterItemID)
    if next(STATE.df_dropped_spots) == nil then return 0 end
    local objs = getWorldObjectsSafe()
    if not objs then return 0 end

    local spotsList = {}
    for spotKey, _ in pairs(STATE.df_dropped_spots) do
        local sx, sy = spotKey:match("^([^,]+),([^,]+)$")
        if sx and sy then
            table.insert(spotsList, { x = tonumber(sx), y = tonumber(sy), key = spotKey })
        end
    end

    local collectedAny = 0
    for _, spot in ipairs(spotsList) do
        local matchedHere = false
        local stillHasOther = false
        for _, obj in pairs(objs) do
            if obj and obj.pos and obj.id then
                local ox = math.floor((obj.pos.x + 10) / 32)
                local oy = math.floor((obj.pos.y + 10) / 32)
                if ox == spot.x and oy == spot.y then
                    if (not filterItemID or obj.itemid == filterItemID) and getInvCount(obj.itemid) < 200 then
                        matchedHere = true
                    else
                        stillHasOther = true
                    end
                end
            end
        end
        if matchedHere then
            -- Buka sementara spotKey agar collectNearbyFloating mau mengambil cadangan dari DF
            STATE.df_dropped_spots[spot.key] = nil
            moveSafeTo(spot.x, spot.y)
            safeSleep(120)
            local objsNow = getWorldObjectsSafe() or {}
            local okP, p = pcall(getLocal)
            local charX = (okP and p and p.posX) or (spot.x * 32)
            local charY = (okP and p and p.posY) or (spot.y * 32)
            for _, obj in pairs(objsNow) do
                if obj and obj.pos and obj.id then
                    local ox = math.floor((obj.pos.x + 10) / 32)
                    local oy = math.floor((obj.pos.y + 10) / 32)
                    if ox == spot.x and oy == spot.y and (not filterItemID or obj.itemid == filterItemID) and getInvCount(obj.itemid) < 200 then
                        pcall(sendPacketRaw, false, {
                            type  = 11,
                            value = obj.id,
                            x     = charX,
                            y     = charY,
                        })
                        collectedAny = collectedAny + 1
                        safeSleep(45)
                    end
                end
            end
            if stillHasOther then
                STATE.df_dropped_spots[spot.key] = true
            end
        end
    end
    return collectedAny
end

local function saveSeedsToStorage(returnWorld, returnDoor, forceAll)
    local itemsToSave = getConfiguredSaveItemList()
    local hasStorageWorld = (CFG.storage_seed_world ~= "")

    -- Poin 1:
    -- - Saat DF masih diproses (forceAll = false):
    --   * Cave Seed, Lava Seed, Rock Seed, Lava Block, dll langsung di-save ke Storage Seed sejak awal saat >= threshold.
    --   * Khusus Dirt Seed & Dirt Block TIDAK dibawa ke Storage dulu — bila BP penuh (>= 200), di-drop di world DF dulu agar nanti diambil buat plant/place sampai DF selesai!
    -- - Setelah semua DF selesai (forceAll = true): seluruh sisa seed termasuk Dirt Seed ikut di-save ke Storage Seed.
    local storageBatch = {}
    local dfBackupBatch = {}
    local dirtInBackup = false

    for _, id in ipairs(itemsToSave) do
        local cnt = getInvCount(id)
        if id == ITEM.DIRT_SEED and (not forceAll) then
            if cnt >= 200 then
                table.insert(dfBackupBatch, id)
            end
        else
            if hasStorageWorld then
                if (forceAll and cnt > 0) or (cnt >= CFG.save_seed_threshold) then
                    table.insert(storageBatch, id)
                end
            elseif cnt >= 200 then
                table.insert(dfBackupBatch, id)
                if id == ITEM.DIRT then dirtInBackup = true end
            end
        end
    end

    if (not forceAll) and (not dirtInBackup) and getInvCount(ITEM.DIRT) >= 200 then
        table.insert(dfBackupBatch, ITEM.DIRT)
    end

    if #storageBatch == 0 and #dfBackupBatch == 0 then
        return true
    end

    STATE.saving_storage = true
    setAutoCollectActive(false)

    -- 1. Drop cadangan Dirt Seed (atau item saat Storage kosong) di world DF dulu
    if #dfBackupBatch > 0 then
        local statusTxt = hasStorageWorld
            and "Dirt Seed penuh (200) -> Drop di DF dulu sampai selesai DF"
            or "Storage Seed kosong -> Drop item 200 di DF (Collect OFF)"
        setStatus("Drop Cadangan DF", statusTxt)
        local doorX, doorY = findMainDoor()
        if not doorX or not doorY then
            doorX, doorY = getPlayerTilePos()
        end
        if not doorX then doorX, doorY = 50, 23 end
        dropItemsAtOpenSpots(dfBackupBatch, doorX, doorY, 3, 12, false, true)
    end

    -- 2. Simpan item non-DirtSeed (atau semua item saat forceAll=true) ke World Storage Seed
    if #storageBatch > 0 and hasStorageWorld then
        setStatus("Save Seed/Block", "Collect OFF -> Menuju Storage Seed: " .. CFG.storage_seed_world)

        local function restoreAndReturn()
            if returnWorld and returnWorld ~= "" and getWorldNameSafe() ~= returnWorld then
                setStatus("Kembali ke DF", "Menuju " .. returnWorld)
                warpTo(returnWorld, returnDoor or "")
                safeSleep(1000)
            end
            STATE.saving_storage = false
            setAutoCollectActive(CFG.auto_collect)
        end

        if getWorldNameSafe() ~= CFG.storage_seed_world then
            if not warpTo(CFG.storage_seed_world, CFG.storage_seed_door) then
                addLog("Gagal warp ke Storage Seed!")
                STATE.saving_storage = false
                setAutoCollectActive(CFG.auto_collect)
                return false
            end
            safeSleep(1000)
        end
        setAutoCollectActive(false)

        local startX, startY = getPlayerTilePos()
        if not startX then startX, startY = 10, 23 end
        dropItemsAtOpenSpots(storageBatch, startX, startY, 1, 8, forceAll, false)

        restoreAndReturn()
        return true
    end

    STATE.saving_storage = false
    setAutoCollectActive(CFG.auto_collect)
    return true
end

-- Uji Coba Drop manual langsung dari Menu 3. Storage (Auto Collect OFF + Anti Collect ON + Validasi BP)
local function testDropCustomSaveItem()
    local targetID = (CFG.custom_save_itemid and CFG.custom_save_itemid > 0) and CFG.custom_save_itemid or ITEM.DIRT_SEED
    local itemName = resolveItemName(targetID)
    local beforeBP = getInvCount(targetID)
    if beforeBP <= 0 then
        local msg = string.format("Stok %s (ID %d) di Backpack kosong (0)!", itemName, targetID)
        addLog("Coba Drop -> " .. msg)
        if sendNotification then pcall(sendNotification, msg) end
        return false
    end

    local function execDrop()
        STATE.saving_storage = true
        setAutoCollectActive(false)
        safeSleep(150)

        local okDrop, dropped, afterBP = dropItemSafe(targetID, beforeBP)
        safeSleep(300)

        -- Jangan nyalakan Auto Collect langsung di tempat drop supaya hasil tes drop tidak tersedot balik
        STATE.saving_storage = false

        if okDrop and dropped > 0 then
            local msg = string.format("Berhasil Drop %dx %s! (BP: %d -> %d) [Collect OFF]", dropped, itemName, beforeBP, afterBP)
            addLog("Coba Drop OK -> " .. msg)
            if sendNotification then pcall(sendNotification, msg) end
        else
            setAutoCollectActive(CFG.auto_collect)
            local msg = string.format("Gagal Drop %s! (Stok BP tetap %d)", itemName, afterBP)
            addLog("Coba Drop GAGAL -> " .. msg)
            if sendNotification then pcall(sendNotification, msg) end
        end
    end

    if runCoroutine then
        pcall(runCoroutine, execDrop)
    else
        execDrop()
    end
    return true
end

local function checkTrashAndSeeds(currentWorld, currentDoor)
    if CFG.auto_trash_junk then
        local junkItems = getConfiguredTrashItemList()
        local thresh = math.max(10, tonumber(CFG.trash_threshold) or 150)
        for _, jid in ipairs(junkItems) do
            local cnt = getInvCount(jid)
            if cnt >= thresh then
                addLog(string.format("Auto-Trash %s (%d >= %d)", resolveItemName(jid), cnt, thresh))
                trashItem(jid, cnt)
            end
        end
    end
    saveSeedsToStorage(currentWorld, currentDoor, false)
end

-- Helper: Bangun pesan Request alat/door yang kurang secara spesifik & kirim notifikasi
local function notifyToolRequest(title, message)
    setStatus(title, message)
    if sendNotification then
        pcall(sendNotification, message)
    end
    if growtopia and growtopia.notify then
        pcall(growtopia.notify, message)
    end
    if sendDialog then
        pcall(sendDialog, { title = title, alias = "boren_df_req", message = message, confirm = "OK" })
    end
end

-- Only require tools that are NOT yet placed in the current world
local function ensureToolsFromStorage(existingSec, returnWorld, returnDoor)
    -- 1. Validasi konfigurasi Door ID & Door Penghalang sudah dipilih
    if CFG.use_id_door then
        if not CFG.id_door_itemid or CFG.id_door_itemid <= 0 then
            notifyToolRequest("Pilih Door ID", "Silakan pilih Item Door ID terlebih dahulu di menu '2. Lock & Door'!")
            return false
        end
        if tostring(CFG.door_id or ""):gsub("%s+", "") == "" then
            notifyToolRequest("Isi ID Door", "Silakan isi Target ID Door di menu '2. Lock & Door'!")
            return false
        end
    end
    if CFG.use_blocker_door then
        if not CFG.blocker_door_itemid or CFG.blocker_door_itemid <= 0 then
            notifyToolRequest("Pilih Door Penghalang", "Silakan pilih Item Door Penghalang terlebih dahulu di menu '2. Lock & Door'!")
            return false
        end
    end

    local needed = {}
    local neededOrder = {}
    local neededRoles = {}
    local function addNeed(id, count, roleLabel)
        if not id or id <= 0 then return end
        if not needed[id] then
            table.insert(neededOrder, id)
            neededRoles[id] = roleLabel
        else
            neededRoles[id] = neededRoles[id] .. " & " .. roleLabel
        end
        needed[id] = (needed[id] or 0) + count
    end

    if CFG.use_wl and not (existingSec and existingSec.has_wl) then
        addNeed(ITEM.WORLD_LOCK, 1, "WL")
    end
    if CFG.use_sl and not (existingSec and existingSec.has_sl) then
        addNeed(ITEM.SMALL_LOCK, 1, "SL")
    end
    if CFG.use_jammer and not (existingSec and existingSec.has_jammer) then
        addNeed(ITEM.JAMMER, 1, "Jammer")
    end
    if CFG.use_id_door and not (existingSec and existingSec.has_id_door) then
        addNeed(CFG.id_door_itemid, 1, "Door ID")
    end
    if CFG.use_blocker_door then
        if not (existingSec and existingSec.has_left_blocker) then
            addNeed(CFG.blocker_door_itemid, 1, "Penghalang Kiri")
        end
    end

    local function collectMissingText()
        local missingParts = {}
        local needDoorPickHint = false
        for _, needID in ipairs(neededOrder) do
            local reqAmt = needed[needID]
            local curAmt = getInvCount(needID)
            if curAmt < reqAmt then
                local diff = reqAmt - curAmt
                local role = neededRoles[needID] or ""
                table.insert(missingParts, string.format("%s (%s) x%d", role, resolveItemName(needID), diff))
                if role:find("Door") then
                    needDoorPickHint = true
                end
            end
        end
        return missingParts, needDoorPickHint
    end

    local missingBefore, doorHintBefore = collectMissingText()
    if #missingBefore == 0 then
        return true
    end

    local missingStr = table.concat(missingBefore, ", ")
    addLog("Request Alat dibutuhkan: " .. missingStr)

    if CFG.storage_pack_world == "" then
        local hint = doorHintBefore and " Atau silakan pilih Door ID / Door Penghalang lain di menu Lock & Door." or ""
        notifyToolRequest(
            "Request Alat Kurang",
            "Request: Kurang " .. missingStr .. "! Siapkan di tas atau isi World Storage Alat." .. hint
        )
        return false
    end

    -- Matikan Auto Collect & nyalakan Anti Collect SEBELUM warp ke Storage Alat agar warpTo() tidak menyalakan Auto Collect di dalam Storage!
    STATE.saving_storage = true
    setAutoCollectActive(false)

    setStatus("Ambil Alat", "Mengambil " .. missingStr .. " di Storage: " .. CFG.storage_pack_world)
    if not warpTo(CFG.storage_pack_world, CFG.storage_pack_door) then
        STATE.saving_storage = false
        setAutoCollectActive(CFG.auto_collect)
        notifyToolRequest("Error Warp Storage", "Gagal masuk ke Storage Alat: " .. CFG.storage_pack_world .. " (Request: " .. missingStr .. ")")
        return false
    end
    setAutoCollectActive(false)
    safeSleep(1100)

    -- Tahap 1: Ambil seluruh alat yang kurang dulu (pakai koordinat obj.pos), jangan drop dulu supaya tidak terinjak saat jalan ke stack lain
    local objs = getWorldObjectsSafe()
    if objs then
        for _, needID in ipairs(neededOrder) do
            local reqAmt = needed[needID]
            if getInvCount(needID) < reqAmt then
                for _, obj in pairs(objs) do
                    if obj and obj.itemid == needID and obj.pos and obj.id then
                        local ox = math.floor((obj.pos.x + 10) / 32)
                        local oy = math.floor((obj.pos.y + 10) / 32)
                        addLog(string.format("Mengambil %s di (%d, %d) [Butuh %dx]", resolveItemName(needID), ox, oy, reqAmt))
                        moveSafeTo(ox, oy)
                        safeSleep(300)
                        setAutoCollectActive(false)
                        pcall(sendPacketRaw, false, {
                            type  = 11,
                            value = obj.id,
                            x     = obj.pos.x,
                            y     = obj.pos.y,
                        })
                        safeSleep(380)
                        if getInvCount(needID) >= reqAmt then
                            break
                        end
                    end
                end
            end
        end
    end

    -- Tahap 2: Drop SEMUA kelebihan alat sekaligus di spot terbuka dari terjauh -> mundur mendekat (jangan pernah berjalan melewati tile hasil drop!)
    local doorX, doorY = findMainDoor()
    local curPx, curPy = getPlayerTilePos()
    local anchorX = doorX or curPx or 50
    local anchorY = doorY or curPy or 23

    local function dropAllToolExcessInStorage()
        local hasExcess = false
        for _, needID in ipairs(neededOrder) do
            if getInvCount(needID) > needed[needID] then
                hasExcess = true
                break
            end
        end
        if not hasExcess then return end

        local candidateSpots = {}
        -- Urut terjauh ke terdekat (kanan mundur ke kiri, lalu kiri mundur ke kanan) agar langkah selanjutnya selalu menjauh dari hasil drop
        for offset = 12, 1, -1 do
            local dxR = math.min(98, anchorX + offset)
            local sxR = dxR - 1
            if sxR >= 1 then
                table.insert(candidateSpots, { dropX = dxR, standX = sxR, faceState = 32 })
            end
        end
        for offset = 12, 1, -1 do
            local dxL = math.max(1, anchorX - offset)
            local sxL = dxL + 1
            if sxL <= 98 then
                table.insert(candidateSpots, { dropX = dxL, standX = sxL, faceState = 48 })
            end
        end

        local usedDropTiles = {}
        for _, needID in ipairs(neededOrder) do
            local reqAmt = needed[needID]
            local curAmt = getInvCount(needID)
            if curAmt > reqAmt then
                for _, spot in ipairs(candidateSpots) do
                    local nowAmt = getInvCount(needID)
                    local excess = nowAmt - reqAmt
                    if excess <= 0 then break end
                    local dKey = tostring(spot.dropX) .. "," .. tostring(anchorY)
                    if (not usedDropTiles[dKey]) and isDropTileOpen(spot.dropX, anchorY) and isTileSafeToStand(spot.standX, anchorY)
                       and countStacksAtTile(spot.dropX, anchorY) < 18 then
                        setAutoCollectActive(false)
                        moveSafeTo(spot.standX, anchorY)
                        safeSleep(220)
                        local apx, apy = getPlayerTilePos()
                        -- Pastikan karakter BENAR-BENAR berdiri di standX (tidak di dropX akibat toleransi +-1 FindPath!)
                        if apx ~= spot.standX or apy ~= anchorY then
                            if FindPath then pcall(FindPath, spot.standX, anchorY) end
                            safeSleep(200)
                            apx, apy = getPlayerTilePos()
                        end
                        if apx == spot.standX and apy == anchorY then
                            local okP, p = pcall(getLocal)
                            local cpx = (okP and p and (p.posX or (p.pos and p.pos.x))) or (spot.standX * 32)
                            local cpy = (okP and p and (p.posY or (p.pos and p.pos.y))) or (anchorY * 32)
                            sendPacketRaw(false, { type = 0, state = spot.faceState, x = cpx, y = cpy })
                            safeSleep(160)
                            local okDrop, droppedNow, afterBP = dropItemSafe(needID, excess)
                            if okDrop and droppedNow > 0 then
                                usedDropTiles[dKey] = true
                                addLog(string.format("Drop sisa %s x%d di (%d,%d) [berdiri %d] -> BP pas: %d/%d", resolveItemName(needID), droppedNow, spot.dropX, anchorY, spot.standX, afterBP, reqAmt))
                            end
                            safeSleep(180)
                        end
                    end
                end

                -- Fallback darurat bila semua spot samping terhalang
                local remExcess = getInvCount(needID) - reqAmt
                if remExcess > 0 then
                    setAutoCollectActive(false)
                    dropItemSafe(needID, remExcess)
                    safeSleep(180)
                end
            end
        end
    end

    dropAllToolExcessInStorage()

    local missingAfter, doorHintAfter = collectMissingText()
    if #missingAfter > 0 then
        local afterStr = table.concat(missingAfter, ", ")
        local hint = doorHintAfter and " Silakan pilih item Door ID / Penghalang yang ada di tas." or ""
        STATE.saving_storage = false
        setAutoCollectActive(CFG.auto_collect)
        notifyToolRequest(
            "Request Stok Alat",
            "Request: Kurang " .. afterStr .. " di Storage Alat!" .. hint
        )
        return false
    end

    if returnWorld and returnWorld ~= "" then
        warpTo(returnWorld, returnDoor or "")
        safeSleep(1000)
    end
    -- Pulihkan Auto Collect HANYA SETELAH keluar dari Storage Alat agar sisa alat tidak terhisap kembali
    STATE.saving_storage = false
    setAutoCollectActive(CFG.auto_collect)
    return true
end

-- ============================================================================
-- 8. WORLD SELECTION (MANUAL LIST, AUTO-ADD INPUT, OR RANDOM WORLD FINDER)
-- ============================================================================

local function generateRandomWorldName(length, useNumbers)
    local chars = useNumbers and "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" or "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local res = {}
    for i = 1, length do
        local idx = math.random(1, #chars)
        res[i] = chars:sub(idx, idx)
    end
    return table.concat(res)
end

local function isCurrentWorldUsableForRandom()
    local ok, tiles = pcall(getTiles)
    if not ok or not tiles then return false, "Tile belum termuat" end

    for _, t in pairs(tiles) do
        if t and OTHER_LOCKS[t.fg] then
            return false, "Sudah ada Lock (" .. resolveItemName(t.fg) .. ")"
        end
    end

    local okPl, players = pcall(getPlayerList)
    local okLoc, myLocal = pcall(getLocal)
    if okPl and players and okLoc and myLocal then
        for _, p in pairs(players) do
            if p and p.netID ~= myLocal.netID then
                return false, "Ada player lain (" .. tostring(p.name) .. ")"
            end
        end
    end

    local dx, dy = findMainDoor()
    if not dx or not dy then
        return false, "Main Door tidak ditemukan"
    end

    return true, "World kosong & siap dibuat DF"
end

local function readGLString(alias, fallback)
    if getValue then
        for _, vtype in ipairs({ 2, 5 }) do
            local ok, val = pcall(getValue, vtype, alias)
            if ok and type(val) == "string" and val ~= "" then
                return val
            end
        end
    end
    return fallback
end

local function readGLBool(alias, fallback)
    if getValue then
        local ok, val = pcall(getValue, 0, alias)
        if ok and type(val) == "boolean" then
            return val
        end
    end
    return fallback
end

local function resolvePickedItemID(value)
    if type(value) == "table" then
        value = value.id or value.itemID or value.itemid or value.value or value.name
    end
    local num = tonumber(value)
    if num and num > 0 then
        return math.floor(num)
    end
    if type(value) == "string" and value ~= "" then
        if findItemID then
            local ok, id = pcall(findItemID, value)
            if ok and tonumber(id) and tonumber(id) > 0 then return tonumber(id) end
        end
        if growtopia and growtopia.getItemID then
            local ok, id = pcall(growtopia.getItemID, value)
            if ok and tonumber(id) and tonumber(id) > 0 then return tonumber(id) end
        end
    end
    return nil
end

local function syncInputsFromGL()
    local wIn = readGLString("df_manual_world_input", "")
    if wIn ~= "" then
        STATE.buf_world_name = wIn:upper()
        CFG.manual_world_text = STATE.buf_world_name
    end
    local dIn = readGLString("df_manual_door_input", "")
    if dIn ~= "" then
        STATE.buf_world_door = dIn
        CFG.manual_door_text = dIn
    end
    local packW = readGLString("df_pack_w", "")
    if packW ~= "" then CFG.storage_pack_world = packW:upper() end
    local packD = readGLString("df_pack_d", "")
    if packD ~= "" then CFG.storage_pack_door = packD end
    local seedW = readGLString("df_seed_w", "")
    if seedW ~= "" then CFG.storage_seed_world = seedW:upper() end
    local seedD = readGLString("df_seed_d", "")
    if seedD ~= "" then CFG.storage_seed_door = seedD end
    local dId = readGLString("df_door_id", "")
    if dId ~= "" then CFG.door_id = dId end
    local dLbl = readGLString("df_door_label", "")
    if dLbl ~= "" then CFG.door_label = dLbl end
    CFG.world_mode = readGLBool("df_world_random", CFG.world_mode == "random") and "random" or "manual"
    local rTgt = tonumber(readGLString("df_random_target", ""))
    if rTgt and rTgt >= 1 then CFG.random_target_count = math.floor(rTgt) end
    local wFile = readGLString("df_world_file", "")
    if wFile ~= "" then CFG.world_file_name = wFile end
end

local function acquireTargetWorld()
    syncInputsFromGL()

    -- Setelah Auto Reconnect dari disconnect, langsung masuk ulang world terakhir agar proses DF dijalankan ulang dari awal
    if STATE.resume_world_override and STATE.resume_world_override ~= "" then
        local rw = STATE.resume_world_override
        local rd = STATE.resume_door_override or ""
        STATE.resume_world_override = nil
        STATE.resume_door_override = nil
        STATE.active_world = rw
        STATE.active_door = rd
        local mIdx = nil
        for idx, entry in ipairs(CFG.world_list) do
            if entry.name == rw and (not entry.done) then
                mIdx = idx
                break
            end
        end
        if getWorldNameSafe() ~= rw then
            warpTo(rw, rd)
            safeSleep(800)
        end
        return rw, rd, mIdx
    end

    if CFG.world_mode == "manual" then
        local hasPending = false
        for _, entry in ipairs(CFG.world_list) do
            if not entry.done then
                hasPending = true
                break
            end
        end

        -- Jika list world masih kosong total, otomatis ambil dari input manual atau world saat ini
        if #CFG.world_list == 0 and STATE.buf_world_name ~= "" then
            addManualWorldsFromString(STATE.buf_world_name, STATE.buf_world_door, false)
            hasPending = (#CFG.world_list > 0)
        end
        if not hasPending and #CFG.world_list == 0 then
            local curW = getWorldNameSafe()
            if curW ~= "" and curW ~= "EXIT" and curW ~= "START" then
                addLog("List world kosong, otomatis memakai world saat ini: " .. curW)
                addManualWorldsFromString(curW, STATE.buf_world_door, false)
            end
        end

        for idx, entry in ipairs(CFG.world_list) do
            if not entry.done then
                STATE.active_world = entry.name
                STATE.active_door = entry.door or ""
                setStatus("Masuk World", "Menuju " .. entry.name)
                if not warpTo(entry.name, entry.door) then
                    if not ensureOnlineInWorld(entry.name, entry.door) then
                        return nil, nil, nil
                    end
                end
                safeSleep(1000)
                return entry.name, entry.door, idx
            end
        end

        STATE.active_world = ""
        STATE.active_door = ""
        local msg = (#CFG.world_list == 0)
            and "List world kosong! Isi Nama World atau nyalakan Mode Random."
            or "Semua world di list sudah selesai! Tambah world baru atau Reset."
        setStatus("Info World", msg)
        if sendNotification then pcall(sendNotification, msg) end
        return nil, nil, nil
    else
        local targetCount = math.max(1, math.floor(tonumber(CFG.random_target_count) or 5))
        if (STATE.random_done_count or 0) >= targetCount then
            local doneMsg = string.format("Target Find Random selesai (%d/%d world DONE)!", STATE.random_done_count, targetCount)
            STATE.active_world = ""
            STATE.active_door = ""
            setStatus("Target Random Selesai", doneMsg)
            addLog(doneMsg)
            if sendNotification then pcall(sendNotification, doneMsg) end
            return nil, nil, nil
        end

        -- Cek bila ada hasil find random sebelumnya yang statusnya belum DONE (lanjutkan dulu sebelum cari baru)
        for idx, entry in ipairs(CFG.world_list) do
            if (not entry.done) and entry.from_random then
                entry.status = "PROSES"
                STATE.active_world = entry.name
                STATE.active_door = entry.door or ""
                if updateWorldDisplayList then pcall(updateWorldDisplayList) end
                setStatus("Lanjut Random World", string.format("%s (%d/%d)", entry.name, (STATE.random_done_count or 0) + 1, targetCount))
                if not warpTo(entry.name, entry.door) then
                    if not ensureOnlineInWorld(entry.name, entry.door) then
                        return nil, nil, nil
                    end
                end
                safeSleep(1000)
                return entry.name, entry.door, idx
            end
        end

        local attempt = 0
        while STATE.running and attempt < 30 do
            if not waitIfPaused() then return nil, nil, nil end
            attempt = attempt + 1
            local candidate = generateRandomWorldName(CFG.random_length, CFG.random_use_numbers)
            setStatus("Find Random World", string.format("Cek #%d: %s (Target %d/%d)", attempt, candidate, (STATE.random_done_count or 0) + 1, targetCount))
            if warpTo(candidate, "") then
                safeSleep(1200)
                local usable, reason = isCurrentWorldUsableForRandom()
                if usable then
                    addLog("Ditemukan World: " .. candidate .. " (" .. reason .. ") -> Disimpan ke List!")
                    local newDoor = (CFG.use_id_door and CFG.door_id ~= "") and CFG.door_id or ""
                    local listIdx = nil
                    for idx, existing in ipairs(CFG.world_list) do
                        if existing.name == candidate then
                            existing.door = newDoor
                            existing.done = false
                            existing.status = "PROSES"
                            existing.from_random = true
                            listIdx = idx
                            break
                        end
                    end
                    if not listIdx then
                        table.insert(CFG.world_list, {
                            name = candidate,
                            door = newDoor,
                            done = false,
                            status = "PROSES",
                            from_random = true,
                        })
                        listIdx = #CFG.world_list
                    end
                    persistConfig()
                    if updateWorldDisplayList then pcall(updateWorldDisplayList) end
                    return candidate, newDoor, listIdx
                else
                    addLog("Skip " .. candidate .. ": " .. reason)
                end
            end
        end
        setStatus("Gagal Find World", "Tidak menemukan world kosong setelah 30 percobaan.")
        return nil, nil, nil
    end
end

-- ============================================================================
-- 9. DIRT FARM CONSTRUCTION STAGES (GAMBAR 2 + VALIDATION + AUTO-RESUME)
-- ============================================================================

-- Stage A: Setup Locks, Jammer, Door ID & 2 Blocker Doors EXACTLY like contoh benar (dengan moat Empty Air di sekeliling & bawah WL/Bedrock)
-- If already installed in the world, skips re-placing and continues DF directly!
local function setupWorldLocks(doorX, doorY, existingSec)
    local sec = existingSec or inspectWorldSecurityState(doorX, doorY)
    if sec.all_ready then
        addLog("Deteksi World: Semua Lock, Jammer & Door sudah terpasang! Langsung lanjut proses DF...")
        if sendNotification then pcall(sendNotification, "Lock & Jammer sudah ada! Lanjut DF...") end
        return CFG.use_id_door and CFG.door_id or ""
    end

    setStatus("Setup Lock & Moat", string.format("Break dirt sekitar Main Door (%d, %d) sesuai susunan Gambar 1", doorX, doorY))

    -- Helper internal: hanya break jika bukan Bedrock, Main Door, atau Lock/Blocker yang sudah terpasang
    local function isKeptSecurityTile(tx, ty)
        if tx == doorX and ty == doorY then return true end
        if tx == doorX and ty == doorY + 1 then return true end
        if sec.has_sl and tx == doorX and ty == doorY - 1 then return true end
        if sec.has_wl and tx == doorX + 1 and ty == doorY then return true end
        if sec.has_jammer and tx == doorX - 1 and ty == doorY - 1 then return true end
        if sec.has_left_blocker and tx == doorX - 1 and ty == doorY then return true end
        return false
    end

    -- 0A. Break RING LUAR (Moat 1-tile Empty Air: fg=0 & bg=0) mengelilingi cluster Lock (termasuk kanan-atas & kanan-bawah WL)
    for my = doorY - 2, doorY + 2 do
        for mx = doorX - 2, doorX + 2 do
            local isOuterRing = (math.abs(mx - doorX) == 2 or math.abs(my - doorY) == 2)
            local isLeftBedrock = (mx == doorX - 1 and my == doorY + 1)
            local isRightAboveWL = (mx == doorX + 1 and my == doorY - 1)
            local isRightBelowWL = (mx == doorX + 1 and my == doorY + 1)
            if (isOuterRing or isLeftBedrock or isRightAboveWL or isRightBelowWL) and mx >= 0 and mx <= 99 and my >= 0 and my <= 59 then
                if not isKeptSecurityTile(mx, my) then
                    local prefDir = (mx <= doorX) and -1 or 1
                    breakTileCompletely(mx, my, true, true, prefDir)
                end
            end
        end
    end

    -- 0B. Bersihkan slot dalam Gambar 1 yang BELUM terisi item yang sesuai
    local innerToPrepare = {}
    if not sec.has_sl then table.insert(innerToPrepare, {doorX, doorY - 1, true}) end
    if not sec.has_wl then table.insert(innerToPrepare, {doorX + 1, doorY, true}) end
    if not sec.has_jammer then table.insert(innerToPrepare, {doorX - 1, doorY - 1, true}) end
    if not sec.has_left_blocker then table.insert(innerToPrepare, {doorX - 1, doorY, true}) end

    for _, c in ipairs(innerToPrepare) do
        local cx, cy, clearBg = c[1], c[2], c[3]
        if cx >= 0 and cx <= 99 and cy >= 0 and cy <= 59 then
            breakTileCompletely(cx, cy, true, clearBg, 1)
        end
    end

    -- 1. Pasang & Validasi Penghalang Kiri di (doorX - 1, doorY) (sisi kanan tidak pakai blocker, langsung WL)
    if CFG.use_blocker_door then
        if doorX - 1 >= 0 and not sec.has_left_blocker then
            setStatus("Pasang Penghalang Kiri", string.format("Menaruh %s di (%d, %d)", resolveItemName(CFG.blocker_door_itemid), doorX - 1, doorY))
            placeAndValidateSecurityTile(doorX - 1, doorY, CFG.blocker_door_itemid, "Penghalang Kiri", doorX - 2, doorY)
        end
    end

    -- 2. Pasang & Validasi Signal Jammer di (doorX - 1, doorY - 1) + Punch 1x agar Jammer aktif
    if CFG.use_jammer and doorX - 1 >= 0 then
        if not sec.has_jammer then
            setStatus("Pasang Jammer", string.format("Menaruh Signal Jammer di (%d, %d)", doorX - 1, doorY - 1))
            local jamPlaced = placeAndValidateSecurityTile(doorX - 1, doorY - 1, ITEM.JAMMER, "Signal Jammer", doorX - 1, math.max(0, doorY - 2))
            if jamPlaced then
                safeSleep(300)
                sendRawAction(doorX - 1, doorY - 1, ITEM.PUNCH)
                safeSleep(350)
                addLog(string.format("Validasi Jammer OK: Signal Jammer aktif di (%d, %d)", doorX - 1, doorY - 1))
            end
        else
            addLog("Signal Jammer sudah terpasang di world ini.")
        end
    end

    -- 3. Pasang & Validasi World Lock (WL) di kanan White Door (doorX + 1, doorY) + Set PUBLIC
    if CFG.use_wl and doorX + 1 <= 99 then
        if not sec.has_wl then
            setStatus("Pasang WL", string.format("Menaruh & Set Public WL di (%d, %d)", doorX + 1, doorY))
            placeAndValidateSecurityTile(doorX + 1, doorY, ITEM.WORLD_LOCK, "World Lock (WL)", doorX + 2, doorY)
        end
        validateAndEditWorldLock(doorX + 1, doorY, CFG.wl_public, doorX + 2, doorY)
    end

    -- 4. Pasang & Apply Small Lock (SL) Private di atas White Door (doorX, doorY - 1)
    if CFG.use_sl then
        if doorY - 2 >= 0 then
            breakTileCompletely(doorX, doorY - 2, true, true, 1)
        end
        if not sec.has_sl then
            setStatus("Pasang Small Lock (Private)", string.format("Menaruh SL di (%d, %d)", doorX, doorY - 1))
            placeAndValidateSecurityTile(doorX, doorY - 1, ITEM.SMALL_LOCK, "Small Lock (SL)", doorX, math.max(0, doorY - 2))
        end
        setStatus("Apply Small Lock", "Set Private + Ignore Empty Air + Re-apply Lock")
        validateAndApplySmallLock(doorX, doorY - 1, CFG.sl_ignore_air, CFG.sl_public, doorX, math.max(0, doorY - 2))
    end

    -- 5. Jeda Tele + Fly ke pojok kiri atas (0, 0) untuk pasang & edit Door ID (Gambar 2)
    local activeDoorID = ""
    if CFG.use_id_door then
        local teleWait = math.max(300, tonumber(CFG.delay_tele_door) or 1500)
        setStatus("Jeda Tele Door (0,0)", string.format("Jeda %d ms sebelum Fly ke (0, 0) untuk pasang Door ID...", teleWait))
        safeSleep(teleWait)
        if editToggle then pcall(editToggle, "ModFly", true) end
        safeSleep(150)

        if not sec.has_id_door then
            setStatus("Pasang Door ID (0,0)", string.format("Fly ke pojok kiri atas & menaruh %s di (0, 0)", resolveItemName(CFG.id_door_itemid)))
            breakTileCompletely(0, 0, true, false, 1)
            placeAndValidateSecurityTile(0, 0, CFG.id_door_itemid, "Door ID (0,0)", 1, 0)
            safeSleep(300)
        end
        validateAndEditDoorTile(0, 0, CFG.door_id, CFG.door_label, 1, 0)
        safeSleep(250)
        activeDoorID = CFG.door_id

        if editToggle then pcall(editToggle, "ModFly", CFG.use_modfly == true) end
    end

    return activeDoorID
end

-- Helper: Amankan Lava di bawah kaki target & tile tempat berdiri (x + dirX, y + 1) sebelum melangkah/break
local function sanitizeLavaUnderFoot(x, y, doorX, doorY, dirX)
    if y >= 53 then return end
    local belowY = y + 1
    local checkXs = { x }
    local standX = x + (dirX or -1)
    if standX >= 0 and standX <= 99 then
        table.insert(checkXs, standX)
    end
    for _, cx in ipairs(checkXs) do
        if not isProtectedEnclosure(cx, belowY, doorX, doorY) then
            local ok, belowTile = pcall(getTile, cx, belowY)
            if ok and belowTile and belowTile.fg == ITEM.LAVA then
                breakTileCompletely(cx, belowY, true, false, dirX)
                if belowY % 2 == 0 and (not isInSecurityMoat(cx, belowY, doorX, doorY)) and getInvCount(ITEM.DIRT) > 0 then
                    placeTileAt(cx, belowY, ITEM.DIRT, false, dirX)
                end
            end
        end
    end
end

-- Helper: Tentukan start/end/step zig-zag secara seragam agar tidak duplikasi
local function zigZagRange(goingRight, minV, maxV, stepAbs)
    local s = stepAbs or 1
    if goingRight then
        return minV, maxV, s
    end
    return maxV, minV, -s
end

local function isEdgePlatformTile(tx, ty, doorX, doorY)
    if not CFG.use_platform then return false end
    if ty < 2 or ty > 52 or (ty % 2 ~= 0) then return false end
    if (not CFG.build_upper) and ty < 24 then return false end
    if isInSecurityMoat(tx, ty, doorX, doorY) then return false end
    return (CFG.plat_left and tx == 1) or (CFG.plat_right and tx == 98)
end

-- Helper: Kolom pinggir yang dibersihkan & batas X baris DF berdasarkan setting Platform
-- Jika use_platform == false: kiri 1 baris (x = 0) & kanan 1 baris (x = 99), baris DF penuh x = 1..98
-- Jika use_platform == true: sisi yang dipasang platform butuh 2 baris (kiri: 1,0 | kanan: 98,99)
local function getSideColumns()
    if not CFG.clear_sides then return {} end
    if not CFG.use_platform then
        return { 0, 99 }
    end
    local cols = {}
    if CFG.plat_left then
        table.insert(cols, 1)
        table.insert(cols, 0)
    else
        table.insert(cols, 0)
    end
    if CFG.plat_right then
        table.insert(cols, 98)
        table.insert(cols, 99)
    else
        table.insert(cols, 99)
    end
    return cols
end

local function getDFRowBounds()
    if not CFG.use_platform then
        return 1, 98
    end
    local minX = CFG.plat_left and 2 or 1
    local maxX = CFG.plat_right and 97 or 98
    return minX, maxX
end

-- Helper: Cek apakah foreground/tile aman untuk dibersihkan bot (bukan Bedrock, Main Door, Lock, atau Jammer)
local function isTileClearableByBot(t)
    if not t then return false end
    return t.fg ~= ITEM.BEDROCK and t.fg ~= ITEM.MAIN_DOOR and (not OTHER_LOCKS[t.fg]) and t.fg ~= ITEM.JAMMER
end

-- Helper: Cek apakah 1 tile pada baris ganjil perlu di-break
local function isOddTileClearNeeded(tx, ty, doorX, doorY)
    if isProtectedEnclosure(tx, ty, doorX, doorY) then return false end
    if isEdgePlatformTile(tx, ty, doorX, doorY) then return false end
    local ok, t = pcall(getTile, tx, ty)
    if not ok or not t or not isTileClearableByBot(t) then return false end
    local needFg = (t.fg ~= 0)
    local needBg = CFG.break_cave_bg and (t.bg ~= 0)
    return needFg or needBg, needFg, needBg
end

-- Helper: Cek cepat apakah seluruh desain clear DF (baris ganjil 25..53 & pinggir) sudah bersih agar tidak maksa break lagi
local function isDFOddClearAlreadyDone(doorX, doorY)
    local sideCols = getSideColumns()
    for _, colX in ipairs(sideCols) do
        for y = 24, 53 do
            if (not isProtectedEnclosure(colX, y, doorX, doorY)) and (not isEdgePlatformTile(colX, y, doorX, doorY)) then
                local ok, t = pcall(getTile, colX, y)
                if ok and isTileClearableByBot(t) and (t.fg ~= 0 or (CFG.break_cave_bg and t.bg ~= 0)) then
                    return false
                end
            end
        end
    end
    local rowMinX, rowMaxX = getDFRowBounds()
    for y = 25, 53, 2 do
        for x = rowMinX, rowMaxX do
            if isOddTileClearNeeded(x, y, doorX, doorY) then
                return false
            end
        end
    end
    return true
end

-- Helper: Berdiri tetap di baris tengah centerY & hancurkan sampai 3 tile vertikal (y, y-2, y+2) + Lava di y-1/y+1 tanpa lompat
local function standAndBreak3AtCol(worldName, activeDoorID, doorX, doorY, x, centerY, safeStandDir)
    local standX = math.max(0, math.min(99, x + safeStandDir))
    -- Pastikan tempat berdiri (standX, centerY) & tile di bawahnya aman dari Lava/Dirt sebelum melangkah ke standX
    if (not isProtectedEnclosure(standX, centerY, doorX, doorY)) and isOddTileClearNeeded(standX, centerY, doorX, doorY) then
        local needS, nFgS, nBgS = isOddTileClearNeeded(standX, centerY, doorX, doorY)
        if needS then
            breakTileCompletely(standX, centerY, nFgS, nBgS, safeStandDir, true)
        end
    end
    sanitizeLavaUnderFoot(x, centerY, doorX, doorY, safeStandDir)

    local px, py = getPlayerTilePos()
    if (not px) or py ~= centerY or math.abs(px - x) > 2 or (px == x and py == centerY) or (not isTileSafeToStand(px, py)) then
        if isTileSafeToStand(standX, centerY) then
            moveSafeTo(standX, centerY)
        else
            moveAdjacentSafe(x, centerY, safeStandDir)
        end
    end

    local targets = { centerY, centerY - 2, centerY + 2 }
    for _ = 1, 2 do
        local anyRemaining = false
        for _, ty in ipairs(targets) do
            local need, nFg, nBg = isOddTileClearNeeded(x, ty, doorX, doorY)
            if need then
                anyRemaining = true
                local cpx, cpy = getPlayerTilePos()
                if (not cpx) or math.abs(cpx - x) > 2 or math.abs(cpy - ty) > 2 then
                    if isTileSafeToStand(standX, centerY) then
                        moveSafeTo(standX, centerY)
                    end
                end
                breakTileCompletely(x, ty, nFg, nBg, safeStandDir, true)
            end
        end
        -- Bersihkan juga Lava pada baris genap bersebelahan (y - 1 dan y + 1) selagi karakter tepat berada di sebelah kolom x
        if CFG.break_lava then
            for _, lavaY in ipairs({ centerY - 1, centerY + 1 }) do
                if lavaY >= 24 and lavaY <= 52 and (not isProtectedEnclosure(x, lavaY, doorX, doorY)) then
                    local okL, tL = pcall(getTile, x, lavaY)
                    if okL and tL and tL.fg == ITEM.LAVA then
                        anyRemaining = true
                        breakTileCompletely(x, lavaY, true, false, safeStandDir, true)
                        if (not isInSecurityMoat(x, lavaY, doorX, doorY)) and getInvCount(ITEM.DIRT) > 0 then
                            placeTileAt(x, lavaY, ITEM.DIRT, false, safeStandDir)
                        end
                    end
                end
            end
        end
        if not anyRemaining then break end
    end

    if CFG.auto_collect then
        collectNearbyFloating(x, centerY, CFG.collect_range, true)
    end
    checkTrashAndSeeds(worldName, activeDoorID)
end

-- Helper: Deteksi & bersihkan ulang tile yang tertinggal saat break akibat lag (0 ms bila sudah bersih, max 4 pass + fallback langsung per-tile)
local function sweepRemainingBreakTiles(worldName, activeDoorID, doorX, doorY, checkEvenPlatRockLava, forceDirectMode)
    local rowMinX, rowMaxX = getDFRowBounds()
    local sideCols = getSideColumns()
    for pass = 1, 4 do
        if pass > 1 then
            safeSleep(100)
        end
        local totalLeftover = 0
        local sideLeftover = {}
        for _, colX in ipairs(sideCols) do
            for y = 24, 53 do
                if (not isProtectedEnclosure(colX, y, doorX, doorY)) and (not isEdgePlatformTile(colX, y, doorX, doorY)) then
                    local ok, t = pcall(getTile, colX, y)
                    if ok and isTileClearableByBot(t) then
                        local needFg = (t.fg ~= 0)
                        local needBg = CFG.break_cave_bg and (t.bg ~= 0)
                        if needFg or needBg then
                            table.insert(sideLeftover, { x = colX, y = y, fg = needFg, bg = needBg, dir = (colX < 50) and 1 or -1 })
                            totalLeftover = totalLeftover + 1
                        end
                    end
                end
            end
        end

        local oddLeftoverFlat = {}
        local oddGroups3 = {}
        if CFG.break_3_mode and pass == 1 and (not forceDirectMode) then
            local goingRightSweep = true
            local centerRows = { 27, 33, 39, 45, 51 }
            for _, centerY in ipairs(centerRows) do
                local startX, endX, stepX = zigZagRange(goingRightSweep, rowMinX, rowMaxX, 1)
                local safeStandDir = -stepX
                for x = startX, endX, stepX do
                    local colMiss = 0
                    for _, ty in ipairs({ centerY, centerY - 2, centerY + 2 }) do
                        if isOddTileClearNeeded(x, ty, doorX, doorY) then
                            colMiss = colMiss + 1
                        end
                    end
                    if colMiss > 0 then
                        table.insert(oddGroups3, { x = x, centerY = centerY, dir = safeStandDir })
                        totalLeftover = totalLeftover + colMiss
                    end
                end
                goingRightSweep = not goingRightSweep
            end
        else
            -- Pass >= 2 (atau mode 1-tile): hampiri langsung setiap sisa tile yang bandel agar pasti tuntas meski jalur centerY terhalang
            for y = 25, 53, 2 do
                for x = rowMinX, rowMaxX do
                    local need, needFg, needBg = isOddTileClearNeeded(x, y, doorX, doorY)
                    if need then
                        table.insert(oddLeftoverFlat, { x = x, y = y, fg = needFg, bg = needBg, dir = -1 })
                        totalLeftover = totalLeftover + 1
                    end
                end
            end
        end

        local evenLeftover = {}
        if checkEvenPlatRockLava and (CFG.break_lava or CFG.break_rock) then
            for y = 24, 52, 2 do
                for x = rowMinX, rowMaxX do
                    if not isInSecurityMoat(x, y, doorX, doorY) then
                        local ok, t = pcall(getTile, x, y)
                        if ok and isTileClearableByBot(t) then
                            if (t.fg == ITEM.LAVA and CFG.break_lava) or (t.fg == ITEM.ROCK and CFG.break_rock) then
                                table.insert(evenLeftover, { x = x, y = y, fg = true, bg = false, dir = -1 })
                                totalLeftover = totalLeftover + 1
                            end
                        end
                    end
                end
            end
        end

        if totalLeftover == 0 then
            if pass > 1 then
                addLog("Deteksi Lag Break OK: Semua tile tertinggal sudah bersih (0 tersisa)!")
            end
            return true
        end

        setStatus("Deteksi Lag Break", string.format("Sweep #%d: %d tile tertinggal di %s, lanjut break...", pass, totalLeftover, worldName))
        for _, grp in ipairs(oddGroups3) do
            if not waitIfPaused() then return false end
            if not ensureOnlineInWorld(worldName, activeDoorID) then return false end
            standAndBreak3AtCol(worldName, activeDoorID, doorX, doorY, grp.x, grp.centerY, grp.dir)
        end
        for _, cellList in ipairs({ sideLeftover, oddLeftoverFlat, evenLeftover }) do
            for _, cell in ipairs(cellList) do
                if not waitIfPaused() then return false end
                if not ensureOnlineInWorld(worldName, activeDoorID) then return false end
                if cell.y >= 25 then
                    sanitizeLavaUnderFoot(cell.x, cell.y, doorX, doorY, cell.dir)
                end
                moveAdjacentSafe(cell.x, cell.y, cell.dir)
                breakTileCompletely(cell.x, cell.y, cell.fg, cell.bg, cell.dir)
                checkTrashAndSeeds(worldName, activeDoorID)
            end
        end
    end
    return true
end

-- Stage B: Clear Side Columns (x = 0,99 bila platform false; 2 kolom bila platform aktif) and Alternating Rows (Mode 1 Tile / Mode 3 Tile)
local function clearWorldDirtFarm(worldName, activeDoorID, doorX, doorY)
    if isDFOddClearAlreadyDone(doorX, doorY) then
        -- Desain DF clear sudah terbentuk (seperti Gambar 2): tidak perlu buang waktu clear sisa Rock di platform, langsung lanjut Plant/Harvest & Place DF!
        addLog("Desain DF sudah terbentuk! Skip clear sisa Rock & langsung lanjut place DF...")
        return true
    end

    local rowMinX, rowMaxX = getDFRowBounds()
    local sideCols = getSideColumns()

    do
        if #sideCols > 0 then
            -- Bersihkan kolom pinggir dengan jeda antar kolom & per-tile agar tidak kena rate-limit/ercon.
            local prevColX = nil
            local sideBrokenCount = 0
            local sideDelay = math.max(0, tonumber(CFG.delay_clear_sides) or 120)
            for _, colX in ipairs(sideCols) do
                if not ensureOnlineInWorld(worldName, activeDoorID) then return false end
                if prevColX ~= nil then
                    if (prevColX <= 1 and colX >= 98) or (prevColX >= 98 and colX <= 1) then
                        safeSleep(math.max(650, sideDelay * 4))
                    else
                        safeSleep(math.max(400, sideDelay * 2))
                    end
                end
                prevColX = colX
                setStatus("Clear Pinggir", string.format("Membersihkan kolom pinggir x = %d", colX))
                for y = 24, 53 do
                    if not waitIfPaused() then return false end
                    if (not isProtectedEnclosure(colX, y, doorX, doorY)) and (not isEdgePlatformTile(colX, y, doorX, doorY)) then
                        local ok, t = pcall(getTile, colX, y)
                        if ok and t and t.fg ~= ITEM.BEDROCK and t.fg ~= ITEM.MAIN_DOOR then
                            local hasFg = (t.fg ~= 0)
                            local hasBg = CFG.break_cave_bg and (t.bg ~= 0)
                            if hasFg or hasBg then
                                local prefDir = (colX < 50) and 1 or -1
                                if breakTileCompletely(colX, y, hasFg, hasBg, prefDir) then
                                    sideBrokenCount = sideBrokenCount + 1
                                    if sideDelay > 0 then safeSleep(sideDelay) end
                                    if sideBrokenCount % 8 == 0 then safeSleep(200) end
                                end
                                checkTrashAndSeeds(worldName, activeDoorID)
                            end
                        end
                    end
                end
            end
        end

        local goingRight = true
        if CFG.break_3_mode then
            -- Mode Break 3 Tile (Gambar 1): jalan di baris tengah {27, 33, 39, 45, 51}, break y-2, y, dan y+2 sekaligus!
            local centerRows = { 27, 33, 39, 45, 51 }
            for _, centerY in ipairs(centerRows) do
                if not ensureOnlineInWorld(worldName, activeDoorID) then return false end
                local dxNow, dyNow = findMainDoor()
                if dxNow and dyNow then doorX, doorY = dxNow, dyNow end

                local startX, endX, stepX = zigZagRange(goingRight, rowMinX, rowMaxX, 1)
                local safeStandDir = -stepX

                setStatus("Break 3 Tile", string.format("World: %s | Baris Y = %d,%d,%d", worldName, centerY - 2, centerY, centerY + 2))
                for x = startX, endX, stepX do
                    if not waitIfPaused() then return false end
                    local anyNeed = false
                    for _, ty in ipairs({ centerY, centerY - 2, centerY + 2 }) do
                        if isOddTileClearNeeded(x, ty, doorX, doorY) then
                            anyNeed = true
                            break
                        end
                    end
                    if (not anyNeed) and CFG.break_lava then
                        for _, ly in ipairs({ centerY - 1, centerY + 1 }) do
                            if ly >= 24 and ly <= 52 and (not isProtectedEnclosure(x, ly, doorX, doorY)) then
                                local okL, tL = pcall(getTile, x, ly)
                                if okL and tL and tL.fg == ITEM.LAVA then
                                    anyNeed = true
                                    break
                                end
                            end
                        end
                    end
                    if anyNeed then
                        standAndBreak3AtCol(worldName, activeDoorID, doorX, doorY, x, centerY, safeStandDir)
                    end
                end
                goingRight = not goingRight
            end
        else
            -- Mode Break 1 Tile: break 1 baris ganjil per jalan
            for y = 25, 53, 2 do
                if not ensureOnlineInWorld(worldName, activeDoorID) then return false end
                local dxNow, dyNow = findMainDoor()
                if dxNow and dyNow then doorX, doorY = dxNow, dyNow end

                local startX, endX, stepX = zigZagRange(goingRight, rowMinX, rowMaxX, 1)
                local safeStandDir = -stepX

                setStatus("Break Baris Kosong", string.format("World: %s | Baris Y = %d", worldName, y))
                for x = startX, endX, stepX do
                    if not waitIfPaused() then return false end
                    local need, nFg, nBg = isOddTileClearNeeded(x, y, doorX, doorY)
                    if need then
                        sanitizeLavaUnderFoot(x, y, doorX, doorY, safeStandDir)
                        breakTileCompletely(x, y, nFg, nBg, safeStandDir)
                        checkTrashAndSeeds(worldName, activeDoorID)
                    end
                end
                goingRight = not goingRight
            end
        end
    end

    -- Deteksi cepat apakah masih ada tile pinggir/baris ganjil yang tertinggal karena lag saat break
    if not sweepRemainingBreakTiles(worldName, activeDoorID, doorX, doorY, false) then
        return false
    end

    -- Baris Platform Genap Bawah (24..52): HANYA break Lava (jika aktif) & Rock (jika df_break_rock aktif); put dilakukan batch 3 tile di buildUpperPlatforms
    if CFG.break_lava or CFG.break_rock then
        local goingRightPlat = true
        for y = 24, 52, 2 do
            if not ensureOnlineInWorld(worldName, activeDoorID) then return false end
            local dxNow, dyNow = findMainDoor()
            if dxNow and dyNow then doorX, doorY = dxNow, dyNow end

            local rowHasBreakTarget = false
            for x = rowMinX, rowMaxX do
                if not isInSecurityMoat(x, y, doorX, doorY) then
                    local ok, t = pcall(getTile, x, y)
                    if ok and isTileClearableByBot(t) and ((t.fg == ITEM.LAVA and CFG.break_lava) or (t.fg == ITEM.ROCK and CFG.break_rock)) then
                        rowHasBreakTarget = true
                        break
                    end
                end
            end

            if rowHasBreakTarget then
                local startX, endX, stepX = zigZagRange(goingRightPlat, rowMinX, rowMaxX, 1)
                local safeStandDir = -stepX
                setStatus("Rapikan Baris Platform", string.format("World: %s | Baris Y = %d", worldName, y))
                for x = startX, endX, stepX do
                    if not waitIfPaused() then return false end
                    if not isInSecurityMoat(x, y, doorX, doorY) then
                        local ok, t = pcall(getTile, x, y)
                        if ok and isTileClearableByBot(t) then
                            if (t.fg == ITEM.LAVA and CFG.break_lava) or (t.fg == ITEM.ROCK and CFG.break_rock) then
                                breakTileCompletely(x, y, true, false, safeStandDir)
                            end
                        end
                    end
                end
            end
            goingRightPlat = not goingRightPlat
        end
    end

    -- Validasi akhir break DF (termasuk baris genap Lava/Rock yg mungkin terlewat akibat lag)
    if not sweepRemainingBreakTiles(worldName, activeDoorID, doorX, doorY, true) then
        return false
    end

    return true
end

-- Helper: Hitung berapa tile platform yang masih kosong (sesuai area build, exclude Security Moat)
local function countMissingDirtPlatforms(doorX, doorY)
    local rowMinX, rowMaxX = getDFRowBounds()
    local missing = 0
    for y = 24, 52, 2 do
        for x = rowMinX, rowMaxX do
            if not isInSecurityMoat(x, y, doorX, doorY) then
                local ok, t = pcall(getTile, x, y)
                if ok and t and t.fg == 0 then
                    missing = missing + 1
                end
            end
        end
    end
    if CFG.build_upper then
        for y = 2, 22, 2 do
            for x = rowMinX, rowMaxX do
                if not isInSecurityMoat(x, y, doorX, doorY) then
                    local ok, t = pcall(getTile, x, y)
                    if ok and t and t.fg == 0 then
                        missing = missing + 1
                    end
                end
            end
        end
    end
    return missing
end

-- Harvest 1 pohon Dirt matang dengan validasi fg == 0 (tahan lag) lalu wajib take hasil dropnya
local function harvestDirtTreeAt(tx, ty)
    for round = 1, 3 do
        if not waitIfPaused() then return false end
        local ok, t = pcall(getTile, tx, ty)
        if not ok or not t or t.fg ~= ITEM.DIRT_SEED then
            break
        end
        local px, py = getPlayerTilePos()
        if (not px) or math.abs(px - tx) > 2 or math.abs(py - ty) > 2 then
            moveSafeTo(tx, ty)
        end
        for _ = 1, 2 do
            if not waitIfPaused() then return false end
            local okStep, tStep = pcall(getTile, tx, ty)
            if not okStep or not tStep or tStep.fg ~= ITEM.DIRT_SEED then
                break
            end
            sendRawAction(tx, ty, ITEM.PUNCH)
            safeSleep(CFG.delay_break)
        end
        if awaitTileLayerCleared(tx, ty, true, 220) then
            break
        end
    end
    -- Beri jeda singkat untuk paket WorldObject drop server lalu wajib hampiri & take
    moveSafeTo(tx, ty)
    safeSleep(60)
    collectNearbyFloating(tx, ty, math.max(3, CFG.collect_range or 3), false, true)
    local okEnd, tEnd = pcall(getTile, tx, ty)
    return (not okEnd) or (not tEnd) or (tEnd.fg ~= ITEM.DIRT_SEED)
end

-- Stage C: Auto Plant & Harvest Dirt Seeds (Harvest Take) untuk mengumpulkan Dirt Block bahan bentuk DF
local function farmDirtUntilEnough(worldName, activeDoorID, doorX, doorY)
    if not CFG.auto_farm_dirt then return true end

    local farmRowY = 23
    local rowMinX, rowMaxX = getDFRowBounds()
    while STATE.running do
        if not waitIfPaused() then return false end
        if not ensureOnlineInWorld(worldName, activeDoorID) then return false end
        local missing = countMissingDirtPlatforms(doorX, doorY)
        if getInvCount(ITEM.DIRT) < math.min(160, missing) then
            collectBackupDropsFromDF(ITEM.DIRT)
        end
        local currentDirt = getInvCount(ITEM.DIRT)
        if missing <= 0 or currentDirt >= math.min(160, missing) then
            return true
        end

        -- Pastikan lantai row 24 tempat tanam terisi blok padat jika masih punya Dirt (jangan timpa Rock)
        for x = rowMinX, rowMaxX do
            if not isInSecurityMoat(x, farmRowY + 1, doorX, doorY) then
                local okF, tf = pcall(getTile, x, farmRowY + 1)
                if okF and tf and tf.fg == 0 and getInvCount(ITEM.DIRT) > 0 then
                    placeTileAt(x, farmRowY + 1, ITEM.DIRT, false, -1)
                end
            end
        end

        -- 1. Harvest & Take semua pohon Dirt matang (2 pass agar yg miss karena lag ikut kepanen)
        local harvestedAny = false
        for hPass = 1, 2 do
            local missedTree = false
            for x = rowMinX, rowMaxX do
                if not waitIfPaused() then return false end
                if not isProtectedEnclosure(x, farmRowY, doorX, doorY) then
                    local okT, t = pcall(getTile, x, farmRowY)
                    if okT and t and t.fg == ITEM.DIRT_SEED and t.readyharvest then
                        setStatus("Harvest & Take", string.format("Panen & ambil Dirt Tree di (%d, %d)", x, farmRowY))
                        if not harvestDirtTreeAt(x, farmRowY) then
                            missedTree = true
                        end
                        harvestedAny = true
                        if getInvCount(ITEM.DIRT) >= 185 then
                            break
                        end
                    end
                end
            end
            if (not missedTree) or getInvCount(ITEM.DIRT) >= 185 then
                break
            end
        end
        if harvestedAny then
            for sx = 10, 90, 8 do
                if getInvCount(ITEM.DIRT) >= 190 then break end
                collectNearbyFloating(sx, farmRowY, 5, true, true)
            end
            -- Poin 2: Begitu dapat Dirt dari harvest, langsung kembali untuk place di atas (kalau masih kurang baru tanam lagi!)
            if getInvCount(ITEM.DIRT) > 0 then
                return true
            end
        end

        -- 2. Jika Dirt Seed di BP habis, ambil dulu cadangan Dirt Seed yg sempat di-drop di DF saat tahap break
        if getInvCount(ITEM.DIRT_SEED) <= 0 then
            collectBackupDropsFromDF(ITEM.DIRT_SEED)
        end

        -- Hitung pohon yg sudah tertanam di row 23 saat ini
        local currentTrees = 0
        for x = rowMinX, rowMaxX do
            local okC, tc = pcall(getTile, x, farmRowY)
            if okC and tc and tc.fg == ITEM.DIRT_SEED then
                currentTrees = currentTrees + 1
            end
        end

        -- 3. Poin 2: Tanam secukupnya saja sesuai setting Max Tanam (misal 50), tidak melebihi kebutuhan sisa tile
        local maxBatch = math.max(1, math.min(rowMaxX - rowMinX + 1, tonumber(CFG.max_plant_dirt) or 50))
        local targetTrees = math.min(maxBatch, missing)
        if getInvCount(ITEM.DIRT_SEED) > 0 and currentTrees < targetTrees then
            setStatus("Plant Dirt Seed", string.format("Tanam secukupnya (%d/%d pohon | sisa place %d)", currentTrees, targetTrees, missing))
            for pPass = 1, 2 do
                local plantMissed = 0
                for x = rowMinX, rowMaxX do
                    if not waitIfPaused() then return false end
                    if currentTrees >= targetTrees or getInvCount(ITEM.DIRT_SEED) <= 0 then break end
                    if not isProtectedEnclosure(x, farmRowY, doorX, doorY) then
                        local okT, t = pcall(getTile, x, farmRowY)
                        local okFloor, floorT = pcall(getTile, x, farmRowY + 1)
                        local solidFloor = okFloor and floorT and floorT.fg ~= 0 and (floorT.fg == ITEM.DIRT or floorT.fg == ITEM.ROCK or floorT.collidable)
                        if okT and t and t.fg == 0 and solidFloor then
                            if placeTileAt(x, farmRowY, ITEM.DIRT_SEED, false, -1) then
                                currentTrees = currentTrees + 1
                            else
                                plantMissed = plantMissed + 1
                            end
                        end
                    end
                end
                if plantMissed == 0 or currentTrees >= targetTrees or getInvCount(ITEM.DIRT_SEED) <= 0 then
                    break
                end
            end
        end

        -- Hitung ulang pohon yg sedang tumbuh & cek apakah ada yg sudah matang
        local treeCount = 0
        local readyNow = false
        for x = rowMinX, rowMaxX do
            local okT, t = pcall(getTile, x, farmRowY)
            if okT and t and t.fg == ITEM.DIRT_SEED then
                treeCount = treeCount + 1
                if t.readyharvest then readyNow = true end
            end
        end

        if treeCount == 0 and getInvCount(ITEM.DIRT_SEED) == 0 and getInvCount(ITEM.DIRT) == 0 then
            addLog("Stok Dirt Block & Dirt Seed habis, lanjut ke validasi DF.")
            return true
        end

        -- Poin 2: Selama tree belum ready, bot waiting sampai bisa di-harvest!
        if (not readyNow) and treeCount > 0 then
            setStatus("Tunggu Pohon Tumbuh", string.format("Waiting %d Dirt Tree siap harvest...", treeCount))
            while STATE.running do
                if not waitIfPaused() then return false end
                if not ensureOnlineInWorld(worldName, activeDoorID) then return false end
                local foundReady = false
                local stillTrees = 0
                for x = rowMinX, rowMaxX do
                    local okR, tr = pcall(getTile, x, farmRowY)
                    if okR and tr and tr.fg == ITEM.DIRT_SEED then
                        stillTrees = stillTrees + 1
                        if tr.readyharvest then
                            foundReady = true
                            break
                        end
                    end
                end
                if foundReady or stillTrees == 0 then break end
                safeSleep(1500)
            end
        end
    end
    return true
end

-- Cari posisi berdiri di koridor ATAS (y - 1) atau BAWAH (y + 1) baris platform target, jangan di baris y itu sendiri
local function moveToStandAboveOrBelow(cx, targetY)
    local candidates = {}
    local rowOffsets = {}
    if targetY - 1 >= 1 then table.insert(rowOffsets, -1) end
    if targetY + 1 <= 53 then table.insert(rowOffsets, 1) end

    for _, dy in ipairs(rowOffsets) do
        local sy = targetY + dy
        for _, sx in ipairs({ cx, cx - 1, cx + 1, cx - 2, cx + 2 }) do
            if sx >= 1 and sx <= 98 and isTileSafeToStand(sx, sy) then
                table.insert(candidates, { x = sx, y = sy })
            end
        end
    end

    for _, pos in ipairs(candidates) do
        if moveSafeTo(pos.x, pos.y) then
            return pos.x, pos.y
        end
    end
    return nil, nil
end

-- Put sampai 3 tile platform horizontal sekaligus dari 1 posisi (atas/bawah), cek jarak & lag lalu ulangi yg masih bolong
local function placePlatformBatch3(rowY, standX, standY, missingXs)
    local pending = {}
    for _, x in ipairs(missingXs) do
        table.insert(pending, x)
    end

    for attempt = 1, 3 do
        if #pending == 0 then return true, 0 end
        local px, py = getPlayerTilePos()
        if px ~= standX or py ~= standY then
            moveSafeTo(standX, standY)
        end

        for _, tx in ipairs(pending) do
            if not waitIfPaused() then return false, #pending end
            if getInvCount(ITEM.DIRT) <= 0 then break end
            local cpx, cpy = getPlayerTilePos()
            if (not cpx) or cpy == rowY or math.abs(cpx - tx) > 2 or math.abs(cpy - rowY) > 2 then
                if isTileSafeToStand(tx, standY) then
                    moveSafeTo(tx, standY)
                else
                    local altX, altY = moveToStandAboveOrBelow(tx, rowY)
                    if altX and altY then standX, standY = altX, altY end
                end
            end
            sendRawAction(tx, rowY, ITEM.DIRT)
            safeSleep(CFG.delay_place)
        end

        local stillMissing = {}
        for waitMs = 25, 250, 25 do
            stillMissing = {}
            for _, tx in ipairs(pending) do
                local ok, t = pcall(getTile, tx, rowY)
                if ok and t and t.fg == 0 then
                    table.insert(stillMissing, tx)
                end
            end
            if #stillMissing == 0 then
                return true, 0
            end
            safeSleep(25)
        end

        stillMissing = {}
        for _, tx in ipairs(pending) do
            local ok, t = pcall(getTile, tx, rowY)
            if ok and t and t.fg == 0 then
                table.insert(stillMissing, tx)
            end
        end
        pending = stillMissing
        if #pending == 0 then
            return true, 0
        end
        if getInvCount(ITEM.DIRT) <= 0 then
            break
        end
        if attempt < 3 then
            addLog(string.format("Put lag di Y=%d (%d tile belum masuk), ulangi cepat...", rowY, #pending))
        end
    end

    return (#pending == 0), #pending
end

-- Stage D: Susun Platform Dirt Atas (y = 22..2), Perbaiki Bawah (y = 24..52), Put 3 Tile dari Atas/Bawah & Validasi Ulang
local function buildUpperPlatforms(worldName, activeDoorID, doorX, doorY)
    local rowsToBuild = {}
    for y = 24, 52, 2 do
        table.insert(rowsToBuild, y)
    end
    if CFG.build_upper then
        for y = 22, 2, -2 do
            table.insert(rowsToBuild, y)
        end
    end

    local rowMinX, rowMaxX = getDFRowBounds()

    for pass = 1, 6 do
        rowMinX, rowMaxX = getDFRowBounds()
        for rowIdx, y in ipairs(rowsToBuild) do
            if not ensureOnlineInWorld(worldName, activeDoorID) then return false end
            local dxNow, dyNow = findMainDoor()
            if dxNow and dyNow then doorX, doorY = dxNow, dyNow end

            -- Cek dulu apakah baris y masih ada yang kosong (jangan ganggu Rock yang sudah jadi bagian platform)
            local rowNeedsWork = false
            for x = rowMinX, rowMaxX do
                if not isInSecurityMoat(x, y, doorX, doorY) then
                    local ok, t = pcall(getTile, x, y)
                    if ok and t and t.fg == 0 then
                        rowNeedsWork = true
                        break
                    end
                end
            end

            if rowNeedsWork then
                setStatus(
                    pass == 1 and "Put 3-Tile Platform" or "Validasi & Tambal Bolong",
                    string.format("Pass %d | Baris Y = %d", pass, y)
                )
                local centers = {}
                local pos = rowMinX
                while pos <= rowMaxX do
                    table.insert(centers, math.min(rowMaxX, pos + 1))
                    pos = pos + 3
                end
                local cStart, cEnd, cStep = zigZagRange(rowIdx % 2 == 1, 1, #centers, 1)

                for ci = cStart, cEnd, cStep do
                    local cx = centers[ci]
                    if not waitIfPaused() then return false end
                    local missingXs = {}
                    for _, tx in ipairs({ cx - 1, cx, cx + 1 }) do
                        if tx >= rowMinX and tx <= rowMaxX and not isInSecurityMoat(tx, y, doorX, doorY) then
                            local ok, t = pcall(getTile, tx, y)
                            if ok and t and t.fg == 0 then
                                table.insert(missingXs, tx)
                            end
                        end
                    end

                    if #missingXs > 0 then
                        if getInvCount(ITEM.DIRT) < #missingXs then
                            collectBackupDropsFromDF(ITEM.DIRT)
                        end
                        if getInvCount(ITEM.DIRT) < #missingXs and CFG.auto_farm_dirt then
                            farmDirtUntilEnough(worldName, activeDoorID, doorX, doorY)
                        end
                        if getInvCount(ITEM.DIRT) > 0 then
                            local standX, standY = moveToStandAboveOrBelow(cx, y)
                            if standX and standY then
                                local okPlace = placePlatformBatch3(y, standX, standY, missingXs)
                                if not okPlace and not STATE.running then return false end
                            else
                                -- Fallback darurat bila kedua koridor atas & bawah terhalang total
                                for _, tx in ipairs(missingXs) do
                                    if getInvCount(ITEM.DIRT) <= 0 then break end
                                    placeTileAt(tx, y, ITEM.DIRT, false, -1)
                                end
                            end
                        end
                    end
                end
            end
        end

        local holesRemaining = 0
        for _, y in ipairs(rowsToBuild) do
            for x = rowMinX, rowMaxX do
                if not isInSecurityMoat(x, y, doorX, doorY) then
                    local ok, t = pcall(getTile, x, y)
                    if ok and t and t.fg == 0 then
                        holesRemaining = holesRemaining + 1
                    end
                end
            end
        end

        if holesRemaining == 0 then
            addLog("Validasi Platform DF OK: Semua baris DF rapat (0 bolong)!")
            break
        else
            addLog(string.format("Validasi Platform Pass %d: Terdeteksi %d tile masih bolong, lanjut tambal...", pass, holesRemaining))
            local hasTrees23 = false
            for x = rowMinX, rowMaxX do
                local okT, tr = pcall(getTile, x, 23)
                if okT and tr and tr.fg == ITEM.DIRT_SEED then
                    hasTrees23 = true
                    break
                end
            end
            if getInvCount(ITEM.DIRT) <= 0 and ((not CFG.auto_farm_dirt) or (getInvCount(ITEM.DIRT_SEED) <= 0 and not hasTrees23)) then
                break
            end
        end
    end

    -- Poin 6: Pasang Platform di jalur naik-turun pinggir (x = 1 dan/atau x = 98) di setiap lantai DF
    if CFG.use_platform and (CFG.plat_left or CFG.plat_right) then
        local platID = (CFG.platform_itemid and CFG.platform_itemid > 0) and CFG.platform_itemid or ITEM.WOOD_PLATFORM
        local edgeCols = {}
        if CFG.plat_left then table.insert(edgeCols, 1) end
        if CFG.plat_right then table.insert(edgeCols, 98) end

        for _, ex in ipairs(edgeCols) do
            if getInvCount(platID) <= 0 then
                addLog(string.format("Stok Platform (%s) habis di BP, skip sisa pemasangan pinggir.", resolveItemName(platID)))
                break
            end
            setStatus("Pasang Platform Pinggir", string.format("Memasang %s di kolom x = %d", resolveItemName(platID), ex))
            for y = 2, 52, 2 do
                if not waitIfPaused() then return false end
                if getInvCount(platID) <= 0 then break end
                if (CFG.build_upper or y >= 24) and (not isInSecurityMoat(ex, y, doorX, doorY)) then
                    local okT, t = pcall(getTile, ex, y)
                    if okT and t and t.fg ~= platID then
                        if t.fg ~= 0 and isTileClearableByBot(t) then
                            breakTileCompletely(ex, y, true, false, (ex == 1) and 1 or -1)
                        end
                        local okNow, tNow = pcall(getTile, ex, y)
                        if okNow and tNow and tNow.fg == 0 then
                            placeTileAt(ex, y, platID, false, (ex == 1) and 1 or -1)
                        end
                    end
                end
            end
        end
    end

    -- Bersihkan sisa pohon panen terakhir di row 23 jika ada yg sudah matang
    for x = rowMinX, rowMaxX do
        if not isProtectedEnclosure(x, 23, doorX, doorY) then
            local ok, t = pcall(getTile, x, 23)
            if ok and t and t.fg == ITEM.DIRT_SEED and t.readyharvest then
                harvestDirtTreeAt(x, 23)
            end
        end
    end

    return true
end

-- Poin 4: Deteksi block penghalang / troll yang merusak simetri garis DF (area atas, baris ganjil, line genap DF, & sekitar White Door/WL)
local function findLineObstructions(doorX, doorY)
    local rowMinX, rowMaxX = getDFRowBounds()
    local obs = {}
    local seen = {}
    local function addObs(tx, ty)
        local key = tostring(tx) .. "," .. tostring(ty)
        if seen[key] then return end
        seen[key] = true
        table.insert(obs, { x = tx, y = ty, dir = (tx < 50) and 1 or -1 })
    end

    -- 1. Cek baris ganjil atas & bawah (y = 1..53, step 2) dari block troll yg dipasang orang
    local minOddY = CFG.build_upper and 1 or 25
    for y = minOddY, 53, 2 do
        for x = rowMinX, rowMaxX do
            if not isProtectedEnclosure(x, y, doorX, doorY) then
                local ok, t = pcall(getTile, x, y)
                if ok and t and t.fg ~= 0 and isTileClearableByBot(t) then
                    if not (y == 23 and t.fg == ITEM.DIRT_SEED) then
                        addObs(x, y)
                    end
                end
            end
        end
    end

    -- 2. Cek garis platform genap DF (y = 2..52, step 2): tidak boleh ada block asing selain Dirt / Rock / Platform
    local minEvenY = CFG.build_upper and 2 or 24
    for y = minEvenY, 52, 2 do
        for x = rowMinX, rowMaxX do
            if not isInSecurityMoat(x, y, doorX, doorY) then
                local ok, t = pcall(getTile, x, y)
                if ok and t and t.fg ~= 0 and isTileClearableByBot(t) then
                    local isValidPlat = (t.fg == ITEM.DIRT)
                        or (t.fg == ITEM.ROCK and not CFG.break_rock)
                        or (CFG.use_platform and t.fg == CFG.platform_itemid)
                    if not isValidPlat then
                        addObs(x, y)
                    end
                end
            end
        end
    end

    -- 3. Cek area sekitar White Door, SL & WL (troll block di atas SL/WL yang menghalangi)
    if doorX and doorY then
        for my = math.max(0, doorY - 2), math.min(53, doorY + 2) do
            for mx = math.max(0, doorX - 2), math.min(99, doorX + 2) do
                if not isProtectedEnclosure(mx, my, doorX, doorY) then
                    local ok, t = pcall(getTile, mx, my)
                    if ok and t and t.fg ~= 0 and isTileClearableByBot(t) then
                        addObs(mx, my)
                    end
                end
            end
        end
    end

    return obs
end

local function sweepLineObstructions(worldName, activeDoorID, doorX, doorY)
    local obs = findLineObstructions(doorX, doorY)
    if #obs == 0 then return true end
    setStatus("Bersihkan Penghalang DF", string.format("Deteksi %d block penghalang simetri DF!", #obs))
    for _, cell in ipairs(obs) do
        if not waitIfPaused() then return false end
        if not ensureOnlineInWorld(worldName, activeDoorID) then return false end
        moveAdjacentSafe(cell.x, cell.y, cell.dir)
        breakTileCompletely(cell.x, cell.y, true, false, cell.dir)
        checkTrashAndSeeds(worldName, activeDoorID)
    end
    return true
end

-- Inspeksi seluruh layout DF (sisa clear break + penghalang simetri DF + platform DF yang bolong)
local function inspectFullDFLayout(doorX, doorY)
    local breakLeft = 0
    local sideCols = getSideColumns()
    for _, colX in ipairs(sideCols) do
        for y = 24, 53 do
            if (not isProtectedEnclosure(colX, y, doorX, doorY)) and (not isEdgePlatformTile(colX, y, doorX, doorY)) then
                local ok, t = pcall(getTile, colX, y)
                if ok and isTileClearableByBot(t) and (t.fg ~= 0 or (CFG.break_cave_bg and t.bg ~= 0)) then
                    breakLeft = breakLeft + 1
                end
            end
        end
    end
    local rowMinX, rowMaxX = getDFRowBounds()
    for y = 25, 53, 2 do
        for x = rowMinX, rowMaxX do
            if isOddTileClearNeeded(x, y, doorX, doorY) then
                breakLeft = breakLeft + 1
            end
        end
    end
    if CFG.break_lava or CFG.break_rock then
        for y = 24, 52, 2 do
            for x = rowMinX, rowMaxX do
                if not isInSecurityMoat(x, y, doorX, doorY) then
                    local ok, t = pcall(getTile, x, y)
                    if ok and isTileClearableByBot(t) and ((t.fg == ITEM.LAVA and CFG.break_lava) or (t.fg == ITEM.ROCK and CFG.break_rock)) then
                        breakLeft = breakLeft + 1
                    end
                end
            end
        end
    end

    local obsList = findLineObstructions(doorX, doorY)
    breakLeft = breakLeft + #obsList

    local platHoles = countMissingDirtPlatforms(doorX, doorY)
    return breakLeft, platHoles
end

-- Stage E: Deteksi penuh apakah layout DF sudah lengkap (clear bersih + bebas block penghalang + semua platform ter-put)
local function validateAndRepairFullDFLayout(worldName, activeDoorID, doorX, doorY)
    for cycle = 1, 3 do
        local breakLeft, platHoles = inspectFullDFLayout(doorX, doorY)
        if breakLeft == 0 and platHoles == 0 then
            addLog("Deteksi Layout DF OK: Semua break bersih (0 sisa) & semua line DF simetris (0 bolong)!")
            return true
        end

        addLog(string.format("Deteksi Layout DF #%d: Sisa/Penghalang=%d tile | Platform Bolong=%d tile -> Perbaiki otomatis...", cycle, breakLeft, platHoles))
        setStatus("Deteksi Layout DF", string.format("Cycle %d | Break/Penghalang: %d | Tambal DF: %d", cycle, breakLeft, platHoles))

        if breakLeft > 0 then
            if not sweepRemainingBreakTiles(worldName, activeDoorID, doorX, doorY, (CFG.break_lava or CFG.break_rock), true) then
                return false
            end
            if not sweepLineObstructions(worldName, activeDoorID, doorX, doorY) then
                return false
            end
        end
        if platHoles > 0 then
            if not buildUpperPlatforms(worldName, activeDoorID, doorX, doorY) then
                return false
            end
        end
    end
    return true
end

-- ============================================================================
-- 10. MAIN COROUTINE ORCHESTRATOR
-- ============================================================================

local function processSingleWorld()
    -- 1. Masuk ke World Target dulu untuk mengecek apakah Lock/Jammer sudah terpasang!
    local worldName, worldDoor, manualIdx = acquireTargetWorld()
    if not worldName then
        return false
    end

    STATE.current_world = worldName
    STATE.active_world = worldName
    STATE.active_door = worldDoor or ""
    STATE.df_dropped_spots = {}
    if manualIdx and CFG.world_list[manualIdx] then
        CFG.world_list[manualIdx].done = false
        CFG.world_list[manualIdx].status = "PROSES"
        if updateWorldDisplayList then pcall(updateWorldDisplayList) end
    end
    applyCheatToggles()
    safeSleep(800)

    local doorX, doorY = findMainDoor()
    if not doorX or not doorY then
        setStatus("Error Main Door", "Main Door tidak ditemukan di world " .. worldName)
        return false
    end

    -- 2. Cek apakah di world ini sudah terpasang WL, SL, Jammer, Door ID & Penghalang
    local secState = inspectWorldSecurityState(doorX, doorY)
    local activeDoorID = worldDoor or ""

    if secState.all_ready then
        setStatus("Auto-Resume DF", "Lock, Jammer & Door sudah terpasang di " .. worldName .. "! Langsung lanjut DF...")
        if CFG.use_id_door and activeDoorID == "" then
            activeDoorID = CFG.door_id
        end
    else
        -- Ambil alat yang kurang saja dari Storage Alat, lalu kembali ke world DF
        if not ensureToolsFromStorage(secState, worldName, worldDoor) then
            return false
        end
        doorX, doorY = findMainDoor()
        if not doorX or not doorY then
            return false
        end
        activeDoorID = setupWorldLocks(doorX, doorY, secState)
        if activeDoorID == "" then
            activeDoorID = worldDoor or ""
        end
    end
    if manualIdx and CFG.world_list[manualIdx] and activeDoorID ~= "" and CFG.world_list[manualIdx].door ~= activeDoorID then
        CFG.world_list[manualIdx].door = activeDoorID
        persistConfig()
        if updateWorldDisplayList then pcall(updateWorldDisplayList) end
    end

    -- 3. Cek penuh apakah layout DF sudah lengkap (Lock lengkap + break bersih + 0 platform bolong); jika belum, clear, build & repair!
    local initBreakLeft, initPlatHoles = inspectFullDFLayout(doorX, doorY)
    if secState.all_ready and initBreakLeft == 0 and initPlatHoles == 0 then
        addLog("Cek Status World: " .. worldName .. " sudah selesai penuh (0 bolong, 0 sisa) -> Status DONE!")
    else
        if not clearWorldDirtFarm(worldName, activeDoorID, doorX, doorY) then
            return false
        end
        if not buildUpperPlatforms(worldName, activeDoorID, doorX, doorY) then
            return false
        end
        if not validateAndRepairFullDFLayout(worldName, activeDoorID, doorX, doorY) then
            return false
        end
    end

    -- 5. Setelah DF terbentuk semua & ter-place: ambil cadangan seed di DF (bila ada) lalu simpan ke World Storage Seed!
    if CFG.storage_seed_world ~= "" then
        for _ = 1, 4 do
            collectBackupDropsFromDF(nil)
            saveSeedsToStorage(worldName, activeDoorID, true)
            if not hasAnyDroppedBackupInDF() then
                break
            end
        end
    else
        saveSeedsToStorage(worldName, activeDoorID, true)
    end

    if STATE.reconnected_restart then
        return false
    end

    local wasRandom = (CFG.world_mode == "random")
    if manualIdx and CFG.world_list[manualIdx] then
        CFG.world_list[manualIdx].done = true
        CFG.world_list[manualIdx].status = "DONE"
        if CFG.world_list[manualIdx].from_random then
            wasRandom = true
        end
        persistConfig()
    end
    if wasRandom then
        STATE.random_done_count = (STATE.random_done_count or 0) + 1
    end

    STATE.worlds_completed = STATE.worlds_completed + 1
    STATE.active_world = ""
    STATE.active_door = ""
    if updateWorldDisplayList then pcall(updateWorldDisplayList) end
    setStatus("World Selesai!", string.format("DF %s selesai! (Total: %d)", worldName, STATE.worlds_completed))
    if sendNotification then
        pcall(sendNotification, "DF Selesai: " .. worldName)
    end
    return true
end

local function startAutoDF()
    if STATE.running then return end
    ensureRuntimeHooks()
    STATE.running = true
    STATE.paused  = false
    STATE.random_done_count = 0
    if editToggle then pcall(editToggle, "df_run_power", true) end
    if updatePowerStatusList then pcall(updatePowerStatusList) end

    local okCoro, errCoro = pcall(runCoroutine, function()
        syncInputsFromGL()
        setStatus("Bot Berjalan", "Auto Dirt Farm by Boren Store aktif...")
        applyCheatToggles()

        while STATE.running do
            local ok, res = pcall(processSingleWorld)
            if ok and res then
                STATE.reconnected_restart = false
                STATE.resume_world_override = nil
                STATE.resume_door_override = nil
            elseif (not ok) or (not res) then
                if STATE.running and STATE.reconnected_restart then
                    STATE.reconnected_restart = false
                    setStatus("Auto-Restart DF", "Kembali online! Menjalankan ulang scan DF dari awal...")
                    addLog("Auto Reconnect OK -> Run ulang DF otomatis agar tidak ada tile tertinggal!")
                    safeSleep(900)
                else
                    local onlineNow = isPlayerOnlineInWorld()
                    if STATE.running and CFG.auto_reconnect and ((not onlineNow) or STATE.reconnecting) then
                        ensureOnlineInWorld(STATE.active_world, STATE.active_door)
                        if STATE.reconnected_restart then
                            STATE.reconnected_restart = false
                            setStatus("Auto-Restart DF", "Kembali online! Menjalankan ulang scan DF dari awal...")
                            addLog("Auto Reconnect OK -> Run ulang DF otomatis agar tidak ada tile tertinggal!")
                            safeSleep(900)
                        else
                            STATE.running = false
                            break
                        end
                    else
                        if not ok then
                            setStatus("Error", tostring(res))
                        end
                        STATE.running = false
                        break
                    end
                end
            end
            safeSleep(1200)
        end

        STATE.running = false
        STATE.paused  = false
        STATE.reconnecting = false
        if editToggle then pcall(editToggle, "df_run_power", false) end
        setStatus("Berhenti", "Auto Dirt Farm berhenti.")
        if updatePowerStatusList then pcall(updatePowerStatusList) end
    end)

    if not okCoro then
        STATE.running = false
        STATE.paused  = false
        if editToggle then pcall(editToggle, "df_run_power", false) end
        setStatus("Error Coroutine", tostring(errCoro))
        if updatePowerStatusList then pcall(updatePowerStatusList) end
        if sendNotification then pcall(sendNotification, "Gagal mulai bot: " .. tostring(errCoro)) end
    end
end

-- ============================================================================
-- 11. NATIVE GROWLAUNCHER MENU ("Boren Store")
-- ============================================================================

local function buildWorldDisplayRows()
    local wList = {}
    for i, entry in ipairs(CFG.world_list) do
        local st = getWorldEntryStatusTag(entry)
        local dInfo = (entry.door and entry.door ~= "") and ("Door: " .. entry.door) or "White Door"
        table.insert(wList, { string.format("%d. %s [%s]", i, entry.name, st), dInfo })
    end
    if #wList == 0 then
        table.insert(wList, { "List world masih kosong", "Ketik Nama World lalu klik + Tambah" })
    end
    return wList
end

updateWorldDisplayList = function()
    if not editValue then return end
    pcall(editValue, "df_world_display_list", jsonEncode(buildWorldDisplayRows()))
end

updateTrashDisplayList = function()
    if not editValue then return end
    local tList = {}
    local items = getConfiguredTrashItemList()
    local thresh = math.max(10, tonumber(CFG.trash_threshold) or 150)
    for _, id in ipairs(items) do
        table.insert(tList, {
            string.format("%s (ID: %d)", resolveItemName(id), id),
            string.format("BP: %d | Auto-Trash >= %d", getInvCount(id), thresh)
        })
    end
    if #tList == 0 then
        table.insert(tList, { "List Trash kosong", "Pick item lalu klik + Tambah" })
    end
    pcall(editValue, "df_trash_display_list", jsonEncode(tList))
end

local function updateBagDisplayList()
    if not editValue then return end
    local bList = {}
    for _, it in ipairs(STATE.cached_inv) do
        local tag = it.isDoor and " [DOOR]" or ""
        table.insert(bList, {
            string.format("%s (ID: %d)%s", it.name, it.id, tag),
            string.format("Jumlah: %d", it.amount)
        })
    end
    if #bList == 0 then
        table.insert(bList, { "Belum ada data tas", "Klik 'Refresh Status, Log & Tas' saat di world" })
    end
    pcall(editValue, "df_bag_display_list", jsonEncode(bList))
end

local function updateLogDisplayList()
    if not editValue then return end
    local lList = {
        { "Status: " .. tostring(STATE.current_step), tostring(STATE.status_text) },
        { "World: " .. tostring(STATE.current_world), "DF Selesai: " .. tostring(STATE.worlds_completed) },
    }
    for i = 1, math.min(10, #STATE.logs) do
        table.insert(lList, { "Log #" .. tostring(i), tostring(STATE.logs[i]) })
    end
    pcall(editValue, "df_log_display_list", jsonEncode(lList))
end

updatePowerStatusList = function()
    if not editValue then return end
    local row1Title = "STATUS: BERHENTI (OFF)"
    local row1Sub = "Tekan 'START AUTO DF' untuk mulai"
    if STATE.reconnecting then
        row1Title = "STATUS: MENUNGGU ONLINE"
        row1Sub = "Terputus, otomatis lanjut saat online"
    elseif STATE.running and STATE.paused then
        row1Title = "STATUS: DIJEDA (PAUSE)"
        row1Sub = "World: " .. tostring(STATE.current_world)
    elseif STATE.running then
        row1Title = "STATUS: SEDANG JALAN (ON)"
        row1Sub = "Tekan 'STOP AUTO DF' untuk berhenti"
    end
    pcall(editValue, "df_power_status_list", jsonEncode({
        { row1Title, row1Sub },
        { "World: " .. tostring(STATE.current_world), "Selesai: " .. tostring(STATE.worlds_completed) .. " | Err: " .. tostring(STATE.error_count) }
    }))
end

refreshNativeDisplayLists = function()
    updatePowerStatusList()
    updateWorldDisplayList()
    updateBagDisplayList()
    updateLogDisplayList()
end

-- Helper UI Builder: memakai UserInterface.new() bawaan Growlauncher agar skema JSON 100% sesuai APK
local function createNativeUI(subName, iconName)
    if UserInterface and UserInterface.new then
        return UserInterface.new(subName, iconName)
    end
    local ui = { sub_name = subName, icon = iconName, menu = {} }
    function ui:addLabelApp(text, icon)
        table.insert(self.menu, { type = "labelapp", text = text, icon = icon or "" })
        return self
    end
    function ui:addLabel(text)
        table.insert(self.menu, { type = "label", text = text })
        return self
    end
    function ui:addDivider()
        table.insert(self.menu, { type = "divider" })
        return self
    end
    function ui:addToggle(text, default, alias, autosave)
        table.insert(self.menu, { type = "toggle", text = text, default = default == true, alias = alias, autosave = autosave == true })
        return self
    end
    function ui:addToggleButton(text, default, alias)
        table.insert(self.menu, { type = "toggle_button", text = text, default = default == true, alias = alias })
        return self
    end
    function ui:addButton(text, alias)
        table.insert(self.menu, { type = "button", text = text, alias = alias })
        return self
    end
    function ui:addInputString(text, default, label, placeholder, icon, alias)
        table.insert(self.menu, { type = "input_string", text = text, default = default or "", label = label or "Text", placeholder = placeholder or "", icon = icon or "", alias = alias })
        return self
    end
    function ui:addInputInt(text, default, label, placeholder, icon, alias)
        table.insert(self.menu, { type = "input_int", text = text, default = tostring(default or "0"), label = label or "Value", placeholder = placeholder or "0", icon = icon or "", alias = alias })
        return self
    end
    function ui:addSlider(text, minVal, maxVal, defaultVal, stepVal, useDot, alias)
        table.insert(self.menu, { type = "slider", text = text, min = minVal, max = maxVal, default = defaultVal, step = stepVal, use_dot = useDot == true, alias = alias })
        return self
    end
    function ui:addTooltip(text, supportText, icon, background)
        table.insert(self.menu, { type = "tooltip", text = text, support_text = supportText or "", icon = icon or "Info", background = background == true })
        return self
    end
    function ui:addItemPicker(text, item, default, alias)
        table.insert(self.menu, { type = "item_picker", text = text, item = item or "Blank", default = tostring(default or "0"), alias = alias })
        return self
    end
    function ui:addDisplayList(text, default, alias)
        table.insert(self.menu, { type = "display_list", text = text, default = default or "Default", alias = alias })
        return self
    end
    function ui:addExpandableToggle(text, default, alias, alwaysExpand, background)
        local obj = {
            type = "expandable_toggle",
            text = text,
            default = default == true,
            alias = alias,
            always_expand = alwaysExpand == true,
            background = background == true,
            list_child = {},
        }
        table.insert(self.menu, obj)
        return obj
    end
    function ui:addChildButton(parentList, text, alias)
        if type(parentList) == "table" then
            table.insert(parentList, { type = "button", text = text, alias = alias })
        end
        return self
    end
    function ui:addChildToggle(parentList, text, default, alias, autosave, background)
        if type(parentList) == "table" then
            table.insert(parentList, { type = "toggle", text = text, default = default == true, alias = alias, autosave = autosave == true, background = background == true })
        end
        return self
    end
    function ui:generateJSON()
        return jsonEncode({ sub_name = self.sub_name, icon = self.icon, menu = self.menu })
    end
    return ui
end

local function registerNativeBorenStoreUI()
    if not addCategory or not addIntoModule then return end

    -- Sub-Menu 1: Start & World
    local uiWorld = createNativeUI("1. Start & World", "PlayArrow")
    uiWorld:addLabelApp("Boren Store - Auto DF", "Storefront")
    if uiWorld.addExpandableToggle and uiWorld.addChildButton and uiWorld.addChildToggle then
        local runCard = uiWorld:addExpandableToggle("▶ START AUTO DF", false, "df_run_power", false, true)
        uiWorld:addChildButton(runCard.list_child, "■ STOP AUTO DF", "df_btn_stop_df")
        uiWorld:addChildToggle(runCard.list_child, "Pause Bot", false, "df_pause_toggle")
    else
        uiWorld:addToggleButton("▶ START / ■ STOP AUTO DF", false, "df_run_power")
        uiWorld:addButton("■ STOP AUTO DF", "df_btn_stop_df")
        uiWorld:addToggle("Pause Bot", false, "df_pause_toggle", false)
    end
    uiWorld:addDisplayList("Status Bot", "Default", "df_power_status_list")
    uiWorld:addDivider()
    uiWorld:addLabel("Daftar World:")
    uiWorld:addInputString("Nama World", CFG.manual_world_text, "World", "WORLD1", "Public", "df_manual_world_input")
    uiWorld:addInputString("Door ID (Opsional)", CFG.manual_door_text, "Door ID", "Kosong = White Door", "DoorFront", "df_manual_door_input")
    uiWorld:addButton("+ Tambah World", "df_btn_add_world")
    uiWorld:addButton("+ World Sekarang", "df_btn_add_cur_world")
    uiWorld:addButton("Kelola / Edit List World", "df_btn_view_worlds")
    uiWorld:addButton("Hapus Semua World", "df_btn_clear_worlds")
    uiWorld:addInputString("File List World", CFG.world_file_name, "File", "boren_df_worlds.txt", "Save", "df_world_file")
    uiWorld:addButton("Save List", "df_btn_save_worlds")
    uiWorld:addButton("Load List", "df_btn_load_worlds")
    uiWorld:addDisplayList("List World DF", "Default", "df_world_display_list")
    uiWorld:addDivider()
    uiWorld:addLabel("Random World:")
    uiWorld:addToggle("Mode Random World", CFG.world_mode == "random", "df_world_random", true)
    if uiWorld.addInputInt then
        uiWorld:addInputInt("Jumlah World Random", tostring(CFG.random_target_count), "Target", "5", "FormatListNumbered", "df_random_target")
    else
        uiWorld:addInputString("Jumlah World Random", tostring(CFG.random_target_count), "Target", "5", "FormatListNumbered", "df_random_target")
    end
    uiWorld:addSlider("Panjang Nama", 4, 10, CFG.random_length, 1, false, "df_random_len")
    uiWorld:addToggle("Campur Angka", CFG.random_use_numbers, "df_random_num", true)

    -- Sub-Menu 2: Lock & Door
    local idDoorName = ITEM_NAME_CACHE[CFG.id_door_itemid] or ("Item #" .. tostring(CFG.id_door_itemid))
    local blkDoorName = ITEM_NAME_CACHE[CFG.blocker_door_itemid] or resolveItemName(CFG.blocker_door_itemid)
    local uiLock = createNativeUI("2. Lock & Door", "Lock")
    uiLock:addLabelApp("Lock & Door", "Lock")
    uiLock:addTooltip("Posisi Lock", "WL kanan (Public), SL atas (Private), Jammer kiri-atas, Penghalang kiri, Door ID di (0,0).", "Verified", false)
    uiLock:addToggle("World Lock (WL)", CFG.use_wl, "df_use_wl", true)
    uiLock:addToggle("WL Public", CFG.wl_public, "df_wl_public", true)
    uiLock:addDivider()
    uiLock:addToggle("Small Lock (SL)", CFG.use_sl, "df_use_sl", true)
    uiLock:addToggle("SL Ignore Air & Apply", CFG.sl_ignore_air, "df_sl_ignore", true)
    uiLock:addToggle("SL Public (OFF = Private)", CFG.sl_public, "df_sl_public", true)
    uiLock:addDivider()
    uiLock:addToggle("Signal Jammer", CFG.use_jammer, "df_use_jammer", true)
    uiLock:addDivider()
    uiLock:addToggle("Door ID di (0,0)", CFG.use_id_door, "df_use_id_door", true)
    uiLock:addItemPicker("Item Door ID", idDoorName, tostring(CFG.id_door_itemid), "df_pick_id_door")
    uiLock:addInputString("ID Door", CFG.door_id, "ID Door", "DF123", "DoorFront", "df_door_id")
    uiLock:addInputString("Label Door", CFG.door_label, "Label", "BOREN STORE", "Label", "df_door_label")
    uiLock:addSlider("Jeda Tele (0,0) (ms)", 300, 4000, CFG.delay_tele_door, 100, false, "df_delay_tele_door")
    uiLock:addDivider()
    uiLock:addToggle("Penghalang Kiri", CFG.use_blocker_door, "df_use_blocker", true)
    uiLock:addItemPicker("Item Penghalang", blkDoorName, tostring(CFG.blocker_door_itemid), "df_pick_blocker")

    -- Sub-Menu 3: Storage
    local uiStorage = createNativeUI("3. Storage", "Inventory")
    uiStorage:addLabelApp("Storage Alat & Seed", "Inventory")
    uiStorage:addLabel("Ambil Alat (Lock/Door/Jammer):")
    uiStorage:addInputString("World Storage Alat", CFG.storage_pack_world, "World", "WORLDALAT", "Inventory", "df_pack_w")
    uiStorage:addInputString("Door Storage Alat", CFG.storage_pack_door, "Door", "DOOR123", "DoorFront", "df_pack_d")
    uiStorage:addDivider()
    uiStorage:addLabel("Simpan Seed:")
    uiStorage:addInputString("World Storage Seed", CFG.storage_seed_world, "World", "Kosong = drop di DF", "Grass", "df_seed_w")
    uiStorage:addInputString("Door Storage Seed", CFG.storage_seed_door, "Door", "SEED123", "DoorFront", "df_seed_d")
    uiStorage:addSlider("Simpan Saat >=", 50, 195, CFG.save_seed_threshold, 5, false, "df_seed_thresh")
    uiStorage:addTooltip("Info Seed", "Cave/Lava/Rock langsung disimpan. Dirt Seed disimpan setelah DF selesai.", "Info", false)
    uiStorage:addToggle("Dirt Seed (Setelah DF)", CFG.save_dirt_seed, "df_save_dirt", true)
    uiStorage:addToggle("Cave Seed", CFG.save_cave_seed, "df_save_cave", true)
    uiStorage:addToggle("Lava Seed", CFG.save_lava_seed, "df_save_lava", true)
    uiStorage:addToggle("Rock Seed", CFG.save_rock_seed, "df_save_rock", true)
    uiStorage:addToggle("Lava Block", CFG.save_lava_block, "df_save_lava_block", true)
    uiStorage:addDivider()
    uiStorage:addLabel("Custom Save & Tes Drop:")
    uiStorage:addToggle("Simpan Item Pilihan", CFG.use_custom_save, "df_use_custom_save", true)
    uiStorage:addItemPicker("Pilih Item", ITEM_NAME_CACHE[CFG.custom_save_itemid] or resolveItemName(CFG.custom_save_itemid), tostring(CFG.custom_save_itemid), "df_pick_save_item")
    uiStorage:addButton("Tes Drop Item", "df_btn_test_drop")

    -- Sub-Menu 4: Pengaturan
    local uiSetting = createNativeUI("4. Pengaturan", "Build")
    uiSetting:addLabelApp("Pengaturan DF", "Build")
    uiSetting:addLabel("Umum:")
    uiSetting:addToggle("Auto Collect", CFG.auto_collect, "df_auto_collect", true)
    uiSetting:addSlider("Jarak Collect (Tile)", 1, 6, CFG.collect_range, 1, false, "df_collect_range")
    uiSetting:addToggle("Auto Reconnect", CFG.auto_reconnect, "df_auto_reconnect", true)
    uiSetting:addToggle("Anti-Lava", CFG.use_anti_lava, "df_anti_lava", true)
    uiSetting:addToggle("ModFly Otomatis", CFG.use_modfly, "df_modfly", true)
    uiSetting:addDivider()
    uiSetting:addLabel("Break & Tanam DF:")
    uiSetting:addToggle("Break 3 Baris (Cepat)", CFG.break_3_mode, "df_break_3_mode", true)
    uiSetting:addToggle("Clear Pinggir", CFG.clear_sides, "df_clear_sides", true)
    uiSetting:addSlider("Jeda Pinggir (ms)", 0, 500, CFG.delay_clear_sides, 20, false, "df_delay_sides")
    uiSetting:addToggle("Break Cave BG", CFG.break_cave_bg, "df_break_cave", true)
    uiSetting:addToggle("Break Lava", CFG.break_lava, "df_break_lava", true)
    uiSetting:addToggle("Break Rock", CFG.break_rock, "df_break_rock", true)
    uiSetting:addToggle("Susun Dirt Atas (y=2-22)", CFG.build_upper, "df_build_upper", true)
    uiSetting:addToggle("Auto Tanam Dirt", CFG.auto_farm_dirt, "df_auto_farm", true)
    uiSetting:addSlider("Max Tanam Dirt Seed", 10, 98, CFG.max_plant_dirt, 2, false, "df_max_plant_dirt")
    uiSetting:addDivider()
    uiSetting:addLabel("Platform Pinggir:")
    uiSetting:addToggle("Pakai Platform", CFG.use_platform, "df_use_platform", true)
    uiSetting:addItemPicker("Item Platform", ITEM_NAME_CACHE[CFG.platform_itemid] or resolveItemName(CFG.platform_itemid), tostring(CFG.platform_itemid), "df_pick_platform")
    uiSetting:addToggle("Pasang Kiri (x=1)", CFG.plat_left, "df_plat_left", true)
    uiSetting:addToggle("Pasang Kanan (x=98)", CFG.plat_right, "df_plat_right", true)
    uiSetting:addDivider()
    uiSetting:addLabel("Auto-Trash:")
    uiSetting:addToggle("Aktifkan Auto-Trash", CFG.auto_trash_junk, "df_auto_trash", true)
    uiSetting:addSlider("Trash Saat >=", 10, 200, CFG.trash_threshold, 10, false, "df_trash_thresh")
    uiSetting:addItemPicker("Pilih Item Trash", ITEM_NAME_CACHE[CFG.trash_picker_itemid] or resolveItemName(CFG.trash_picker_itemid), tostring(CFG.trash_picker_itemid), "df_pick_trash_item")
    uiSetting:addButton("+ Tambah Trash", "df_btn_add_trash")
    uiSetting:addButton("- Hapus Trash", "df_btn_rem_trash")
    uiSetting:addButton("Kelola / Edit List Trash", "df_btn_view_trash")
    uiSetting:addButton("Reset Default Trash", "df_btn_reset_trash")
    uiSetting:addDisplayList("List Auto-Trash", "[]", "df_trash_display_list")
    uiSetting:addDivider()
    uiSetting:addLabel("Delay:")
    uiSetting:addSlider("Delay Break (ms)", 80, 400, CFG.delay_break, 10, false, "df_delay_break")
    uiSetting:addSlider("Delay Place (ms)", 80, 400, CFG.delay_place, 10, false, "df_delay_place")
    uiSetting:addSlider("Delay Jalan (ms)", 80, 500, CFG.delay_walk, 10, false, "df_delay_walk")
    uiSetting:addSlider("Delay Warp (ms)", 3000, 8000, CFG.delay_warp, 250, false, "df_delay_warp")

    -- Sub-Menu 5: Console & Tas
    local uiBackpack = createNativeUI("5. Console & Tas", "Terminal")
    uiBackpack:addLabelApp("Console & Backpack", "Terminal")
    uiBackpack:addToggle("Mini Console", false, "df_mini_console", false)
    uiBackpack:addToggle("Hanya Error", false, "df_console_err_only", false)
    uiBackpack:addButton("Buka Log", "df_btn_open_console")
    uiBackpack:addButton("Bersihkan Log", "df_btn_clear_console")
    uiBackpack:addDivider()
    uiBackpack:addButton("Refresh Tas", "df_btn_refresh_bag")
    uiBackpack:addDisplayList("Isi Backpack", "Default", "df_bag_display_list")

    pcall(addCategory, "Boren Store", "Storefront")
    pcall(addIntoModule, uiWorld:generateJSON(), "Boren Store")
    pcall(addIntoModule, uiLock:generateJSON(), "Boren Store")
    pcall(addIntoModule, uiStorage:generateJSON(), "Boren Store")
    pcall(addIntoModule, uiSetting:generateJSON(), "Boren Store")
    pcall(addIntoModule, uiBackpack:generateJSON(), "Boren Store")
end

-- Handle events from Native Growlauncher Menu ("Boren Store")
local lastAliasEventTime = {}

local function toBoolVal(v)
    return (v == true or v == 1 or v == "true" or v == "1")
end

local function handleUIValue(vtype, name, value)
    if type(name) ~= "string" then return end
    local now = os.clock()
    local isButton = (name:sub(1, 7) == "df_btn_")
    if isButton then
        if lastAliasEventTime[name] and (now - lastAliasEventTime[name]) < 0.25 then
            return
        end
        lastAliasEventTime[name] = now
    else
        local evKey = name .. "=" .. tostring(value)
        if lastAliasEventTime[evKey] and (now - lastAliasEventTime[evKey]) < 0.08 then
            return
        end
        lastAliasEventTime[evKey] = now
    end

    if name == "df_pause_toggle" then
        STATE.paused = toBoolVal(value)
        setStatus(STATE.paused and "Paused" or "Resumed", STATE.paused and "Bot dijeda" or "Bot lanjut")
    elseif name == "df_run_power" then
        local wantRun = toBoolVal(value)
        if wantRun and not STATE.running then
            startAutoDF()
        elseif not wantRun and STATE.running then
            STATE.running = false
            STATE.paused = false
            STATE.reconnecting = false
            setStatus("Stopping", "Menghentikan bot...")
            updatePowerStatusList()
        end
        return
    elseif name == "df_btn_stop_df" then
        STATE.running = false
        STATE.paused = false
        STATE.reconnecting = false
        if editToggle then pcall(editToggle, "df_run_power", false) end
        setStatus("Stopping", "Bot dihentikan via tombol STOP.")
        updatePowerStatusList()
        if sendNotification then pcall(sendNotification, "Auto DF dihentikan!") end
        return
    elseif name == "df_manual_world_input" then
        CFG.manual_world_text = tostring(value or ""):upper()
        STATE.buf_world_name = CFG.manual_world_text
    elseif name == "df_manual_door_input" then
        CFG.manual_door_text = tostring(value or "")
        STATE.buf_world_door = CFG.manual_door_text
    elseif name == "df_btn_add_world" then
        local wIn = readGLString("df_manual_world_input", "")
        if wIn ~= "" then
            STATE.buf_world_name = wIn:upper()
            CFG.manual_world_text = STATE.buf_world_name
        end
        local dIn = readGLString("df_manual_door_input", "")
        if dIn ~= "" then
            STATE.buf_world_door = dIn
            CFG.manual_door_text = dIn
        end
        local count = addManualWorldsFromString(STATE.buf_world_name, STATE.buf_world_door, false)
        updateWorldDisplayList()
        if count > 0 then
            if sendNotification then pcall(sendNotification, string.format("%d World ditambahkan! (Total: %d)", count, #CFG.world_list)) end
        else
            if sendNotification then pcall(sendNotification, "Isi Nama World dulu di atas!") end
        end
    elseif name == "df_btn_add_cur_world" then
        local curW = getWorldNameSafe()
        if curW ~= "" and curW ~= "EXIT" then
            STATE.buf_world_name = curW
            CFG.manual_world_text = curW
            addManualWorldsFromString(curW, STATE.buf_world_door, false)
            updateWorldDisplayList()
            if sendNotification then pcall(sendNotification, string.format("World ditambahkan: %s (Total: %d)", curW, #CFG.world_list)) end
        else
            if sendNotification then pcall(sendNotification, "Anda belum masuk ke dalam world!") end
        end
    elseif name == "df_btn_clear_worlds" then
        CFG.world_list = {}
        CFG.manual_world_text = ""
        STATE.buf_world_name = ""
        updateWorldDisplayList()
        if sendNotification then pcall(sendNotification, "List world dikosongkan!") end
    elseif name == "df_btn_view_worlds" then
        ensureRuntimeHooks()
        updateWorldDisplayList()
        local curW = getWorldNameSafe()
        local openedInteractive = false
        if curW ~= "" and curW ~= "EXIT" then
            openedInteractive = openWorldListManagerDialog()
        end
        local lines = {}
        for i, entry in ipairs(CFG.world_list) do
            local st = getWorldEntryStatusTag(entry)
            local doorTxt = (entry.door and entry.door ~= "") and (" | ID: " .. tostring(entry.door)) or " | Public"
            table.insert(lines, string.format("%d. %s [%s]%s", i, tostring(entry.name), st, doorTxt))
        end
        local msg = (#lines > 0) and table.concat(lines, "\n") or "List world masih kosong. Isi Nama World lalu klik '+ Tambah World ke List'."
        if sendNotification then pcall(sendNotification, string.format("Total World DF: %d", #CFG.world_list)) end
        if (not openedInteractive) and sendDialog then
            pcall(sendDialog, {
                title = "List World DF (" .. tostring(#CFG.world_list) .. ")",
                alias = "boren_df_world_list",
                message = msg .. "\n\nTips: Klik tombol 'Lihat / Kelola List World' saat berada di dalam world untuk langsung Edit atau Hapus tiap world!",
                confirm = "OK"
            })
        end
    elseif name == "df_world_file" then
        local f = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if f ~= "" then CFG.world_file_name = f end
    elseif name == "df_btn_save_worlds" then
        local fIn = readGLString("df_world_file", "")
        if fIn ~= "" then CFG.world_file_name = fIn:gsub("^%s+", ""):gsub("%s+$", "") end
        saveWorldListToStorage(true)
    elseif name == "df_btn_load_worlds" then
        local fIn = readGLString("df_world_file", "")
        if fIn ~= "" then CFG.world_file_name = fIn:gsub("^%s+", ""):gsub("%s+$", "") end
        loadWorldListFromStorage(true)
        updateWorldDisplayList()
    elseif name == "df_world_random" then
        CFG.world_mode = toBoolVal(value) and "random" or "manual"
    elseif name == "df_random_target" then
        local n = math.floor(tonumber(value) or 5)
        CFG.random_target_count = math.max(1, n)
    elseif name == "df_random_len" then
        CFG.random_length = tonumber(value) or 6
    elseif name == "df_random_num" then
        CFG.random_use_numbers = toBoolVal(value)
    elseif name == "df_use_wl" then
        CFG.use_wl = toBoolVal(value)
    elseif name == "df_wl_public" then
        CFG.wl_public = toBoolVal(value)
    elseif name == "df_use_sl" then
        CFG.use_sl = toBoolVal(value)
    elseif name == "df_sl_ignore" then
        CFG.sl_ignore_air = toBoolVal(value)
    elseif name == "df_sl_public" then
        CFG.sl_public = toBoolVal(value)
    elseif name == "df_use_jammer" then
        CFG.use_jammer = toBoolVal(value)
    elseif name == "df_use_id_door" then
        CFG.use_id_door = toBoolVal(value)
    elseif name == "df_pick_id_door" then
        local num = resolvePickedItemID(value)
        if num and num > 0 then
            CFG.id_door_itemid = num
            if sendNotification then pcall(sendNotification, "Door ID: " .. resolveItemName(num)) end
        end
    elseif name == "df_door_id" then
        CFG.door_id = tostring(value or "DF123")
    elseif name == "df_door_label" then
        CFG.door_label = tostring(value or "BOREN STORE")
    elseif name == "df_use_blocker" then
        CFG.use_blocker_door = toBoolVal(value)
    elseif name == "df_pick_blocker" then
        local num = resolvePickedItemID(value)
        if num and num > 0 then
            CFG.blocker_door_itemid = num
            if sendNotification then pcall(sendNotification, "Penghalang Kiri: " .. resolveItemName(num)) end
        end
    elseif name == "df_delay_tele_door" then
        CFG.delay_tele_door = math.max(300, tonumber(value) or 1500)
    elseif name == "df_pack_w" then
        CFG.storage_pack_world = tostring(value or ""):upper()
    elseif name == "df_pack_d" then
        CFG.storage_pack_door = tostring(value or "")
    elseif name == "df_seed_w" then
        CFG.storage_seed_world = tostring(value or ""):upper()
    elseif name == "df_seed_d" then
        CFG.storage_seed_door = tostring(value or "")
    elseif name == "df_seed_thresh" then
        CFG.save_seed_threshold = tonumber(value) or 180
    elseif name == "df_save_dirt" then
        CFG.save_dirt_seed = toBoolVal(value)
    elseif name == "df_save_cave" then
        CFG.save_cave_seed = toBoolVal(value)
    elseif name == "df_save_lava" then
        CFG.save_lava_seed = toBoolVal(value)
    elseif name == "df_save_rock" then
        CFG.save_rock_seed = toBoolVal(value)
    elseif name == "df_save_lava_block" then
        CFG.save_lava_block = toBoolVal(value)
    elseif name == "df_use_custom_save" then
        CFG.use_custom_save = toBoolVal(value)
    elseif name == "df_pick_save_item" then
        local num = resolvePickedItemID(value)
        if num and num > 0 then
            CFG.custom_save_itemid = num
            CFG.use_custom_save = true
            if editToggle then pcall(editToggle, "df_use_custom_save", true) end
            if sendNotification then pcall(sendNotification, string.format("Item Save: %s (BP: %d)", resolveItemName(num), getInvCount(num))) end
        end
    elseif name == "df_btn_test_drop" then
        testDropCustomSaveItem()
    elseif name == "df_auto_collect" then
        CFG.auto_collect = toBoolVal(value)
    elseif name == "df_collect_range" then
        CFG.collect_range = tonumber(value) or 3
    elseif name == "df_auto_reconnect" then
        CFG.auto_reconnect = toBoolVal(value)
    elseif name == "df_anti_lava" then
        CFG.use_anti_lava = toBoolVal(value)
    elseif name == "df_modfly" then
        CFG.use_modfly = toBoolVal(value)
    elseif name == "df_clear_sides" then
        CFG.clear_sides = toBoolVal(value)
    elseif name == "df_delay_sides" then
        CFG.delay_clear_sides = math.max(0, tonumber(value) or 120)
    elseif name == "df_break_3_mode" then
        CFG.break_3_mode = toBoolVal(value)
    elseif name == "df_break_cave" then
        CFG.break_cave_bg = toBoolVal(value)
    elseif name == "df_break_lava" then
        CFG.break_lava = toBoolVal(value)
    elseif name == "df_break_rock" then
        CFG.break_rock = toBoolVal(value)
    elseif name == "df_build_upper" then
        CFG.build_upper = toBoolVal(value)
    elseif name == "df_auto_farm" then
        CFG.auto_farm_dirt = toBoolVal(value)
    elseif name == "df_max_plant_dirt" then
        CFG.max_plant_dirt = math.max(1, math.min(98, math.floor(tonumber(value) or 50)))
    elseif name == "df_use_platform" then
        CFG.use_platform = toBoolVal(value)
    elseif name == "df_pick_platform" then
        local num = resolvePickedItemID(value)
        if num and num > 0 then
            CFG.platform_itemid = num
            if sendNotification then pcall(sendNotification, "Platform: " .. resolveItemName(num)) end
        end
    elseif name == "df_plat_left" then
        CFG.plat_left = toBoolVal(value)
    elseif name == "df_plat_right" then
        CFG.plat_right = toBoolVal(value)
    elseif name == "df_auto_trash" then
        CFG.auto_trash_junk = toBoolVal(value)
    elseif name == "df_trash_thresh" then
        CFG.trash_threshold = math.max(10, math.min(200, math.floor(tonumber(value) or 150)))
    elseif name == "df_pick_trash_item" then
        local num = resolvePickedItemID(value)
        if num and num > 0 then
            CFG.trash_picker_itemid = num
            if sendNotification then pcall(sendNotification, "Item Trash dipilih: " .. resolveItemName(num)) end
        end
    elseif name == "df_btn_add_trash" then
        local list = getConfiguredTrashItemList()
        local id = tonumber(CFG.trash_picker_itemid) or 0
        if id > 0 then
            local exists = false
            for _, v in ipairs(list) do if v == id then exists = true; break end end
            if not exists then table.insert(list, math.floor(id)) end
            setTrashListFromTable(list)
            if updateTrashDisplayList then pcall(updateTrashDisplayList) end
            if sendNotification then pcall(sendNotification, "Ditambah ke List Trash: " .. resolveItemName(id)) end
        end
    elseif name == "df_btn_rem_trash" then
        local list = getConfiguredTrashItemList()
        local id = tonumber(CFG.trash_picker_itemid) or 0
        local nextList = {}
        for _, v in ipairs(list) do if v ~= id then table.insert(nextList, v) end end
        setTrashListFromTable(nextList)
        if updateTrashDisplayList then pcall(updateTrashDisplayList) end
        if sendNotification then pcall(sendNotification, "Dihapus dari List Trash: " .. resolveItemName(id)) end
    elseif name == "df_btn_reset_trash" then
        CFG.trash_list_str = "4,14,10"
        if updateTrashDisplayList then pcall(updateTrashDisplayList) end
        if sendNotification then pcall(sendNotification, "List Trash direset ke default (Lava, Cave, Rock)!") end
    elseif name == "df_btn_view_trash" then
        ensureRuntimeHooks()
        if not openTrashListManagerDialog() then
            if sendNotification then pcall(sendNotification, "Masuk ke world dulu untuk membuka List Trash!") end
        end
    elseif name == "df_delay_break" then
        CFG.delay_break = tonumber(value) or 180
    elseif name == "df_delay_place" then
        CFG.delay_place = tonumber(value) or 160
    elseif name == "df_delay_walk" then
        CFG.delay_walk = tonumber(value) or 250
    elseif name == "df_delay_warp" then
        CFG.delay_warp = tonumber(value) or 4500
    elseif name == "df_mini_console" then
        STATE.show_mini_console = toBoolVal(value)
    elseif name == "df_console_err_only" then
        STATE.console_errors_only = toBoolVal(value)
    elseif name == "df_btn_open_console" then
        ensureRuntimeHooks()
        openMiniConsoleDialog(STATE.console_errors_only)
    elseif name == "df_btn_clear_console" then
        STATE.logs = {}
        STATE.error_logs = {}
        STATE.error_count = 0
        if sendNotification then pcall(sendNotification, "Log & Error dibersihkan!") end
    elseif name == "df_btn_refresh_bag" then
        refreshInventorySnapshot()
        updateBagDisplayList()
        updateLogDisplayList()
        updatePowerStatusList()
        if sendNotification then pcall(sendNotification, "Isi backpack diperbarui!") end
    end

    if name:sub(1, 3) == "df_" then
        persistConfig()
    end
end

function OnValue(vtype, name, value)
    local ok, err = pcall(handleUIValue, vtype, name, value)
    if not ok then
        addLog("[Boren DF UI Err] " .. tostring(err))
    end
end

-- Alias camelCase & PascalCase untuk OnValue
onValue = OnValue

-- Mini Console ImGui (hanya muncul bila toggle 'Tampilkan Mini Console' dinyalakan)
function onDrawImGui()
    if (not STATE.show_mini_console) or (not ImGui) then
        return
    end
    pcall(function()
        if ImGui.SetNextWindowSize and ImVec2 then
            local cond = (ImGui.Cond and ImGui.Cond.FirstUseEver) or 4
            ImGui.SetNextWindowSize(ImVec2(380, 260), cond)
        end
        local openWin = ImGui.Begin("Boren DF - Mini Console (Cek Error)")
        if openWin then
            local statusCol = STATE.reconnecting and "[WAIT ONLINE] " or (STATE.running and "[AKTIF] " or "[STOP] ")
            ImGui.Text(string.format("%sStep: %s | World: %s", statusCol, tostring(STATE.current_step), tostring(STATE.current_world)))
            ImGui.Text(string.format("DF Selesai: %d | Total Error/Warn: %d", tonumber(STATE.worlds_completed) or 0, tonumber(STATE.error_count) or 0))
            if ImGui.Button(STATE.console_errors_only and "Mode: Error Saja" or "Mode: Semua Log") then
                STATE.console_errors_only = not STATE.console_errors_only
                if editToggle then pcall(editToggle, "df_console_err_only", STATE.console_errors_only) end
            end
            if ImGui.SameLine then ImGui.SameLine() end
            if ImGui.Button("Clear") then
                STATE.logs = {}
                STATE.error_logs = {}
                STATE.error_count = 0
            end
            if ImGui.SameLine then ImGui.SameLine() end
            if ImGui.Button("Tutup") then
                STATE.show_mini_console = false
                if editToggle then pcall(editToggle, "df_mini_console", false) end
            end
            if ImGui.Separator then ImGui.Separator() end
            local list = STATE.console_errors_only and STATE.error_logs or STATE.logs
            if #list == 0 then
                ImGui.TextWrapped(STATE.console_errors_only and "Tidak ada error tercatat." or "Belum ada log aktivitas.")
            else
                for i = 1, math.min(12, #list) do
                    ImGui.TextWrapped(tostring(list[i]))
                end
            end
        end
        ImGui.End()
    end)
end
OnDrawImGui = onDrawImGui

-- Registrasi UI "Boren Store" saat script di-load
registerNativeBorenStoreUI()
updatePowerStatusList()
updateTrashDisplayList()

-- Daftarkan setOnValue untuk semua alias UI agar tombol/input merespons di semua versi Growlauncher
local ALL_UI_ALIASES = {
    "df_run_power", "df_btn_stop_df", "df_pause_toggle",
    "df_manual_world_input", "df_manual_door_input",
    "df_btn_add_world", "df_btn_add_cur_world", "df_btn_clear_worlds", "df_btn_view_worlds",
    "df_world_file", "df_btn_save_worlds", "df_btn_load_worlds",
    "df_world_random", "df_random_target", "df_random_len", "df_random_num",
    "df_use_wl", "df_wl_public",
    "df_use_sl", "df_sl_ignore", "df_sl_public",
    "df_use_jammer", "df_use_id_door", "df_pick_id_door", "df_door_id", "df_door_label", "df_delay_tele_door",
    "df_use_blocker", "df_pick_blocker",
    "df_pack_w", "df_pack_d", "df_seed_w", "df_seed_d", "df_seed_thresh",
    "df_save_dirt", "df_save_cave", "df_save_lava", "df_save_rock", "df_save_lava_block",
    "df_use_custom_save", "df_pick_save_item", "df_btn_test_drop",
    "df_auto_collect", "df_collect_range", "df_auto_reconnect", "df_anti_lava", "df_modfly",
    "df_clear_sides", "df_delay_sides", "df_break_3_mode", "df_break_cave", "df_break_lava", "df_break_rock",
    "df_build_upper", "df_auto_farm", "df_max_plant_dirt",
    "df_use_platform", "df_pick_platform", "df_plat_left", "df_plat_right",
    "df_auto_trash", "df_trash_thresh", "df_pick_trash_item", "df_btn_add_trash", "df_btn_rem_trash", "df_btn_view_trash", "df_btn_reset_trash",
    "df_delay_break", "df_delay_place", "df_delay_walk", "df_delay_warp",
    "df_mini_console", "df_console_err_only", "df_btn_open_console", "df_btn_clear_console",
    "df_btn_refresh_bag",
}

if setOnValue then
    for _, aliasName in ipairs(ALL_UI_ALIASES) do
        pcall(setOnValue, aliasName, function(a1, a2, a3)
            if a2 == aliasName then
                OnValue(a1, a2, a3)
            elseif a1 == aliasName then
                OnValue(0, a1, a2)
            else
                OnValue(0, aliasName, a1)
            end
        end)
    end
end

-- Daftarkan hook onvalue (sesuai docs/hooks/index.md: addHook lalu applyHook)
if addHook then
    pcall(addHook, onValue, "onvalue")
end
if applyHook then
    pcall(applyHook)
end

if sendNotification then
    pcall(sendNotification, "Boren Store Auto DF siap!")
end
