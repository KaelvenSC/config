-- ===== CONFIG (EDIT SENDIRI) =====

-- package Roblox (ganti kalau clone)
local PKG = "com.roblox.clientb"

-- daftar Private Server
local PS = {
  "https://www.roblox.com/share?code=91fbc202237dca4b820fcdec8723282b&type=Server",
  "https://www.roblox.com/share?code=aeae86301c1abc4e857dca2d60eef8fe&type=Server"
}

-- delay sebelum join (detik)
local DELAY = 8

-- =================================

print("Pilih Private Server:")
for i = 1, #PS do
  print(i .. ") PS " .. i)
end

io.write("Nomor: ")
local pilih = tonumber(io.read())

if not pilih or not PS[pilih] then
  print("Pilihan salah")
  os.exit()
end

print("Buka Roblox...")
os.execute("am start -n " .. PKG .. "/com.roblox.client.ActivitySplash")

os.execute("sleep " .. DELAY)

print("Join Private Server...")
os.execute('am start -a android.intent.action.VIEW -d "' .. PS[pilih] .. '"')

os.exit()
