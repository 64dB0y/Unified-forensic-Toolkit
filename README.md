# I_HATE_LIVE_FORENSIC

This Repository is for Live Forenisc Script



# How To Use Linux Version

1. Go to root directory
'cd /' or 'cd ..' twice

2. Make directory mnt1 & mnt2
These directories are for mounting each partition of Forensic USB
'mkdir mnt1', 'mkdir mnt2'

3. Mount the USB
Check which directory your USB has been connected
If the directory is /dev/sdb1 and /dev/sdb2, mount each of it to mnt1 and mnt2
ex)
sudo mount /dev/sdb1 /mnt1
sudo mount /dev/sdb2 /mnt2

4. Give permission to Forensic.bash script
All the other script's permission wil be given by Forensic.bash
sudo chmod +x ./Forensic.bash

5. Run the script!
sudo ./Forensic.bash
