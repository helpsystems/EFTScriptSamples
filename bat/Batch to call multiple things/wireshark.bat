@echo off
c:
cd "C:\Program Files\Wireshark"
wireshark -k -i Ethernet0 -f "host 192.168.102.10" -a duration:120 -w "C:\Users\jbranan\Desktop\Batch to call multiple things\dumps\capture.pcapng"