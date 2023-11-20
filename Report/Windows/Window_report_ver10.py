import os
import re
from reportlab.lib.pagesizes import letter, landscape
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, PageBreak

def first_page(canvas, doc, Info_path):
    canvas.saveState()
    canvas.setFont('Helvetica-Bold', 38)
    canvas.drawCentredString(landscape(letter)[0] / 2, landscape(letter)[1] / 2, "WINDOWS LIVE FORENSIC RESULT")

    case, name, active_start_time = extract_case_name_start_time(Info_path)
    canvas.setFont('Helvetica-Bold', 16)
    canvas.drawCentredString(landscape(letter)[0] / 2 + 20, landscape(letter)[1] / 2 - 140, f"CASE NAME: {case}")
    canvas.drawCentredString(landscape(letter)[0] / 2 + 20, landscape(letter)[1] / 2 - 180, f"ANALYST NAME: {name}")
    canvas.drawCentredString(landscape(letter)[0] / 2 + 20, landscape(letter)[1] / 2 - 220, f"ACTIVE SCRIPT START TIME: {active_start_time}")
    canvas.restoreState()


def abbreviate_filename(filename, max_length=30, start=15, end=15):
    """Abbreviate the filename if it exceeds the max_length."""
    if len(filename) > max_length:
        return f"{filename[:start]}...{filename[-end:]}"
    return filename

def extract_case_name_start_time(log_path):
    case, name, active_start_time = "N/A", "N/A", "N/A"
    with open(log_path, 'r') as file:
        for line in file:
            if 'CASE:' in line:
                case = line.split('CASE:')[1].strip()
            elif 'NAME:' in line:
                name = line.split('NAME:')[1].strip()
            elif 'Active Script START TIME' in line:
                active_start_time = line.split(']')[0].strip('[')
    return case, name, active_start_time

def get_file_hashes(hash_directory, filename, current_directory, hash_option):
    """Retrieve the required hash values for a given file from its hash file."""
    base_filename = os.path.splitext(filename)[0]

    if '.Kernel.dmp' in filename:
        hash_file_name = filename.replace('.Kernel.dmp', '_kernel_hash.txt')
    elif filename.endswith('.mem'):
        hash_file_name = "RamCapture_hash.txt"
    else:
        hash_file_name = f"{base_filename}_HASH.txt"

    if 'System_Information\\HKEY_USERS' in current_directory:
        hash_directory = os.path.normpath(os.path.join(current_directory, '..', 'HASH'))

    hash_file_path = os.path.join(hash_directory, hash_file_name)

    try:
        with open(hash_file_path, 'r') as file:
            for line in file:
                if line.startswith('##'):
                    continue

                if base_filename in line and ',' in line:
                    hash_values = line.strip().split(',')
                    if hash_option == 1:
                        return hash_values[1], hash_values[2]  # MD5, SHA1
                    else:
                        return hash_values[3]  # SHA256
    except FileNotFoundError:
        return "Hash File Not Found" if hash_option == 2 else ("Hash File Not Found", "Hash File Not Found")
    return "N/A" if hash_option == 2 else ("N/A", "N/A")

def main():
    # 사용자로부터 디렉토리 경로 입력받기
    user_input = input("Enter the directory path for parsing: ")
    # 사용자 입력 경로의 '\'를 '\\'로 변환하지 않고, 원시 문자열로 처리
    base_directory = r"{}".format(user_input)

    # TimeStamp.log 파일 경로 설정 (Volatile_Information 디렉토리가 아닌 사용자가 제공한 디렉토리 내)
    Info_path = os.path.join(base_directory, 'TimeStamp.log')
    if not os.path.exists(Info_path):
        print("TimeStamp.log file not found in the given path.")
        return

    # Volatile_Information 폴더 경로 설정
    volatile_info_path = os.path.join(base_directory, 'Volatile_Information')

    # PDF 파일 생성 설정
    pdf_filename = 'Forensic_Windows_Report.pdf'
    doc = SimpleDocTemplate(pdf_filename, pagesize=landscape(letter))
    story = []

    # 사용자에게 해시 알고리즘 선택 요청
    while True:
        hash_option = input(
            "Choose the hash algorithm for the report:\n1) Display MD5, SHA1\n2) Display SHA256\nEnter 1 or 2: ")
        if hash_option in ["1", "2"]:
            hash_option = int(hash_option)
            break
        else:
            print("Invalid choice. Please enter 1 or 2.")

    # 페이지 구분 추가
    story.append(PageBreak())

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
                    print(f"Timestamp found: {file_or_action.lower()} - {timestamp}")  # 디버깅 로그 추가

    # os.walk 수정: Volatile_Information 폴더 내부만 순회
    for root, dirs, files in os.walk(volatile_info_path):
        if "HASH" in root:
            continue

        if not files:
            continue

        display_path = root.replace(base_directory, '').lstrip('\\')

        # 디렉토리 경로의 글자 크기를 키우기 위한 스타일 설정
        directory_style = ParagraphStyle(
            'DirectoryStyle',
            parent=getSampleStyleSheet()['Normal'],
            fontSize=12,
            leading=16,
        )

        story.append(Paragraph(f"{display_path}", directory_style))
        story.append(Spacer(1, 5))  # 여기서 5는 간격의 높이를 나타냄 (단위: 포인트)

        # 테이블 헤더 조정
        if hash_option == 1:
            data = [["File Name", "Timestamp", "MD5 Hash", "SHA1 Hash"]]
            col_widths = [2.45 * inch, 1.5 * inch, 2.85 * inch, 3.2 * inch]
        else:
            data = [["File Name", "Timestamp", "SHA256 Hash"]]
            col_widths = [2.65 * inch, 1.46 * inch, 4.89 * inch]

        for file in files:
            if file == 'TimeStamp.log' or file.endswith('.hash'):
                continue

            file_display = abbreviate_filename(file)
            file_lower = file.lower()
            timestamp = timestamp_dict.get(file_lower, "N/A")  # 각 파일에 대한 타임스탬프 초기화

            # 해시 디렉토리 경로 결정
            hash_directory = os.path.join(root, 'HASH')

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
                for key in timestamp_dict:
                    if key in file_lower:
                        timestamp = timestamp_dict[key]
                        print(f"Matching {file_lower} with timestamp {timestamp} for key {key}")  # 디버깅 로그 추가
                        break

            # 디버깅 로그 추가: 파일과 매핑되는 타임스탬프 출력
            print(f"File: {file}, Timestamp: {timestamp}")
            # 사용자 선택에 따라 해시 값 가져오기
            if hash_option == 1:
                hash_md5, hash_sha1 = get_file_hashes(hash_directory, file, root, hash_option)
                data.append([file_display, timestamp, hash_md5, hash_sha1])
            else:
                hash_sha256 = get_file_hashes(hash_directory, file, root, hash_option)
                data.append([file_display, timestamp, hash_sha256])

        # Adjust column widths to maintain the overall table size
        table = Table(data, colWidths=col_widths)
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

    doc.build(story, onFirstPage=lambda canvas, doc: first_page(canvas, doc, Info_path))
    print(f"PDF report has been created: {pdf_filename}")

if __name__ == "__main__":
    main()