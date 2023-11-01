from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.pagesizes import portrait
from reportlab.platypus import PageBreak

# 텍스트 파일의 경로를 나열합니다.
txt_files = ["lastb.txt", "lastdown.txt", "lastlog.txt", "users.txt", "w.txt", "who.txt"]

# PDF 파일의 이름을 지정합니다.
pdf_filename = "text_to_pdf.pdf"

# PDF를 생성하고 텍스트를 추가하는 함수를 정의합니다.
def create_pdf_from_text(txt_files, pdf_filename):
    doc = SimpleDocTemplate(pdf_filename, pagesize=portrait(letter))
    elements = []

    for txt_file in txt_files:
        with open(txt_file, "r", encoding="utf-8") as f:
            lines = f.readlines()

            # 텍스트를 줄바꿈을 유지하며 추가하기 위한 스타일을 생성합니다.
            styles = getSampleStyleSheet()
            style = styles["Normal"]
            style.leading = 12  # 줄간격을 조절합니다

            # 페이지 제목을 가운데 정렬된 부제목 스타일로 생성
            title_style = styles["Title"]
            title_style.alignment = 1  # 가운데 정렬

            # 페이지 제목을 Paragraph 객체로 변환하여 PDF에 추가합니다.
            elements.append(Paragraph(txt_file, title_style))

            for line in lines:
                # 각 라인을 개행문자로 분리하여 한 줄씩 처리
                line = line.strip()
                if line:
                    elements.append(Paragraph(line, style))

            # 페이지 구분을 위해 페이지 나누기를 추가
            elements.append(PageBreak())

    doc.build(elements)

# PDF 생성 함수를 호출하여 PDF 파일을 생성합니다.
create_pdf_from_text(txt_files, pdf_filename)

print(f"{pdf_filename} 파일이 생성되었습니다.")
