import argparse
import json
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph
from PyPDF2 import PdfReader, PdfWriter

def read_config(file_path):
    with open(file_path, 'r') as f:
        return json.load(f)

def create_pay_stub(filename, config, hourly_rate, hours_worked):
    # Extract data from config
    company_name = config["company_name"]
    company_address = config["company_address"]
    employee_name = config["employee_name"]
    employee_address = config["employee_address"]
    pay_period = config["pay_period"]
    pay_date = config["pay_date"]

    # Calculate gross pay
    gross_pay = hourly_rate * hours_worked

    # Define realistic deductions
    federal_income_tax = 0.10 * gross_pay  # Approximate federal tax rate
    social_security_tax = 0.062 * gross_pay  # Social Security tax rate
    medicare_tax = 0.0145 * gross_pay  # Medicare tax rate
    nj_state_income_tax = 0.05 * gross_pay  # Approximate NJ state income tax rate
    nj_ui = 0.003 * gross_pay  # NJ State Unemployment Insurance
    nj_di = 0.0035 * gross_pay  # NJ Disability Insurance

    # Create a PDF document
    doc = SimpleDocTemplate(filename, pagesize=letter)
    elements = []

    # Define styles
    styles = getSampleStyleSheet()
    title_style = styles['Title']
    normal_style = styles['Normal']

    # Add company details
    elements.append(Paragraph(f"Company Name: {company_name}", title_style))
    elements.append(Paragraph(f"Company Address: {company_address}", normal_style))
    elements.append(Paragraph(f"Employee Name: {employee_name}", normal_style))
    elements.append(Paragraph(f"Employee Address: {employee_address}", normal_style))
    elements.append(Paragraph(f"Pay Period: {pay_period}", normal_style))
    elements.append(Paragraph(f"Pay Date: {pay_date}", normal_style))
    elements.append(Paragraph("<br/>", normal_style))

    # Add hours worked and gross pay
    deductions = {
        'Federal Income Tax': federal_income_tax,
        'Social Security Tax': social_security_tax,
        'Medicare Tax': medicare_tax,
        'NJ State Income Tax': nj_state_income_tax,
        'NJ State Unemployment Insurance': nj_ui,
        'NJ Disability Insurance': nj_di
    }

    net_pay = gross_pay - sum(deductions.values())

    data = [
        ['Hours Worked:', f'{hours_worked:.2f} hours'],
        ['Hourly Rate:', f'${hourly_rate:.2f}'],
        ['Gross Pay:', f'${gross_pay:.2f}'],
        ['Federal Income Tax:', f'${federal_income_tax:.2f}'],
        ['Social Security Tax:', f'${social_security_tax:.2f}'],
        ['Medicare Tax:', f'${medicare_tax:.2f}'],
        ['NJ State Income Tax:', f'${nj_state_income_tax:.2f}'],
        ['NJ State Unemployment Insurance:', f'${nj_ui:.2f}'],
        ['NJ Disability Insurance:', f'${nj_di:.2f}'],
        ['Total Deductions:', f'${sum(deductions.values()):.2f}'],
        ['Net Pay:', f'${net_pay:.2f}'],
    ]

    table = Table(data, colWidths=[250, 100])
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('GRID', (0, 0), (-1, -1), 1, colors.black),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
    ]))

    elements.append(table)

    # Build PDF
    doc.build(elements)

def create_payroll_summary(filename, config, total_gross_pay, num_employees):
    # Extract data from config
    company_name = config["company_name"]

    # Define company payroll taxes
    social_security_employer = 0.062 * total_gross_pay  # Employer's contribution to Social Security
    medicare_employer = 0.0145 * total_gross_pay  # Employer's contribution to Medicare

    # Create a PDF document for payroll summary
    doc = SimpleDocTemplate(filename, pagesize=letter)
    elements = []

    # Define styles
    styles = getSampleStyleSheet()
    title_style = styles['Title']
    normal_style = styles['Normal']

    # Add company payroll summary
    elements.append(Paragraph(f"Company Name: {company_name}", title_style))
    elements.append(Paragraph("<br/>", normal_style))
    elements.append(Paragraph(f"Total Gross Pay for {num_employees} Employees: ${total_gross_pay:.2f}", normal_style))
    elements.append(Paragraph(f"Employer's Contribution to Social Security: ${social_security_employer:.2f}", normal_style))
    elements.append(Paragraph(f"Employer's Contribution to Medicare: ${medicare_employer:.2f}", normal_style))
    elements.append(Paragraph("<br/>", normal_style))
    elements.append(Paragraph(f"Total Employer Contributions: ${social_security_employer + medicare_employer:.2f}", normal_style))

    # Build PDF
    doc.build(elements)

def append_pdfs(output_filename, pdfs):
    pdf_writer = PdfWriter()

    for pdf in pdfs:
        pdf_reader = PdfReader(pdf)
        for page in range(len(pdf_reader.pages)):
            pdf_writer.add_page(pdf_reader.pages[page])

    with open(output_filename, 'wb') as out:
        pdf_writer.write(out)

def main():
    parser = argparse.ArgumentParser(description="Generate a pay stub or payroll summary PDF, and optionally append PDFs.")
    parser.add_argument('filename', type=str, help="The name of the output PDF file.")
    parser.add_argument('hours_worked', type=float, help="The number of hours worked.")
    parser.add_argument('hourly_rate', type=float, help="The hourly rate of pay.")
    parser.add_argument('--Payroll', action='store_true', help="Generate a payroll summary instead of a pay stub.")
    parser.add_argument('--config', type=str, default='config.json', help="Path to the configuration file.")
    parser.add_argument('--appendpages', nargs='*', help="List of PDF files to append together.")
    
    args = parser.parse_args()
    
    # Read configuration from file
    config = read_config(args.config)
    num_employees = 1  # Number of employees, adjust as needed

    if args.Payroll:
        total_gross_pay = args.hourly_rate * args.hours_worked * num_employees
        create_payroll_summary(
            filename=args.filename,
            config=config,
            total_gross_pay=total_gross_pay,
            num_employees=num_employees
        )
    else:
        create_pay_stub(
            filename=args.filename,
            config=config,
            hourly_rate=args.hourly_rate,
            hours_worked=args.hours_worked
        )

    if args.appendpages:
        append_pdfs(
            output_filename=args.filename,
            pdfs=args.appendpages
        )

if __name__ == "__main__":
    main()
