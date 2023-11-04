import os

Active_list = ['Virtual_memory','Logon','Network','Process','Autorun','System']
Inactive_list = ['Metadata','Log','SysInfo_Inactive','Trash','Web','TMP','shortcut','exstorage']
Unified_list = Active_list + Inactive_list

def IDX():
    # 현재 작업 디렉토리를 얻습니다.
    current_directory = os.getcwd()
    Dir_list = os.listdir(current_directory)

    Index_Active_list = []
    Index_Inactive_list = []

    for dir in Dir_list:
        for act in Active_list:
            if act == dir:
                Index_Active_list.append(act)
                Active_list.remove(act)
        for inact in Inactive_list:
            if inact == dir:
                Index_Inactive_list.append(inact)
                Inactive_list.remove(inact)