# **I_HATE_LIVE_FORENSIC**

This Repository is for Live Forenisc Script

## **1. Common Concept**

This repository is dedicated to developing automated tools for live digital forensics, applicable across both Linux and Windows platforms. Live forensics refers to the process of collecting and analyzing digital evidence from a computer system without shutting it down, which is crucial in cases where stopping the system could lead to the loss of valuable volatile data.

Assuming our scripts are stored on a USB drive, this drive is then attached to the system under investigation, be it compromised or under analysis. Our scripts are designed to run directly from the USB, facilitating a streamlined process in live forensic scenarios.
```
+---------------------+---------------------+
|                     |                     |
|    Script Storage   |   Data Storage      |
|      Partition      |     Partition       |
|                     |                     |
+---------------------+---------------------+
|                                           |
|                USB Drive                  |
|                                           |
+-------------------------------------------+
```
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
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/84cb1b76-a742-4ccf-949e-f5e452174b5e)<br/>
This is a script for collecting active data. As seen in the image, the script can perform various options. You can select the options in your preferred order, such as 2, 7, 3, or enter option 'a' to execute all options at once.<br/><br/>

From now on, I will introduce only the notable contents within the active data script<br/>
### **4-1) Memory Dump Explanation - Choice**<br/><br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/7c2d912f-385f-4a9a-9a8a-2292ad4a89da)<br/>
We support a total of three memory dump tools: first is RamCapture, second is Winpmem, and third is CyLR<br/><br/>
### **4-2) Memory Dump Explanation - RamCapture**<br/><br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/4e615650-8dcb-426b-b9a2-86f3a8e36589)<br/>
When you enter the 'R' option to execute RamCapture, a path will appear in the cmd. Insert this path into the space provided for RamCapture's location and press the 'Capture!' button to run it<br/><br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/6728c0ce-65f8-45eb-99ec-08838bf17799)<br/>
If it has been completed, press 'Close'<br/><br/>
### **4-3) Memory Dump Explanation - Winpmem**<br/><br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/31e84026-0feb-460d-8c79-0ab60b77a21a)<br/>
To execute Winpmem, it is mandatory to enter the username and password. (As a note, it is recommended to enter the user account with SID 1001 if possible. This is to run it with administrative privileges.)<br/><br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/0e0520a6-4ab6-4201-9ec0-cbe8010ebf3e)<br/>
Continuing, if the account name and password have been entered successfully, a memory dump will be performed through Winpmem as illustrated in the figure.<br/><br/>
### **4-4) Memory Dump Explanation - CyLR**<br/><br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/db17f460-d45a-4588-a419-dee1d4715463)<br/>
Since CyLR compresses the results of the memory dump, the password for the compressed file must be specified in advance.<br/><br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/9f7a9290-9f73-4421-bc2d-caac4e50672a)<br/>
Once the compression password has been entered, you can see CyLR functioning as shown in the picture above.<br/><br/>
### **4-5) Virtual Memory Dump Explanation - Choice**<br/><br/>
![vm1](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/e33f3ec8-f724-4569-826a-f53733f0069e)<br/>
The virtual memory dump is supported through the sysinternals procdump tool, and there are two main types that can be collected. One is a full memory dump, and the other is a kernel memory dump.<br/><br/>
![vm2](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/976fed1d-d24e-4c0d-8684-62d0ae93020a)<br/>
You might notice several errors quickly appearing at the beginning of a virtual memory dump using procdump, but then the dump proceeds normally after a moment. These initial errors are presumed to be related to permission issues.<br/><br/>

(Note - Since the virtual memory dump generates a large amount of data, during development and testing, the process was briefly run and then stopped to move on.)<br/>

Once all the script executions are complete, the menu will reappear, and you can exit by pressing 'q'. However, if you selected the option to run both active and inactive scripts by pressing 3 in main.bat, the Inactive script will start executing immediately.<br/><br/>
### **5) Fifth, Treating with Inactive Script**<br/><br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/b3386869-170d-4bbb-b8b7-0c7bc938bb8b)<br/>
The Inactive Script also supports various options, as seen in the image. The difference from the active script is that the execution of the Inactive Script depends on whether the .NET FRAMEWORK is installed. If the .NET FRAMEWORK is installed, it utilizes kape to use tools appropriately for each stage. On the other hand, if the .NET FRAMEWORK is not installed, it primarily uses forecopy_handy for data collection and occasionally employs xcopy, a built-in command provided by Windows, for data gathering.<br/><br/>
### **5-1) Collecting Filesystem Metadata**<br/><br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/99f0d519-8ccd-4750-bfe2-1574a278764f)<br/>
As you can see in the image above, the current system utilizes .NET FRAMEWORK version 4, which allows for the collection of Filesystem Metadata via kape.<br/><br/>
## **2-2 How To Use Linux Version**

