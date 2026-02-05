-- ===== CONFIG =====
local PS = {
  "https://www.roblox.com/share?code=PS_CODE_1&type=Server",
  "https://www.roblox.com/share?code=PS_CODE_2&type=Server"
}
local DELAY = 10
-- ==================

-- ambil semua package roblox
local pkgs = {}
local p = io.popen("pm list packages | grep roblox")
for line in p:lines() do
  local pkg = line:match("package:(.+)")
  if pkg then table.insert(pkgs, pkg) end
end
p:close()

if #pkgs == 0 then
  print("❌ Roblox tidak ditemukan")
  os.exit()
end

print("Pilih Roblox:")
for i,v in ipairs(pkgs) do
  print(i .. ") " .. v)
end

io.write("Nomor: ")
local tty = io.open("/dev/tty","r")
local pilih = tonumber(tty and tty:read("*l") or io.read())
if tty then tty:close() end

local PKG = pkgs[pilih]
if not PKG then
  print("❌ Pilihan salah")
  os.exit()
end

print("Pilih Private Server:")
for i=1,#PS do print(i..") PS "..i) end
io.write("Nomor: ")
tty = io.open("/dev/tty","r")
local ps = tonumber(tty and tty:read("*l") or io.read())
if tty then tty:close() end
if not PS[ps] then
  print("❌ PS salah")
  os.exit()
end

print("Join PS...")
os.execute(
  'am start -a android.intent.action.VIEW ' ..
  '-d "'..PS[ps]..'" ' ..
  '-p '..PKG
)

os.execute("sleep "..DELAY)

print("Join PS...")
os.execute(
  'am start -a android.intent.action.VIEW -d "'..PS[ps]..'"'
)

os.exit()
