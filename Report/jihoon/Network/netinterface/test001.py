from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Spacer, PageBreak
from reportlab.lib import colors
from reportlab.platypus import Paragraph

from io import BytesIO
import re

def read_network_info(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    return lines


def parse_network_info(lines):
    interfaces = []
    current_interface = {}

    for line in lines:
        # Split the line into key and value based on the first space
        parts = line.strip().split(' ', 1)
        if len(parts) >= 2:
            key, value = parts[0], parts[1]
            if re.match(r'^[a-zA-Z0-9]+:', key):
                if current_interface:
                    interfaces.append(current_interface)
                current_interface = {'name': key[:-1]}
            if key.startswith("RX") or key.startswith("TX"):
                # If the key starts with "RX" or "TX", append to previous "RX" or "TX" value
                current_interface[key] = current_interface.get(key, '') + ' ' + value
            else:
                current_interface[key] = value

    if current_interface:
        interfaces.append(current_interface)

    return interfaces







def create_network_info_pdf(filename, interfaces):
    doc = SimpleDocTemplate(filename, pagesize=letter)
    elements = []

    # Title paragraph
    title = Paragraph("<b>NetInterface Info</b>", style=ParagraphStyle(name='Title', fontSize=18, alignment=1))
    elements.append(title)
    elements.append(Spacer(1, 12))

    for interface in interfaces:
        data = [[key, value] for key, value in interface.items() if key != 'name']
        table = Table(data)
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
            ('GRID', (0, 0), (-1, -1), 1, colors.black)
        ]))

        elements.append(table)
        elements.append(Spacer(1, 12))

    doc.build(elements)

if __name__ == "__main__":
    network_info = read_network_info('netinterface.txt')
    interfaces = parse_network_info(network_info)
    create_network_info_pdf('netinterface_info.pdf', interfaces)