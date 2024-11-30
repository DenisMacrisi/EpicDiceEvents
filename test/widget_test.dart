import 'dart:io';
import 'package:epic_dice_events/AddEventPage.dart';
import 'package:epic_dice_events/EventListFiltredPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:epic_dice_events/LogInPage.dart';
import 'package:epic_dice_events/Authenticate.dart';

Future<void> main() async {

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

  // Rularea testelor
  runAuthenticateTests(addResult);


  tearDownAll(() {
    generateReport(testResults);
  });
}

// Funcția pentru testele Authenticate
void runAuthenticateTests(Function addResult) {
  testWidgets('Authenticate page has Log In button', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Authenticate()));

    try {
      expect(find.text('Log In'), findsOneWidget);
      addResult('Authenticate.dart', 'Log In button', true);
    } catch (e) {
      addResult('Authenticate.dart', 'Log In button', false, error: e.toString());
    }
  });

  testWidgets('Authenticate page has Sign Up button', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Authenticate()));

    try {
      expect(find.text('Sign Up'), findsOneWidget);
      addResult('Authenticate.dart', 'Sign Up button', true);
    } catch (e) {
      addResult('Authenticate.dart', 'Sign Up button', false, error: e.toString());
    }
  });

  testWidgets('Authenticate page has EpicDiceEvents title', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Authenticate()));

    try {
      expect(find.text('EpicDiceEvents'), findsOneWidget);
      addResult('Authenticate.dart', 'EpicDiceEvents title', true);
    } catch (e) {
      addResult('Authenticate.dart', 'EpicDiceEvents title', false, error: e.toString());
    }
  });
}


// Funcția pentru generarea raportului HTML
void generateReport(List<Map<String, dynamic>> results) {
  final StringBuffer htmlBuffer = StringBuffer();
  int totalTests = results.length;
  int totalPassedTests = results
      .where((result) => result['status'] == 'Passed')
      .length;

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
      <p>Success Rate: ${(totalPassedTests / totalTests * 100).toStringAsFixed(
      2)}%</p>
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
  file.writeAsStringSync(htmlBuffer.toString());
}