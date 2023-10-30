from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Spacer
from reportlab.lib import colors
from reportlab.platypus import Paragraph

def read_arp_cache_info(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    return lines

def parse_arp_cache_info(lines):
    arp_cache = []

    # Flag to start parsing the ARP cache table
    start_parsing = False

    for line in lines:
        # Check for the line that indicates the start of the ARP cache table
        if "HW\tIP\ttype\taddress" in line:
            start_parsing = True
            continue

        if start_parsing:
            parts = line.split()
            if len(parts) >= 4:
                hw, ip, arp_type, address = parts[:4]
                arp_cache.append({
                    "HW": hw,
                    "IP": ip,
                    "Type": arp_type,
                    "Address": address
                })

    return arp_cache

def create_arp_cache_info_pdf(filename, arp_cache):
    doc = SimpleDocTemplate(filename, pagesize=letter, leftMargin=30)
    elements = []

    # Title paragraph
    title = Paragraph("<b>ARP Cache Info</b>", style=ParagraphStyle(name='Title', fontSize=18, alignment=1))
    elements.append(title)
    elements.append(Spacer(1, 12))

    data = [["HW", "IP", "Type", "Address"]]
    for entry in arp_cache:
        data.append([
            entry["HW"],
            entry["IP"],
            entry["Type"],
            entry["Address"]
        ])

    table = Table(data)
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.black)
    ]))

    elements.append(table)
    doc.build(elements)

if __name__ == "__main__":
    arp_info = read_arp_cache_info('ARP.txt')
    arp_cache = parse_arp_cache_info(arp_info)
    create_arp_cache_info_pdf('arp_cache_info.pdf', arp_cache)
