from fpdf import FPDF

class PDF(FPDF):
    def header(self):
        pass

    def footer(self):
        self.set_y(-15)
        self.set_font("Arial", "I", 8)
        self.cell(0, 10, f"Page {self.page_no()}", 0, 0, "C")

    def chapter_title(self, title):
        self.set_font("Arial", "B", 12)
        self.cell(0, 12, title, 0, 1)

    def chapter_body(self, body):
        self.set_font("Arial", "", 12)
        self.multi_cell(0, 4, body)  # 줄 간격을 조절
        self.ln(5)  # 더 작은 줄 간격으로 조절

def text_to_pdf(input_file, output_file):
    pdf = PDF()
    pdf.add_page()
    pdf.set_left_margin(10)
    pdf.set_right_margin(10)

    # 텍스트 파일 열기
    with open(input_file, "r", encoding="utf-8") as f:
        text = f.read()

    pdf.chapter_body(text)
    pdf.output(output_file)

if __name__ == "__main__":
    input_file = "pstree_info.txt"
    output_file = "pstree_info.pdf"
    text_to_pdf(input_file, output_file)
