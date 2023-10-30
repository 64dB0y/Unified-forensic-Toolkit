import matplotlib.pyplot as plt
from datetime import datetime
from collections import Counter

from reportlab.lib.styles import getSampleStyleSheet
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle
from reportlab.lib import colors
from reportlab.platypus import Image
from io import BytesIO

def read_data(filename):
    data = []
    with open(filename, 'r', encoding='utf-8') as file:
        for line in file:
            parts = line.strip().split('|')
            timestamp = datetime.strptime(parts[0], '%Y-%m-%d %H:%M:%S')
            url = parts[-1]
            data.append((timestamp, url))
    return data


def process_data(data):
    # Count occurrences of each date and hour
    date_counts = Counter(timestamp.date() for timestamp, _ in data)
    hour_counts = Counter(timestamp.hour for timestamp, _ in data)

    # Sort the dates and hours for plotting
    sorted_dates = sorted(date_counts.keys())
    sorted_hours = sorted(hour_counts.keys())
    date_counts = [date_counts[date] for date in sorted_dates]
    hour_counts = [hour_counts[hour] for hour in sorted_hours]

    return sorted_dates, date_counts, sorted_hours, hour_counts

def create_pdf(filename, sorted_dates, date_counts, sorted_hours, hour_counts):
    # Create a PDF with bar charts for date and hour analysis
    doc = SimpleDocTemplate(filename, pagesize=letter)

    elements = []

    # Draw the date analysis chart
    plt.figure(figsize=(8, 4))
    plt.bar(sorted_dates, date_counts)
    plt.xlabel('Date')
    plt.ylabel('Usage Count')
    plt.title('Web Browser Usage by Date')
    plt.xticks(rotation=45)
    plt.tight_layout()
    date_graph = BytesIO()
    plt.savefig(date_graph, format="png")
    plt.close()
    date_graph.seek(0)

    # Draw the hour analysis chart
    plt.figure(figsize=(8, 4))
    plt.bar(sorted_hours, hour_counts)
    plt.xlabel('Hour of the Day')
    plt.ylabel('Usage Count')
    plt.title('Web Browser Usage by Hour')
    plt.xticks(range(24))
    plt.tight_layout()
    hour_graph = BytesIO()
    plt.savefig(hour_graph, format="png")
    plt.close()
    hour_graph.seek(0)

    # Create and add paragraphs for each graph
    styles = getSampleStyleSheet()

    # Add the graphs to the PDF elements
    date_graph_img = Image(date_graph, width=500, height=250)
    hour_graph_img = Image(hour_graph, width=500, height=250)

    elements.append(date_graph_img)
    elements.append(Spacer(1, 12))
    elements.append(hour_graph_img)
    elements.append(PageBreak())

    # Add text table for date analysis
    date_table_data = [['Date', 'Usage Count']] + [[str(date), str(count)] for date, count in zip(sorted_dates, date_counts)]
    date_table = Table(date_table_data, colWidths=[100, 100])
    date_table.setStyle(TableStyle([('BACKGROUND', (0, 0), (-1, 0), colors.grey),
                                    ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                                    ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                                    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                                    ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                                    ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
                                    ('GRID', (0, 0), (-1, -1), 1, colors.black)]))
    elements.append(date_table)
    elements.append(PageBreak())

    # Add text table for hour analysis
    hour_table_data = [['Hour', 'Usage Count']] + [[str(hour), str(count)] for hour, count in zip(sorted_hours, hour_counts)]
    hour_table = Table(hour_table_data, colWidths=[100, 100])
    hour_table.setStyle(TableStyle([('BACKGROUND', (0, 0), (-1, 0), colors.grey),
                                    ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                                    ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                                    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                                    ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                                    ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
                                    ('GRID', (0, 0), (-1, -1), 1, colors.black)]))
    elements.append(hour_table)

    # Build the PDF
    doc.build(elements)

if __name__ == "__main__":
    data = read_data('aa.txt')
    sorted_dates, date_counts, sorted_hours, hour_counts = process_data(data)
    create_pdf('analysis_report.pdf', sorted_dates, date_counts, sorted_hours, hour_counts)