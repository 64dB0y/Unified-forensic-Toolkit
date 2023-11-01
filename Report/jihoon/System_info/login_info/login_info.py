from reportlab.lib.pagesizes import landscape, letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Spacer, Paragraph
from reportlab.lib.styles import getSampleStyleSheet
from io import BytesIO

def read_login_info(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    return lines

def parse_login_info(lines):
    login_info_entries = []

    for line in lines:
        columns = line.strip().split('\t')

        if len(columns) == 8:
            username, domain, logon_type, logon_time, sid, sid_group, ip_address, host_name = columns
            login_info_entries.append({
                "Username": username,
                "Domain": domain,
                "Logon Type": logon_type,
                "Logon Time": logon_time,
                "SID": sid,
                "SID Group": sid_group,
                "IP Address": ip_address,
                "Host Name": host_name
            })

    return login_info_entries

def create_login_info_pdf(filename, login_info_entries):
    doc = SimpleDocTemplate(filename, pagesize=landscape(letter))
    elements = []

    styles = getSampleStyleSheet()
    title_style = styles['Title']
    title = Paragraph("<b>Login Info</b>", title_style)
    elements.append(title)
    elements.append(Spacer(1, 12))

    data = [
        ["Username", "Domain", "Logon Type", "Logon Time", "SID", "SID Group", "IP Address", "Host Name"]
    ]

    for entry in login_info_entries:
        data.append([
            Paragraph(entry["Username"], styles['Normal']),
            Paragraph(entry["Domain"], styles['Normal']),
            Paragraph(entry["Logon Type"], styles['Normal']),
            Paragraph(entry["Logon Time"], styles['Normal']),
            Paragraph(entry["SID"], styles['Normal']),
            Paragraph(entry["SID Group"], styles['Normal']),
            Paragraph(entry["IP Address"], styles['Normal']),
            Paragraph(entry["Host Name"], styles['Normal'])
        ])

    table_style = [
        ('BACKGROUND', (0, 0), (-1, 0), (0.7, 0.7, 0.7)),
        ('TEXTCOLOR', (0, 0), (-1, 0), (1, 1, 1)),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.black),
        ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black)
    ]

    table = Table(data, colWidths='*')
    table.setStyle(TableStyle(table_style))
    elements.append(table)
    doc.build(elements)

if __name__ == "__main__":
    login_info_entries = parse_login_info(read_login_info('login_info.txt'))
    create_login_info_pdf('login_info.pdf', login_info_entries)
