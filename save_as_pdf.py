from fpdf import FPDF
import os
pdf = FPDF()
pdf.set_font("courier", size = 11)

s = open('for006.dat').read()
pages = s.split('THE USAF AUTOMATED MISSILE DATCOM')
pages = pages[1:]
for i, page in enumerate(pages):
    pdf.add_page()
    pdf.cell(240, 4, txt = "Page "+str(i),
         ln = 1, align = 'L')
    pdf.multi_cell(240, 4, txt = page,
         align = 'L')
 
pdf.output("for006.pdf")  
os.system('open for006.pdf')