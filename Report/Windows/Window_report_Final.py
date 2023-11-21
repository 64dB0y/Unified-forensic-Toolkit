import os
import re
from reportlab.lib.pagesizes import letter, landscape
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, PageBreak
from reportlab.lib.enums import TA_JUSTIFY, TA_CENTER


directory_order = [
    "Memory_Dump", "Virtual_Memory", "Network_Information",
    "Process_Information", "Logon_Information", "System_Information",
    "Autoruns_Information", "TSCB_Information"
]

def get_volatile_info_directories(volatile_info_path):
    # Volatile_Information 디렉토리 내의 하위 디렉토리 목록을 가져옵니다.
    if not os.path.exists(volatile_info_path):
        print(f"Volatile_Information directory not found in {volatile_info_path}")
        return []

    directories = next(os.walk(volatile_info_path))[1]
    return directories

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

def create_index_page(story, volatile_directories, title_style, index_style):
    # INDEX 페이지 생성 (중앙 정렬, 글자 크기 조절)
    story.append(Spacer(1, 0.4 * inch))
    story.append(Paragraph("INDEX", title_style))
    story.append(Spacer(1, 0.8 * inch))

    # 지정된 순서에 따라 디렉토리를 나열합니다.
    for dir_name in directory_order:
        if dir_name in volatile_directories:
            story.append(Paragraph(f"-> {dir_name}", index_style))
            story.append(Spacer(1, 0.35 * inch))
        else:
            story.append(Paragraph(f"-> {dir_name} (Not Collected!!)", index_style))
            story.append(Spacer(1, 0.35 * inch))

    #story.append(PageBreak())

def main():
    user_input = input("Enter the directory path for parsing: ")
    base_directory = r"{}".format(user_input)

    # TimeStamp.log 파일 경로 설정 (Volatile_Information 디렉토리가 아닌 사용자가 제공한 디렉토리 내)
    Info_path = os.path.join(base_directory, 'TimeStamp.log')
    if not os.path.exists(Info_path):
        print("TimeStamp.log file not found in the given path.")
        return

    # Set the path for the Volatile_Information folder
    volatile_info_path = os.path.join(base_directory, 'Volatile_Information')

    pdf_filename = 'Forensic_Windows_Report.pdf'
    doc = SimpleDocTemplate(pdf_filename, pagesize=landscape(letter))
    story = []

    # Add content to the first page (center alignment, adjust font size, set font style)
    title_style = ParagraphStyle('TitleStyle', alignment=TA_CENTER, fontSize=36, fontName='Helvetica-Bold')
    normal_style = ParagraphStyle('NormalStyle', alignment=TA_CENTER, fontSize=22, fontName='Helvetica-Bold')

    # Add Spacer to center the content on the first page
    story.append(Spacer(1, 1.3 * inch))
    story.append(Paragraph("WINDOWS LIVE FORENSIC RESULT", title_style))
    story.append(Spacer(1, 1.3 * inch))
    case, name, active_start_time = extract_case_name_start_time(Info_path)
    story.append(Paragraph(f"CASE NAME: {case}", normal_style))
    story.append(Spacer(1, 0.4 * inch))
    story.append(Paragraph(f"ANALYST NAME: {name}", normal_style))
    story.append(Spacer(1, 0.4 * inch))  # Add spacer
    story.append(Paragraph(f"ACTIVE SCRIPT START TIME: {active_start_time}", normal_style))
    story.append(PageBreak())

    # Code to retrieve the list of subdirectories within the Volatile_Information directory
    volatile_directories = get_volatile_info_directories(volatile_info_path)

    # Add the INDEX page (center alignment, adjust font size, set font style)
    index_style = ParagraphStyle('IndexStyle', alignment=TA_JUSTIFY, fontSize=24,
                                 fontName='Helvetica-Bold')  # Maintain font size at 24
    create_index_page(story, volatile_directories, title_style, index_style)

    while True:
        hash_option = input(
            "Choose the hash algorithm for the report:\n1) Display MD5, SHA1\n2) Display SHA256\nEnter 1 or 2: ")
        if hash_option in ["1", "2"]:
            hash_option = int(hash_option)
            break
        else:
            print("Invalid choice. Please enter 1 or 2.")

    # Add page separation
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
                    print(f"Timestamp found: {file_or_action.lower()} - {timestamp}")  # Added debugging log

    # Modified os.walk: Only traverses inside the Volatile_Information folder
    for root, dirs, files in os.walk(volatile_info_path):
        if "HASH" in root:
            continue

        if not files:
            continue

        display_path = root.replace(base_directory, '').lstrip('\\')

        # Set style to increase the font size of the directory path
        directory_style = ParagraphStyle(
            'DirectoryStyle',
            parent=getSampleStyleSheet()['Normal'],
            fontSize=12,
            leading=16,
        )

        story.append(Paragraph(f"{display_path}", directory_style))
        story.append(Spacer(1, 5))  # Here, 5 represents the height of the space (in points)

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
            timestamp = timestamp_dict.get(file_lower, "N/A")  # Initialize the timestamp for each file

            # Determine the path for the hash directory
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
                        print(f"Matching {file_lower} with timestamp {timestamp} for key {key}")  # added for debugging log
                        break

            # 디버깅 로그 추가: 파일과 매핑되는 타임스탬프 출력
            print(f"File: {file}, Timestamp: {timestamp}")
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

    doc.build(story)
    print(f"PDF report has been created: {pdf_filename}")

if __name__ == "__main__":
    main()