### **1) Prepare USB**<br/><br/>
### **1-1) Recommanded USB capacity**<br/><br/>
For dump virtual memory and copy metadata files, you need LOTS of capacity
We recommand more than 64GB

### **1-2) USB partitioning**<br/><br/>
There is no need to partition in Linux
If you can use Windows, just partion it in Windows
It also works at Linux too
But, If you cannot use Windows, you have to follow these steps:
1. Search USB drive
```
lsblk
```

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

## **3. Report**
After data collection, we support the creation of a separate report (Note, this report generation task should be carried out on a computer unrelated to the one affected by the security incident. After all, the goal of digital forensics is to minimize changes to the system). Our report briefly outlines what data has been collected, when (timestamp) it was collected, where it is located, and what its hash value is.<br/><br/>

### **3-1) Report for Windows**
Unlike Linux, Windows currently generates reports only for active data because inactive data already provides ample information through kape.<br/><br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/9211ddac-afcd-4b9b-a4e1-a93d23c2396f)<br/>
Inside the I_HATE_LIVE_FORENSIC\Report\Windows directory, there is a file named Window_report_Final.py. You can use this program to generate the report.<br/><br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/9e7fcd88-ecf3-4b16-b041-49fe115cea79)<br/>
Specify the target directory you wish to parse and the type of hash value you want to output.<br/><br/>

If you're uncertain about which directory to specify,<br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/10c8a06b-d354-4232-ba89-217ccb29ce0b)<br/>
simply select the directory under the target directory defined in main.bat, which is named after the computer name and timestamp.<br/><br/>
If executed correctly, you should be able to see the results as follows:<br/>
![image](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/assets/55012702/06fc153b-49ec-47b1-83e7-b5339f229202)<br/>
The table in the image above represents a portion of the results from the generated report<br/><br/>
## Planned Improvements
Windows:
1) In main.bat, after running ProcMon and later closing it, we provided commands for unloading the ProcMon driver and for deletion. However, the unload command still shows an error, and despite being in an administrator privilege terminal, the delete command fails due to insufficient permissions. This issue needs to be addressed.

2) In the memory dump step, stage 0 of active_data2.bat, it shows a specific path for copying in RamCapture. It would be beneficial if this path could be highlighted or emphasized in color.

3) In the memory dump step, stage 0 of active_data2.bat, the fact that Winpmem reveals the user account name and password in clear text is problematic. The user’s input should be made invisible.

4) Both active_data2.bat and inactive_new_ver_ver.bat allow users to choose stages to execute by entering numbered stages or the 'a' option. The issue is that after performing each option, it only indicates the options selected by the user, not exactly up to which stage has been completed. There needs to be a clear indication of the stages that have been completed.

5) With the Windows Reporting feature, the tables are currently arranged alphabetically. They need to be reorganized according to the order of stages as listed in each script.

6) The Windows Reporting feature should be able to indicate the page number from the "second page" onwards at the bottom of each page, for example, - 2 - or - 3 -.

7) On main.bat, there's a Procmon warning content. I will change the color of this warning string to emphasize it, aiming to make it more noticeable so that users can read and make informed decisions based on it.

Linux:

## Requirements

For Windows - you need to execute the terminal with Administrator privileges.
For Linux - 

## Usage

[Note: This section will contain numbered or bulleted steps to ensure clarity and ease of understanding for users. Technical jargon will be avoided or explained where necessary.]

## License

Currently, our project is licensed under the MIT License.

## Contributing

Contributions are what make the Open Source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**. For detailed guidelines, please refer to ou [CONTRIBUTING.md](https://github.com/S3xyG4y/I_HATE_LIVE_FORENSIC/blob/main/CONTRIBUTING.md).
