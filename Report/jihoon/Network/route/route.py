from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Spacer
from reportlab.lib import colors
from reportlab.platypus import Paragraph
from io import BytesIO
import re

def read_network_info(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    return lines

def parse_network_info(lines):
    routes = []

    # Flag to start parsing the route table
    start_parsing = False

    for line in lines:
        # Check for the line that indicates the start of the route table
        if "Destination" in line and "Gateway" in line:
            start_parsing = True
            continue

        if start_parsing:
            parts = line.split()
            if len(parts) >= 7:
                destination, gateway, genmask, flags, metric, ref, use, iface = parts[:8]
                routes.append({
                    "Destination": destination,
                    "Gateway": gateway,
                    "Genmask": genmask,
                    "Flags": flags,
                    "Metric": metric,
                    "Ref": ref,
                    "Use": use,
                    "Iface": iface
                })

    return routes

def create_network_info_pdf(filename, routes):
    doc = SimpleDocTemplate(filename, pagesize=letter, leftMargin=30)
    elements = []

    # Title paragraph
    title = Paragraph("<b>Route Table Info</b>", style=ParagraphStyle(name='Title', fontSize=18, alignment=1))
    elements.append(title)
    elements.append(Spacer(1, 12))

    data = [["Destination", "Gateway", "Genmask", "Flags", "Metric", "Ref", "Use", "Iface"]]
    for route in routes:
        data.append([
            route["Destination"],
            route["Gateway"],
            route["Genmask"],
            route["Flags"],
            route["Metric"],
            route["Ref"],
            route["Use"],
            route["Iface"]
        ])

    table = Table(data)
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),  # 표를 왼쪽으로 정렬
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.black)
    ]))

    elements.append(table)
    doc.build(elements)

if __name__ == "__main__":
    route_info = read_network_info('route.txt')
    routes = parse_network_info(route_info)
    create_network_info_pdf('route_info.pdf', routes)
