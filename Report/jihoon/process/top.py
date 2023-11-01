from reportlab.lib.pagesizes import landscape, letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Spacer
from reportlab.lib import colors
from reportlab.platypus import Paragraph
from io import BytesIO
import re


def read_top_info(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    return lines


def create_top_info_pdf(filename, table1_data, table2_data):
    doc = SimpleDocTemplate(filename, pagesize=landscape(letter), leftMargin=30)
    elements = []

    # Title paragraph for Table 1
    title_table1 = Paragraph("<b>System Info</b>",
                             style=ParagraphStyle(name='Title', fontSize=18, alignment=1))
    elements.append(title_table1)
    elements.append(Spacer(1, 12))

    # Create Table 1
    table1 = Table(table1_data, colWidths=None)
    table1.setStyle(TableStyle([
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('GRID', (0, 0), (-1, -1), 1, colors.black)  # 테이블의 선 스타일 변경
    ]))
    elements.append(table1)

    # Title paragraph for Table 2
    title_table2 = Paragraph("<b>Process Info</b>",
                             style=ParagraphStyle(name='Title', fontSize=18, alignment=1))
    elements.append(title_table2)
    elements.append(Spacer(1, 12))

    # Create Table 2 with header
    table2_data_with_header = [
        ['PID', 'USER', 'PR', 'NI', 'VIRT', 'RES', 'SHR', 'S', '%CPU', '%MEM', 'TIME+', 'COMMAND']]
    table2_data_with_header.extend(table2_data)

    table2 = Table(table2_data_with_header, colWidths=None)
    table2.setStyle(TableStyle([
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('GRID', (0, 0), (-1, -1), 1, colors.black),
        ('BACKGROUND', (0, 0), (-1, 0), colors.beige)# 테이블의 선 스타일 변경
    ]))
    elements.append(table2)

    doc.build(elements)


if __name__ == "__main__":
    top_info = read_top_info('top_info.txt')

    table1_data = []
    table2_data = []
    current_table = None

    for line in top_info:
        if "PID USER" in line:
            current_table = table2_data
        elif "PID USER" not in line and current_table is None:
            table1_data.append([line.strip()])
        elif current_table is not None:
            current_table.append(line.split())

    create_top_info_pdf('top_info.pdf', table1_data, table2_data)
