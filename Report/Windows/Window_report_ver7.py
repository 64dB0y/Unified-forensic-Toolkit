# If a file name is too long, it is abbreviated with "..."
import os
import re
from reportlab.lib.pagesizes import letter, landscape
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer

def abbreviate_filename(filename, max_length=30, start=17, end=17):
    """Abbreviate the filename if it exceeds the max_length."""
    if len(filename) > max_length:
        return f"{filename[:start]}...{filename[-end:]}"
    return filename

# Basic PDF file creation setup
pdf_filename = 'Forensic_Windows_Report.pdf'
doc = SimpleDocTemplate(pdf_filename, pagesize=landscape(letter))
story = []

# Target directory
base_directory = 'D:\\for_rep_result\\DESKTOP-2PH1IF1_2023-11-19_22-49-53'

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
                print(f"Timestamp found for action '{file_or_action}': {timestamp}")  # Debugging output

# Walk through the directory
for root, dirs, files in os.walk(base_directory):
    if "HASH" in root or root == base_directory:
        continue

    if files:
        display_path = root.replace(base_directory, '').lstrip('\\')
        story.append(Paragraph(f"{display_path}", getSampleStyleSheet()['Normal']))

        data = [["File Name", "Timestamp", "SHA256 Hash"]]

        for file in files:
            if file == 'TimeStamp.log' or file.endswith('.hash'):
                continue

            # Abbreviate long filenames
            file_display = abbreviate_filename(file)

            file_lower = file.lower()
            timestamp = "N/A"

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

            hash_sha256 = "N/A"

            print(f"File: {file_display}, Timestamp: {timestamp}")  # Debugging output
            data.append([file_display, timestamp, hash_sha256])

        # Adjust column widths to maintain the overall table size
        table = Table(data, colWidths=[3.5 * inch, 1.5 * inch, 4 * inch])
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