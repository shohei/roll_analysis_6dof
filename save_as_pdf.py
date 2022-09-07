from fpdf import FPDF
pdf = FPDF()
pdf.set_font("courier", size = 12)

s = open('for006.dat').read()
pages = s.split('THE USAF AUTOMATED MISSILE DATCOM')
pages = pages[1:]
for i, page in enumerate(pages):
    pdf.add_page()
    pdf.cell(200, 4, txt = "Page "+str(i),
         ln = 1, align = 'L')
    pdf.multi_cell(200, 4, txt = page,
         align = 'L')
 
pdf.output("for006.pdf")  