import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:epic_dice_events/LogInPage.dart';
import 'package:epic_dice_events/Authenticate.dart';
import 'package:epic_dice_events/main.dart' as app;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Lista pentru a stoca toate rezultatele testului
  final List<Map<String, dynamic>> testResults = [];

  // Funcție pentru a adăuga rezultate în raport
  void addResult(String className, String testCase, bool status, {String? error}) {
    testResults.add({
      'className': className,
      'testCase': testCase,
      'status': status ? 'Passed' : 'Failed',
      'error': error ?? ''
    });
  }

  group('Authenticate Page Tests', () {

    setUp(() {
      //print("Inceperea aplicației...");
      app.main();
      Future.delayed(Duration(seconds: 5));
    });

    testWidgets('Verify title of the page', (tester) async {
    //  print("Incep testul: Verify title of the page");
      await tester.pumpAndSettle(Duration(seconds: 10)); // Așteaptă finalizarea animațiilor
      await Future.delayed(Duration(seconds: 10)); // Așteaptă ca pagina să se încarce
      try {
        expect(find.text('EpicDiceEvents'), findsOneWidget);
        addResult("Authentication", "Authentication Page Title", true);
       // generateReport(testResults);
      } catch (e) {
        addResult("Authentication", 'Authentication Page Title', false, error: e.toString());
       // generateReport(testResults);
      }
    });

    testWidgets('Verify presence of Log In button', (tester) async {
     // print("Incep testul: Verify presence of Log In button");
      await tester.pumpAndSettle(); // Așteaptă finalizarea animațiilor
      try {
        expect(find.text('Log In'), findsOneWidget);
        addResult('Authenticate', 'Verify presence of Log In button', true);
      } catch (e) {
        addResult('Authenticate', 'Verify presence of Log In button', false, error: e.toString());
      }
    });

    testWidgets('Verify presence of Sign Up button', (tester) async {
      //print("Incep testul: Verify presence of Sign Up button");
      await tester.pumpAndSettle(); // Așteaptă finalizarea animațiilor
      try {
        expect(find.text('Sign Up'), findsOneWidget);
        addResult('Authenticate', 'Verify presence of Sign Up button', true);
      } catch (e) {
        addResult('Authenticate', 'Verify presence of Sign Up button', false, error: e.toString());
      }
    });

    testWidgets('Simulate Log In button press', (tester) async {
    //  print("Incep testul: Simulate Log In button press");
      await tester.pumpAndSettle(); // Așteaptă finalizarea animațiilor
      try {
        await tester.tap(find.text('Log In'));
        await tester.pumpAndSettle(); // Așteaptă finalizarea navigării
        //await tester.pumpAndSettle(Duration(seconds: 5));
        expect(find.byType(LogInPage), findsOneWidget);
        addResult('Authenticate', 'Simulate Log In button press', true);
      } catch (e) {
        addResult('Authenticate', 'Simulate Log In button press', false, error: e.toString());
      }
      print(testResults);

    });
  });

}

// Funcția pentru generarea raportului HTML
void generateReport(List<Map<String, dynamic>> results) {
  print("Generale raport");
  final StringBuffer htmlBuffer = StringBuffer();
  int totalTests = results.length;
  int totalPassedTests = results.where((result) => result['status'] == 'Passed').length;

  htmlBuffer.writeln('''<html>
  <head>
      <title>Test Report</title>
      <style>
          table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
          th, td { border: 1px solid black; padding: 8px; text-align: left; }
          th { background-color: #f2f2f2; }
          .passed { background-color: #d4edda; color: #155724; }
          .failed { background-color: #f8d7da; color: #721c24; }
      </style>
  </head>
  <body>
      <h1>Test Report</h1>
      <h2>Overall Summary</h2>
      <p>Total Tests: $totalTests</p>
      <p>Passed Tests: $totalPassedTests</p>
      <p>Failed Tests: ${totalTests - totalPassedTests}</p>
      <p>Success Rate: ${(totalPassedTests / totalTests * 100).toStringAsFixed(2)}%</p>
      <h2>Test Results</h2>
      <table>
          <tr>
              <th>Class Name</th>
              <th>Test Case</th>
              <th>Status</th>
              <th>Error</th>
          </tr>
  ''');

  for (var result in results) {
    final statusClass = result['status'] == 'Passed' ? 'passed' : 'failed';
    htmlBuffer.writeln('''<tr>
            <td>${result['className']}</td>
            <td>${result['testCase']}</td>
            <td class="$statusClass">${result['status']}</td>
            <td>${result['error']}</td>
        </tr>
      ''');
  }

  htmlBuffer.writeln('</table></body></html>');

  // Scrierea raportului într-un fișier

  const String reportPath = 'test_report.html';
  final file = File(reportPath);

  try {
    file.writeAsStringSync(htmlBuffer.toString());
    print("Raport salvat la: $reportPath");
  } catch (e) {
    print("Eroare la salvarea raportului: $e");
  }

}
