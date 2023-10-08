from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
from reportlab.lib import colors
import pandas as pd
import numpy as np
import matplotlib
import os

# 현재 작업 디렉토리를 얻습니다.
current_directory = os.getcwd()

# 하위 디렉토리 목록을 저장할 빈 리스트를 생성합니다.
subdirectories = []

# 현재 디렉토리의 모든 파일과 하위 디렉토리를 검색합니다.
for root, dirs, files in os.walk(current_directory):
    for dir in dirs:
        # 각 하위 디렉토리의 경로를 생성하고 리스트에 추가합니다.
        subdirectory_path = os.path.join(root, dir)
        subdirectories.append(subdirectory_path)

# 결과 출력
for subdir in subdirectories:
    #print(os.path.basename(subdir))
    for dir in os.listdir(subdir):
        if dir.endswith('.txt'):
            print(dir)

print("==============================================")

# 기초 pdf파일 생성 설정
pdf_filename = 'Forensic_Report.pdf'    # pdf 파일명
doc = SimpleDocTemplate(pdf_filename, pagesize=letter) # 표 생성시 필요한 코드

txt_path = os.path.join(current_directory, 'test')
Index_list = os.listdir(txt_path)
Original_list = Index_list
for index in Index_list:
    if index.endswith('.txt'):
        Index_list.remove(index)
for index in Index_list:
    print(index)
print(len(Index_list))

print("==============================================")

# 텍스트로 출력시 필요한 코드
txt_path = os.path.join(txt_path, 'Forensic_Info.txt')
with open(txt_path, 'r') as file:
    text_data = file.read()

styles = getSampleStyleSheet()
style = styles["Normal"]
style.leading = 12

text_data = text_data.replace('\n', '<br/>')

story = []
story.append(Paragraph(text_data, style))
story.append(Spacer(1, 12))  # 위아래 공간 추가
doc.build(story)
