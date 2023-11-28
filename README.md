# **I_HATE_LIVE_FORENSIC**

This Repository is for Live Forenisc Script

## **1. Common Concept**

This repository is dedicated to developing automated tools for live digital forensics, applicable across both Linux and Windows platforms. Live forensics refers to the process of collecting and analyzing digital evidence from a computer system without shutting it down, which is crucial in cases where stopping the system could lead to the loss of valuable volatile data.

Assuming our scripts are stored on a USB drive, this drive is then attached to the system under investigation, be it compromised or under analysis. Our scripts are designed to run directly from the USB, facilitating a streamlined process in live forensic scenarios.

+---------------------+---------------------+<br/>
|                     |                     |<br/>
|    Script Storage   |   Data Storage      |<br/>
|      Partition      |     Partition       |<br/>
|                     |                     |<br/>
+---------------------+---------------------+<br/>
|                                           |<br/>
|                USB Drive                  |<br/>
|                                           |<br/>
+-------------------------------------------+<br/>

For optimal functionality, the USB drive should be prepared with two distinct partitions. The first partition contains all our scripts along with the necessary programs required for their execution. The second partition is reserved for storing the data gathered by these scripts during the forensic process. This dual-partition setup ensures a clear separation between tools and collected data, enhancing both organization and efficiency in the live forensic investigation.

In addition to the fundamental concept of live forensics, our scripts are meticulously designed to collect both active and inactive data from the target system. The specific types of data gathered by our scripts are as follows:

**- Active Data Collection**

*For active data, our scripts are capable of:*

1. Creating Memory and Virtual Memory dumps. <br/>
2. Collecting network configuration and connection status. <br/>
3. Gathering information about running processes and their resource usage. <br/>
4. Retrieving details about the currently logged-in user. <br/>
5. Compiling system event logs and registry information. <br/>
6. Listing programs configured to start automatically during boot. <br/>
7. Collecting information about scheduled tasks and clipboard history. <br/>

**- Inactive Data Collection**

*For inactive data, our scripts focus on:*

1. Collecting file system metadata including MFT, Boot, Amcache. <br/>
2. Retrieving registry files like SAM, SYSTEM, SOFTWARE, SECURITY. <br/>
3. Gathering Prefetch and Superfetch data. <br/>
4. Compiling Event Log files for the target host. <br/>
5. Collecting Recycle Bin information. <br/>
6. Retrieving browser artifacts including cache, cookies, history, and download history. <br/>
7. Collecting System Restore Points (or System Volume Information). <br/>
8. Gathering Portable Device Information. <br/>
9. Retrieving Link File and JumpLists data. <br/>

**[*] It's important to note that the data available for collection can vary between different operating systems, hence some differences in the information gathered from Linux and Windows systems.**

Furthermore, our script suite is divided into three main components. The main script allows users to choose whether to collect only active data, only inactive data, or both. This flexibility ensures that investigators can tailor the data collection process to the specific requirements of each forensic examination.

All demonstrations presented from this point forward are performed with administrative privileges. This means that our project's scripts are designed to be executed on the premise that they are granted administrator-level permissions

## **2-1 How To Use Windows Version**
### **1) First, prepare the USB with two partitions.**<br/><br/>
One side should be smaller and the other larger. Ensure that the smaller partition has at least 4GB of capacity, and allocate as much space as possible for the other partition. In my case, when I tested with a single desktop, I secured about 70GB of data.<br/><br/>
![diskmgmt](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/f318596a-6030-4b27-9031-e6164740c697)<br/>
As can be seen from the result screen of diskmgmt.msc in the image, the USB is currently attached with the scripts stored in the E:\ drive, and a partition designated for storing the results of script execution appearing in the F:\ drive.<br/><br/>
### **2) Second, Navigate to the Windows Script Directory and Execute main.bat**<br/><br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/85e6a06f-0588-46e4-ac2f-284ebc0ee75e)<br/>
Attention! You must execute the script with Administrator Permissions!<br/><br/>
### **3) Third, Entering Specific Information in main.bat**<br/><br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/d5770272-08c0-4153-b0bd-e63a8e4b177a)<br/>
Begin by inputting the case name and analyst's name, then designate the directory where the results will be stored. As shown in the image, you will be prompted to decide if you want to run ProcMon. This feature has been added to trace how information gathering is conducted later on. For simplicity in this demonstration, we've skipped this step by selecting the 'N' option.<br/><br/>
At this stage, a root directory named after the computer name and timestamp is created in the target directory specified by the user. Within this root directory, all forthcoming active data will be stored in the 'Volatile_Information' directory, while inactive data will be saved in the 'NONVOLATILE' directory. Additionally, the timestamp will also be saved directly under the aforementioned computer name_timestamp directory as 'TimeStamp.log'. Furthermore, if 'main.bat' is set to utilize Procmon, the 'procmon_log.pml' file will be stored in this directory as well.<br/>
### **4) Fourth, Treating with Active Script**<br/><br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/d46f8cfd-ea12-42e2-822e-bba534a94905)<br/>
This is a script for collecting active data. As seen in the image, the script can perform various options. You can select the options in your preferred order, such as 2, 7, 3, or enter option 'a' to execute all options at once.<br/><br/>
## **2-2 How To Use Linux Version**

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
