-- ===== CONFIG =====

local PKG = "com.roblox.clientb"

local PS = {
  "https://www.roblox.com/share?code=91fbc202237dca4b820fcdec8723282b&type=Server",
  "https://www.roblox.com/share?code=aeae86301c1abc4e857dca2d60eef8fe&type=Server"
}

local DELAY = 12

-- ==================

print("Pilih Private Server:")
for i = 1, #PS do
  print(i .. ") PS " .. i)
end

io.write("Nomor: ")

local pilih
local tty = io.open("/dev/tty", "r")
if tty then
  pilih = tonumber(tty:read("*l"))
  tty:close()
else
  pilih = tonumber(io.read())
end

if not pilih or not PS[pilih] then
  print("Pilihan salah")
  os.exit()
end

print("Buka Roblox...")
os.execute("monkey -p " .. PKG .. " -c android.intent.category.LAUNCHER 1")

os.execute("sleep " .. DELAY)

print("Join Private Server...")
os.execute('am start -a android.intent.action.VIEW -d "' .. PS[pilih] .. '"')

os.exit()
