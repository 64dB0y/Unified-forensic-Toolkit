from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.platypus import PageBreak
import pandas as pd
import os
import idx
import ARP, DNS, isof, netinterface
import login_info, system_info
import psaux, pstree, top
import autoinfo, autorunning
import web

def Line(line, doc, hash_path):
    style = styles["Normal"]
    style.leading = 12
    text = f"{line}"
    p = Paragraph(text, style)
    doc.append(p)

    if '.txt' in line and os.path.exists(hash_path):
        with open(hash_path, 'r', encoding='utf-8') as hashfile:
            hash_lines = hashfile.readlines()
        hash_value1 = ''
        hash_value2 = ''
        for i, hash_line in enumerate(hash_lines):
            split = line.split(" ")
            for part in split:
                if part.endswith(".txt"):
                    dir = part
                    break
            if dir in hash_line:
                hash_value1 = hash_lines[i+1]
                hash_value2 = hash_lines[i+2]
                text = f"{hash_value1}<br/>{hash_value2}<br/>"
                p = Paragraph(text, style)
                doc.append(p)
                doc.append(Spacer(1, 12))
        if hash_value1 == '' and hash_value2 == '' and 'hash' not in line:
            text = f"{'No Hash Values'}"
            p = Paragraph(text, style)
            doc.append(p)
            doc.append(Spacer(1, 12))

    if 'files' in line or 'Hash Directory Timestamp' in line:
        doc.append(Spacer(1, 12))
    return doc

def Title(title, doc):
    style = styles["Title"]
    style.leading = 30

    text = f"{title}"
    p = Paragraph(text, style)
    doc.append(p)

    return doc

def get_dir_size(path):
    total = 0
    with os.scandir(path) as it:
        for entry in it:
            if entry.is_file():
                total += entry.stat().st_size
            elif entry.is_dir():
                total += get_dir_size(entry.path)
    return total

# 기초 pdf파일 생성 설정
pdf_filename = 'Forensic_Report.pdf'    # pdf 파일명
doc = SimpleDocTemplate(pdf_filename, pagesize=letter) # 표 생성시 필요한 코드

current_directory = os.getcwd()
Info_path = os.path.join(current_directory, 'Forensic_Info.txt')
Info_Data = pd.read_csv(Info_path, delimiter=' : ', header=None, names=['Key', 'Value'], engine='python')
breakstring = '-------------------------------------------------------------'

print("Linux Forensic Report Create Program")
print("by Team.최애의포렌식")
print("Ver.1.0.0")
print()

story = []
styles = getSampleStyleSheet()
style = styles["Normal"]
style.leading = 12

print("제목 생성 중 . . .")
text = f"{'Forensic Report'}"
title_style = styles["Title"]
title_style.leading = 60
p = Paragraph(text, title_style)
story.append(p)
story.append(Spacer(1, 12))

# 목차를 생성하는 코드
print("목차 생성 중 . . .")
Index_Active_List, Index_Inactive_List, Active_List, Inactive_List = idx.IDX()
story = idx.IDX_Record(Index_Active_List, Index_Inactive_List, Active_List, Inactive_List, story)

hash_path = ""
category = ''

print("개요 생성 중 . . .")
Title('Case Outline', story)

