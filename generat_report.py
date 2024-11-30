import json
import sys
from pathlib import Path

def generate_html_report(test_results):
    total_tests = len(test_results)
    total_passed_tests = sum(1 for result in test_results if result['status'] == 'Passed')
    
    html_buffer = f'''
    <html>
    <head>
        <title>Test Report</title>
        <style>
            table {{ width: 100%; border-collapse: collapse; margin-bottom: 20px; }}
            th, td {{ border: 1px solid black; padding: 8px; text-align: left; }}
            th {{ background-color: #f2f2f2; }}
            .passed {{ background-color: #d4edda; color: #155724; }}
            .failed {{ background-color: #f8d7da; color: #721c24; }}
        </style>
    </head>
    <body>
        <h1>Test Report</h1>
        <h2>Overall Summary</h2>
        <p>Total Tests: {total_tests}</p>
        <p>Passed Tests: {total_passed_tests}</p>
        <p>Failed Tests: {total_tests - total_passed_tests}</p>
        <p>Success Rate: {(total_passed_tests / total_tests * 100):.2f}%</p>
        <h2>Test Results</h2>
        <table>
            <tr>
                <th>Class Name</th>
                <th>Test Case</th>
                <th>Status</th>
                <th>Error</th>
            </tr>
    '''
    
    for result in test_results:
        status_class = 'passed' if result['status'] == 'Passed' else 'failed'
        html_buffer += f'''
        <tr>
            <td>{result['className']}</td>
            <td>{result['testCase']}</td>
            <td class="{status_class}">{result['status']}</td>
            <td>{result['error']}</td>
        </tr>
        '''
    
    html_buffer += '''
        </table>
    </body>
    </html>
    '''
    
    return html_buffer

def main(test_results_json):
    # Analizează rezultatele testului din argumentul JSON
    try:
        test_results = json.loads(test_results_json)
    except json.JSONDecodeError:
        print("Eroare la analiza JSON. Asigurați-vă că formatul este corect.")
        sys.exit(1)

    # Generează raportul HTML
    report_html = generate_html_report(test_results)
    
    # Scrie raportul într-un fișier HTML
    report_path = Path('test_report.html')
    with open(report_path, 'w') as report_file:
        report_file.write(report_html)
    
    print(f"Raport salvat la: {report_path}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Utilizare: python generate_report.py '<test_results_json>'")
        sys.exit(1)

    test_results_json = sys.argv[1]
    main(test_results_json)
