import os
import re
from reportlab.lib.pagesizes import letter, landscape
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
from reportlab.lib.styles import ParagraphStyle

def abbreviate_filename(filename, max_length=30, start=17, end=17):
    """Abbreviate the filename if it exceeds the max_length."""
    if len(filename) > max_length:
        return f"{filename[:start]}...{filename[-end:]}"
    return filename

def get_sha256_hash(hash_directory, filename, current_directory):
    """Retrieve the SHA256 hash for a given file from its hash file."""
    # 확장자를 제외한 파일명 추출
    base_filename = os.path.splitext(filename)[0]

    # 특정 패턴에 해당하는 경우 파일명 수정
    if '.Kernel.dmp' in filename:
        hash_file_name = filename.replace('.Kernel.dmp', '_kernel_hash.txt')
    elif filename.endswith('.mem'):
        hash_file_name = "RamCapture_hash.txt"
    else:
        hash_file_name = f"{base_filename}_HASH.txt"

    # System_Information\HKEY_USERS 디렉토리 내의 파일에 대한 예외 처리
    if 'System_Information\\HKEY_USERS' in current_directory:
        # 상위 디렉토리로 이동 후 HASH 디렉토리로 경로 설정
        hash_directory = os.path.normpath(os.path.join(current_directory, '..', 'HASH'))

    hash_file_path = os.path.join(hash_directory, hash_file_name)

    print(f"Checking hash for {filename} in {hash_file_path}")  # 디버깅 메시지 추가

    try:
        with open(hash_file_path, 'r') as file:
            for line in file:
                if base_filename in line and ',' in line:
                    hash_value = line.strip().split(',')[-2]
                    print(f"Found hash for {filename}: {hash_value}")  # 디버깅 메시지 추가
                    return hash_value
    except FileNotFoundError:
        print(f"Hash file not found for {filename}")  # 디버깅 메시지 추가
        return "Hash File Not Found"
    return "N/A"

# Basic PDF file creation setup
pdf_filename = 'Forensic_Windows_Report.pdf'
doc = SimpleDocTemplate(pdf_filename, pagesize=landscape(letter))
story = []

# Target directory
base_directory = 'D:\\for_rep_result\\DESKTOP-2PH1IF1_2023-11-20_02-52-11'

# Info_path setup
Info_path = os.path.join(base_directory, 'TimeStamp.log')

# Timestamp regex pattern
timestamp_pattern = re.compile(r"\[(\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})\].*?(\w+)(?: Finished)?")

# Create a dictionary of timestamps from Info_Data
timestamp_dict = {}
if os.path.exists(Info_path):
    with open(Info_path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            if "HASH" in line or "DIRECTORY" in line:
                continue  # Exclude lines containing HASH or DIRECTORY

            match = timestamp_pattern.search(line)
            if match:
                timestamp, file_or_action = match.groups()
                timestamp_dict[file_or_action.lower()] = timestamp  # Convert to lowercase

# Walk through the directory
for root, dirs, files in os.walk(base_directory):
    if "HASH" in root or root == base_directory:
        continue

    if not files:
        continue

    display_path = root.replace(base_directory, '').lstrip('\\')

    # 디렉토리 경로의 글자 크기를 키우기 위한 스타일 설정
    directory_style = ParagraphStyle(
        'DirectoryStyle',
        parent=getSampleStyleSheet()['Normal'],
        fontSize=12,  # 글자 크기 조정
        leading=16,  # 줄 간격 조정
    )

    story.append(Paragraph(f"{display_path}", directory_style))
    # 디렉토리 경로와 표 사이의 간격 추가
    story.append(Spacer(1, 5)) # 여기서 5는 간격의 높이를 나타냄 (단위: 포인트)

    data = [["File Name", "Timestamp", "SHA256 Hash"]]

    for file in files:
        if file == 'TimeStamp.log' or file.endswith('.hash'):
            continue

        # Abbreviate long filenames
        file_display = abbreviate_filename(file)

        file_lower = file.lower()
        timestamp = timestamp_dict.get(file_lower, "N/A")

        # Match the filename with the timestamp
        if 'physmem.raw' in file_lower:
            timestamp = timestamp_dict.get('winpmem', "N/A")
        elif 'memory_dump.zip' in file_lower:
            timestamp = timestamp_dict.get('cylr', "N/A")
        elif file_lower.endswith('.mem'):
            timestamp = timestamp_dict.get('ramcapture', "N/A")
        elif 'application_log.evtx' in file_lower:
            timestamp = timestamp_dict.get('wevtutil_application_log', "N/A")
        elif 'hklm-software.hiv' in file_lower:
            timestamp = timestamp_dict.get('reg_save_software', "N/A")
        elif 'sam.hiv' in file_lower:
            timestamp = timestamp_dict.get('reg_save_sam', "N/A")
        elif 'security.hiv' in file_lower:
            timestamp = timestamp_dict.get('reg_save_security', "N/A")
        elif 'security_log.evtx' in file_lower:
            timestamp = timestamp_dict.get('wevtutil_security_log', "N/A")
        else:
            # Other files
            for key in timestamp_dict:
                if key in file_lower:
                    timestamp = timestamp_dict[key]
                    break

        # Determine the path for the hash directory
        hash_directory = os.path.join(root, 'HASH')
        hash_sha256 = get_sha256_hash(hash_directory, file, root)  # 현재 디렉토리 경로 추가

        data.append([file_display, timestamp, hash_sha256])

    # Adjust column widths to maintain the overall table size
    table = Table(data, colWidths=[2.65 * inch, 1.46 * inch, 4.89 * inch])
    table_style = TableStyle([('BACKGROUND', (0, 0), (-1, 0), "#f2f2f2"),
                                  ('TEXTCOLOR', (0, 0), (-1, 0), "#000000"),
                                  ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                                  ('VALIGN', (0, 0), (-1, 0), 'MIDDLE'),
                                  ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                                  ('FONTSIZE', (0, 0), (-1, 0), 12),
                                  ('BACKGROUND', (0, 1), (-1, -1), "#ffffff"),
                                  ('GRID', (0, 0), (-1, -1), 1, "#c0c0c0")])
    table.setStyle(table_style)

    story.append(table)
    story.append(Spacer(1, 0.25 * inch))

# Save the PDF document
doc.build(story)
print(f"PDF report has been created: {pdf_filename}")