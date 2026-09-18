import 'package:flutter_test/flutter_test.dart';

import 'package:pdf_editor/main.dart';

void main() {
  testWidgets('PDF Tool app loads the home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PdfToolApp());

    expect(find.text('PDF Tool'), findsWidgets);
    expect(find.text('Open PDF'), findsOneWidget);
    expect(find.text('Create sample'), findsOneWidget);
  });
}
