#!/data/data/com.termux/files/usr/bin/bash

clear
echo "=== ROBLOX PS JOINER ==="
echo
echo "1. Delta Server 1"
echo "2. Delta Server 2"
echo "3. Delta Server 3"
echo "4. Delta Server 4"
echo "5. Delta Server 5"
echo
read -p "Pilih server: " pilih

case $pilih in
1)
am start -a android.intent.action.VIEW -d "https://www.roblox.com/share?code=119f9d69ec0fe14b979bb230adedbb6d&type=Server" com.roblox.nomercy1
;;
2)
am start -a android.intent.action.VIEW -d "https://www.roblox.com/share?code=91fbc202237dca4b820fcdec8723282b&type=Server" com.roblox.nomercy1
;;
3)
am start -a android.intent.action.VIEW -d "https://www.roblox.com/share?code=a952e7e79e0c7343ba2932c9ad4dca0f&type=Server" com.roblox.nomercy1
;;
4)
am start -a android.intent.action.VIEW -d "https://www.roblox.com/share?code=8cc356d05d61e048a2c5607923b9c830&type=Server" com.roblox.nomercy1
;;
5)
am start -a android.intent.action.VIEW -d "https://www.roblox.com/share?code=39e7c9e9dae16342a3c1e0d7ebb5ed0e&type=Server" com.roblox.nomercy1
;;
Trade)
am start -a android.intent.action.VIEW -d "https://www.roblox.com/share?code=0fe10be1c1d7a348b8cbf65e39952057&type=Server" com.roblox.nomercy1
;;
*)
echo "Pilihan tidak valid"
;;
esac
