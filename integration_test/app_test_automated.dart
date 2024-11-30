import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:epic_dice_events/LogInPage.dart';
import 'package:epic_dice_events/Authenticate.dart';
import 'package:epic_dice_events/main.dart' as app;
import 'package:path_provider/path_provider.dart';





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
  Future<void> verifyTextPresenceInPage(WidgetTester tester, String text, String className, String testDescription) async{
    await tester.pumpAndSettle();
    try{
      expect(find.text(text), findsOneWidget);
      addResult(className, testDescription, true);
    }catch(e){
      addResult(className, testDescription, false, error: e.toString() );
    }
  }

  Future<void> verifyButtonPresenceInPage(WidgetTester tester, String text, String className, String testDescription) async{
    await tester.pumpAndSettle();
    try{
      expect(find.widgetWithText(ElevatedButton,text), findsOneWidget);
      addResult(className, testDescription, true);
    }catch(e){
      addResult(className, testDescription, false, error: e.toString() );
    }
  }

  group('Authenticate Page Tests', () {

    setUp(() {
      //print("Inceperea aplicației...");
      app.main();
      Future.delayed(Duration(seconds: 5));
    });

    testWidgets('Verify title of the page', (tester) async {
      //  Precondition
      await tester.pumpAndSettle(Duration(seconds: 10)); // Așteaptă finalizarea animațiilor
      //Procedure
      await Future.delayed(Duration(seconds: 10));
      try{
        expect(find.text("EpicDiceEvents"), findsOneWidget);
        addResult("Authenticate", "Verify App title on Welcome Page", true);
      }catch(e){
        addResult("Authenticate", "Verify App title on Welcome Page", false, error: e.toString());
      }
      // Post-condition
    });

    testWidgets('Verify presence of Log In button', (tester) async {
      //Precondition
      await tester.pumpAndSettle();
      //Procedure
      try{
        expect(find.text("Log In"), findsOneWidget);
        addResult("Authenticate", "Verify if Log In Button present on Welcome Page", true);
      }catch(e){
        addResult("Authenticate", "Verify if Log In Button present on Welcome Page", false, error: e.toString());
      }
      //Post Condition
    });

    testWidgets('Verify presence of Sign Up button', (tester) async {
      //Precondition
      await tester.pumpAndSettle();
      //Procedure
      try{
        expect(find.text("Sign Up"), findsOneWidget);
        addResult("Authenticate", "Verify if Log Up Button present on Welcome Page", true);
      }catch(e){
        addResult("Authenticate", "Verify if Log Up Button present on Welcome Page", false, error: e.toString());
       }
       //Post Condition
    });

    testWidgets('Simulate Log In button press', (tester) async {
      //Precondition
      await tester.pumpAndSettle(); // Așteaptă finalizarea animațiilor
      //Procedure
      try {
        await tester.tap(find.text('Log In'));
        await tester.pumpAndSettle(); // Așteaptă finalizarea navigării
        //await tester.pumpAndSettle(Duration(seconds: 5));
        expect(find.byType(LogInPage), findsOneWidget);
        addResult('Authenticate', 'Simulate Log In button press', true);
      } catch (e) {
        addResult('Authenticate', 'Simulate Log In button press', false, error: e.toString());
      }
      //Post Condition
      //print(testResults);
    });
  });
  tearDownAll(() {
    //generarea raportului aici
    generateReport(testResults);
  });

}

Future<void> generateReport(List<Map<String, dynamic>> results) async {
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

  final directory = await getExternalStorageDirectory();
  final path = '${directory!.path}/test_report.html';
  final file = File(path);

  try {
    await file.writeAsString(htmlBuffer.toString());
    print("Raport salvat la: $path");
  } catch (e) {
    print("Eroare la salvarea raportului: $e");
  }
}