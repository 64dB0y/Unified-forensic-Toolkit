import os
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import Paragraph, Spacer
from reportlab.platypus import PageBreak

Active_list = ['Virtual_memory','Logon','Network','Process','Autorun','System']
Inactive_list = ['Metadata','Log','SysInfo_Inactive','Trash','Web','TMP','shortcut','exstorage']

tmp_AL = []
tmp_IAL = []

for dir in Active_list:
    tmp_AL.append(dir)
for dir in Inactive_list:
    tmp_IAL.append(dir)

def IDX():
    # 현재 작업 디렉토리를 얻습니다.
    current_directory = os.getcwd()
    Dir_list = os.listdir(current_directory)

    for dir in Dir_list:
        for act in Active_list:
            if act == dir:
                tmp_AL.remove(act)
        for inact in Inactive_list:
            if inact == dir:
                tmp_IAL.remove(inact)

    for dir1 in Active_list:
        for dir2 in tmp_AL:
            if dir1 == dir2:
                Active_list.remove(dir1)
    
    for dir1 in Inactive_list:
        for dir2 in tmp_IAL:
            if dir1 == dir2:
                Inactive_list.remove(dir1)

    return Active_list, Inactive_list, tmp_AL, tmp_IAL

def IDX_Record(Index_Active_List, Index_Inactive_List, Active_List, Inactive_List, story):
    styles = getSampleStyleSheet()
    
    text = f"{'Index<br/>'}"
    index_style = styles["Normal"].clone("index_style")
    index_style.fontSize = 14
    index_style.leading = 18
    p = Paragraph(text, index_style)
    story.append(p)
    story.append(Spacer(1, 12))

    if(Index_Active_List != []):
        text = f"{'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Collected Active Data'}"
        p = Paragraph(text, index_style)
        story.append(p)
        for dir in Index_Active_List:
            text = f"{'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+dir}"
            p = Paragraph(text, index_style)
            story.append(p)
        story.append(Spacer(1, 12))

    if(Index_Inactive_List != []):
        text = f"{'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Collected Inactive Data'}"
        p = Paragraph(text, index_style)
        story.append(p)
        for dir in Index_Inactive_List:
            text = f"{'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+dir}"
            p = Paragraph(text, index_style)
            story.append(p)
        story.append(Spacer(1, 12))

    if(Active_List != []):
        text = f"{'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Uncollected Active Data'}"
        p = Paragraph(text, index_style)
        story.append(p)
        for dir in Active_List:
            text = f"{'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+dir}"
            p = Paragraph(text, index_style)
            story.append(p)
        story.append(Spacer(1, 12))

    if(Inactive_List != []):
        text = f"{'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Uncollected Inactive Data'}"
        p = Paragraph(text, index_style)
        story.append(p)
        for dir in Inactive_List:
            text = f"{'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+dir}"
            p = Paragraph(text, index_style)
            story.append(p)
        story.append(Spacer(1, 12))
    
    story.append(PageBreak())

    return story