with open(Info_path, 'r') as file:
    line = file.readline()
    while line:
        if breakstring in line:
            category = ''
            story.append(PageBreak())
            line = file.readline()

        if 'Virtual_memory' in line:
            if 'files' in line:
                print("Virtual Memory 생성 중 . . .")
                Title('Virtual Memory', story)
                category = 'Virtual_memory'
                line = file.readline()
            elif 'Virtual Memory Dump Timestamp' in line:
                line = file.readline()
                continue
            elif 'hash.txt' in line:
                Line(line, story, hash_path)
                story.append(Spacer(1,12))

                dump_path = os.path.join(current_directory, 'Virtual_memory', 'core-dumps')
                subdir = [f.path for f in os.scandir(dump_path) if f.is_dir()]
                dump_dir_count = len(subdir) - 1
                text = f"{'Collected Dump files : ' + str(dump_dir_count)}"
                p = Paragraph(text, style)
                story.append(p)

                file_size = get_dir_size(dump_path)
                file_size /= 1024
                file_size = round(file_size, 2)
                text = f"{'Size of Collected Dump files : ' + str(file_size) + 'KB'}"
                p = Paragraph(text, style)
                story.append(p)
                line = file.readline()
            else:
                Line(line, story, hash_path)
                line = file.readline()
            continue
        elif 'Logon' in line or category == 'Logon':
            if 'files' in line:
                print("Logon 생성 중 . . .")
                Title('Logon', story)
                category = 'Logon'
                hash_path = os.path.join(current_directory, 'Logon', 'hash', 'hash.txt')
                line = file.readline()
            else:
                Line(line, story, hash_path)
                line = file.readline()
            continue
        elif 'Network' in line or category == 'Network':
            if 'files' in line:
                print("Network 생성 중 . . .")
                Title('Network', story)
                category = 'Network'
                hash_path = os.path.join(current_directory, 'Network', 'hash', 'hash.txt')
                line = file.readline()
            else:
                Line(line, story, hash_path)
                line = file.readline()
            continue
        elif 'Process' in line or category == 'Process':
            if 'files' in line:
                print("Process 생성 중 . . .")
                Title('Process', story)
                category = 'Process'
                hash_path = os.path.join(current_directory, 'Process', 'hash', 'hash.txt')
                line = file.readline()
            else:
                Line(line, story, hash_path)
                line = file.readline()
            continue
        elif 'Autorun' in line or category == 'Autorun':
            if 'files' in line:
                print("Autorun 생성 중 . . .")
                Title('Autorun', story)
                category = 'Autorun'
                hash_path = os.path.join(current_directory, 'Autorun', 'hash', 'hash.txt')
                line = file.readline()
            else:
                Line(line, story, hash_path)
                line = file.readline()
            continue
        elif 'System Info files' in line or category == 'System Info':
            if 'files' in line:
                print("System Info 생성 중 . . .")
                Title('System Information (Active Data)', story)
                category = 'System Info'
                hash_path = os.path.join(current_directory, 'System', 'hash', 'hash.txt')
                line = file.readline()
            else:
                Line(line, story, hash_path)
                line = file.readline()
            continue
        elif 'Metadata' in line or category == 'Metadata':
            if 'files' in line:
                print("Metadata 생성 중 . . .")
                Title('Metadata', story)
                category = 'Metadata'
                hash_path = os.path.join(current_directory, 'Metadata', 'hash', 'hash.txt')
                Metadata_path = os.path.join(current_directory, 'Metadata')
                line = file.readline()
            elif 'hash.txt' in line:
                file_size = get_dir_size(Metadata_path)
                file_size /= 1024
                file_size = round(file_size, 2)
                text = f"{'Size of Collected Metadata : ' + str(file_size) + 'KB'}"
                p = Paragraph(text, style)
                story.append(p)
                line = file.readline()
            else:
                Line(line, story, hash_path)
                line = file.readline()
            continue
        elif ('Log' in line and 'Logon' not in line) or category == 'Log':
            hash_path = ""
            if 'hash.txt' in line:
                Line(line, story, hash_path)
                story.append(Spacer(1,12))
                log_file_count = 0
                log_path = os.path.join(current_directory, 'Log')
                for root, dirs, files in os.walk(log_path):
                    for log_file in files:
                        if log_file.endswith('.log'):
                            log_file_count+=1
                log_file_count = str(log_file_count)
                text = f"{'Collected log files : ' + log_file_count}"
                p = Paragraph(text, style)
                story.append(p)

                file_size = get_dir_size(log_path) #os.path.getsize(log_path)
                file_size /= 1024
                file_size = round(file_size, 2)
                text = f"{'Size of Collected log files : ' + str(file_size) + 'KB'}"
                p = Paragraph(text, style)
                story.append(p)

                line = file.readline()
                continue
            elif 'files' in line:
                print("Log 생성 중 . . .")
                Title('Log', story)
                line = file.readline()
                category = 'Log'
                continue
            else:
                story = Line(line, story, hash_path)
                line = file.readline()
                continue
        elif 'System Information' in line or category == 'SysInfo_Inactive':
            if 'files' in line:
                print("System Info(Inactive Data) 생성 중 . . .")
                Title('System Information (Inactive Data)', story)
                category = 'SysInfo_Inactive'
                hash_path = os.path.join(current_directory, 'SysInfo_Inactive', 'hash', 'hash.txt')
                line = file.readline()
            else:
                Line(line, story, hash_path)
                line = file.readline()
            continue
        elif 'Trash' in line or category == 'Trash':
            if 'files' in line:
                print("Trash 생성 중 . . .")
                Title('Trash', story)
                category = 'Trash'
                line = file.readline()
            elif 'hash.txt' in line:
                Line(line, story, hash_path)
                story.append(Spacer(1,12))
                trash_file_count = 0
                trash_path = os.path.join(current_directory, 'Trash')
                for root, dirs, files in os.walk(log_path):
                    for trash_file in files:
                        trash_file_count+=1
                trash_file_count = str(trash_file_count)
                text = f"{'Collected Trash files : ' + trash_file_count}"
                p = Paragraph(text, style)
                story.append(p)

                file_size = get_dir_size(trash_path)
                file_size /= 1024
                file_size = round(file_size, 2)
                text = f"{'Size of Collected Trash files : ' + str(file_size) + 'KB'}"
                p = Paragraph(text, style)
                story.append(p)

                line = file.readline()
                continue
            else:
                Line(line, story, hash_path)
                line = file.readline()
            continue
        elif 'Web History' in line or category == 'Web':
            if 'files' in line:
                print("Web History 생성 중 . . .")
                Title('Web History', story)
                category = 'Web'
                hash_path = os.path.join(current_directory, 'Web', 'hash', 'hash.txt')
                line = file.readline()
            else:
                Line(line, story, hash_path)
                line = file.readline()
            continue
        elif 'Temporary' in line or category == 'TMP':
            if 'files' in line:
                print("TMP File 생성 중 . . .")
                Title('Temporary File', story)
                category = 'TMP'
                TMP_path = os.path.join(current_directory, 'TMP')
                line = file.readline()
            elif 'hash.txt' in line:
                Line(line, story, hash_path)
                story.append(Spacer(1,12))
                subdir = [f.path for f in os.scandir(TMP_path) if f.is_dir()]
                TMP_dir_count = len(subdir) - 1
                text = f"{'Collected TMP files : ' + str(TMP_dir_count)}"
                p = Paragraph(text, style)
                story.append(p)

                file_size = get_dir_size(TMP_path)
                file_size /= 1024
                file_size = round(file_size, 2)
                text = f"{'Size of Collected TMP files : ' + str(file_size) + 'KB'}"
                p = Paragraph(text, style)
                story.append(p)
                line = file.readline()
            else:
                Line(line, story, hash_path)
                line = file.readline()
            continue
        elif 'Shortcut' in line or category == 'shortcut':
            if 'files' in line:
                print("Shortcut 생성 중 . . .")
                Title('Shortcut', story)
                category = 'shortcut'
                line = file.readline()
            else:
                Line(line, story, hash_path)
                line = file.readline()
            continue
        elif 'ExStorage' in line or category == 'exstorage':
            if 'files' in line:
                print("ExStorage 생성 중 . . .")
                Title('ExStorage', story)
                category = 'exstorage'
                hash_path = os.path.join(current_directory, 'exstorage', 'hash', 'hash.txt')
                line = file.readline()
            else:
                Line(line, story, hash_path)
                line = file.readline()
            continue

        text = f"{line}"
        p = Paragraph(text, style)
        story.append(p)
        if 'files' in line or 'Hash Directory Timestamp' in line:
            story.append(Spacer(1, 12))

        line = file.readline()

doc.build(story)

choose = 0

while(1):
    print("추가적인 보고서를 생성하시겠습니까?")
    print("[1] Network\t[2] System Info\t[3] Process\n[4] Autorun\t[5] Web History\t[6] Exit")
    choose = int(input())

    if(choose == 1):    # 네트워크
        print("Network 세부 보고서를 생성합니다")
        ARP.ARP()
        DNS.DNS()
        isof.ISOF()
        netinterface.NETITF()
    elif(choose == 2):  # 시스템 정보
        print("System Information 세부 보고서를 생성합니다")
        system_info.SYSINFO()
        login_info.login()
    elif(choose == 3):  # 프로세스
        psaux.psaux()
        pstree.pstree()
        top.top()
    elif(choose == 4):  # 자동 실행
        autoinfo.autoinfo()
        autorunning.autorunning()
    elif(choose == 5):  # 웹 히스토리
        #web.WebHis() <--- 조금 더 수정하고 완성
        continue
    elif(choose == 6):  # 종료
        print("보고서 생성 프로그램을 종료합니다")
        break
    else:
        print("올바른 입력이 아닙니다")
    print()