from reportlab.lib.pagesizes import landscape, letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Spacer, Paragraph
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from io import BytesIO

def read_system_info(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    return lines

def parse_system_info(lines):
    system_info_entries = []
    current_category = None

    for line in lines:
        line = line.strip()

        if line.startswith("---"):
            if current_category is not None:
                system_info_entries.append(current_category)
            current_category = {
                "Category": line.strip("-").strip(),
                "Content": []
            }
        else:
            if current_category is not None:
                current_category["Content"].append(line)

    if current_category is not None:
        system_info_entries.append(current_category)

    return system_info_entries

def create_system_info_pdf(filename, system_info_entries):
    doc = SimpleDocTemplate(filename, pagesize=landscape(letter))
    elements = []

    styles = getSampleStyleSheet()
    title_style = styles['Title']
    title = Paragraph("<b>--System Info--</b>", title_style)
    elements.append(title)
    elements.append(Spacer(1, 12))

    for entry in system_info_entries:
        elements.append(Paragraph(entry["Category"], title_style))
        data = []

        # Set background color of the first row to yellow
        table_style = [
            ('BACKGROUND', (0, 0), (-1, 0), colors.yellow),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.black),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('GRID', (0, 0), (-1, -1), 1, colors.black),
            ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black)
        ]

        if entry["Category"] == "Block Devices":
            header = ["NAME", "MAJ:MIN", "RM", "SIZE", "RO", "TYPE", "MOUNTPOINTS"]
            data.append([Paragraph(col, styles['Normal']) for col in header])

            skip_first_line = True  # 첫 번째 줄을 스킵하기 위한 플래그

            for line in entry["Content"]:
                if skip_first_line:
                    skip_first_line = False
                    continue  # Skip the first line

                # Split the data into columns
                columns = line.split()
                data.append([Paragraph(col, styles['Normal']) for col in columns])

        elif entry["Category"] == "Hardware Info":
            for line in entry["Content"]:
                if not line.strip():
                    continue  # Skip empty lines

                if line.startswith("*"):
                    data.append([Paragraph(line, styles['Normal'])])
                else:
                    key_value = line.split(":", 1)
                    if len(key_value) == 2:
                        key, value = key_value
                        data.append([
                            Paragraph(key.strip(), styles['Normal']),
                            Paragraph(value.strip(), styles['Normal'])
                        ])

        elif entry["Category"] == "CPU Info" :
            for line in entry["Content"]:
                if not line.strip():
                    continue  # Skip empty lines
                key_value = line.split(":", 1)
                if len(key_value) == 2:
                    key, value = key_value
                    data.append([
                        Paragraph(key.strip(), styles['Normal']),
                        Paragraph(value.strip(), styles['Normal'])
                    ])

        elif entry["Category"] == "USB Devices":
            data.append(["BUS", "Contents"])
            for line in entry["Content"]:
                if not line.strip():
                    continue  # Skip empty lines
                key_value = line.split(":", 1)
                if len(key_value) == 2:
                    key, value = key_value
                    data.append([
                        Paragraph(key.strip(), styles['Normal']),
                        Paragraph(value.strip(), styles['Normal'])
                    ])

        elif entry["Category"] == "Loaded Kernel Modules":
            data.append(["Module", "Size", "Used by"])
            for line in entry["Content"]:
                if not line.strip():
                    continue  # Skip empty lines
                columns = line.split()
                if len(columns) == 3:
                    data.append([Paragraph(col, styles['Normal']) for col in columns])


        elif entry["Category"] == "Disk Space Info":
            data.append(["Filesystem", "Size", "Used", "Avail", "Use%", "Mounted on"])
            for line in entry["Content"]:
                if not line.strip():
                    continue  # Skip empty lines
                columns = line.split()
                if len(columns) == 6:
                    data.append([Paragraph(col, styles['Normal']) for col in columns])

        elif entry["Category"] == "Memory Info":
            header = ["", "total", "used", "free", "shared", "buff/cache", "available"]
            data.append([Paragraph(col, styles['Normal']) for col in header])

            is_attribute_row = True

            for line in entry["Content"]:
                if is_attribute_row:
                    is_attribute_row = False
                    continue  # Skip the attribute row

                if not line.strip():
                    continue

                columns = line.split()
                category = columns[0]
                data.append([Paragraph(category, styles['Normal'])] + [Paragraph(col, styles['Normal']) for col in columns[1:]])

        if data:  # Check if data is not empty
            table = Table(data, colWidths='*')
            table.setStyle(TableStyle(table_style))
            elements.append(table)
            elements.append(Spacer(1, 12))

    doc.build(elements)

if __name__ == "__main__":
    system_info_entries = parse_system_info(read_system_info('system_info.txt'))
    create_system_info_pdf('system_info.pdf', system_info_entries)