import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_form_field/custom_form_field.dart';

void main() {
  group('CustomTextField Tests', () {
    testWidgets('should display label text', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              labelText: 'Test Label',
              fieldType: FieldType.custom,
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('should show required indicator when required is true', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              labelText: 'Required Field',
              fieldType: FieldType.custom,
              required: true,
            ),
          ),
        ),
      );

      // Check if CustomPaint (required indicator) is present
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should validate email format', (WidgetTester tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CustomTextField(
                controller: controller,
                labelText: 'Email',
                fieldType: FieldType.email,
              ),
            ),
          ),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField), 'invalid-email');

      // Trigger validation
      expect(formKey.currentState!.validate(), false);

      await tester.pump();

      // Check for error message
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('should validate username format', (WidgetTester tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CustomTextField(
                controller: controller,
                labelText: 'Username',
                fieldType: FieldType.username,
              ),
            ),
          ),
        ),
      );

      // Enter invalid username (too short)
      await tester.enterText(find.byType(TextFormField), 'ab');

      // Trigger validation
      expect(formKey.currentState!.validate(), false);

      await tester.pump();

      // Check for error message
      expect(
        find.text(
          'Enter a valid username (min 3 characters, alphanumeric + underscore only)',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should validate password requirements', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CustomTextField(
                controller: controller,
                labelText: 'Password',
                fieldType: FieldType.password,
              ),
            ),
          ),
        ),
      );

      // Enter weak password
      await tester.enterText(find.byType(TextFormField), 'weak');

      // Trigger validation
      expect(formKey.currentState!.validate(), false);

      await tester.pump();

      // Check for error message
      expect(
        find.text('Password must be 6+ characters with 1 uppercase & 1 number'),
        findsOneWidget,
      );
    });

    testWidgets('should toggle password visibility', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              labelText: 'Password',
              fieldType: FieldType.password,
            ),
          ),
        ),
      );

      // Find the visibility toggle button
      final toggleButton = find.byIcon(Icons.visibility_off);
      expect(toggleButton, findsOneWidget);

      // Tap to toggle visibility
      await tester.tap(toggleButton);
      await tester.pump();

      // Should now show visibility icon
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should show required field error', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CustomTextField(
                controller: controller,
                labelText: 'Required Field',
                fieldType: FieldType.custom,
                required: true,
              ),
            ),
          ),
        ),
      );

      // Trigger validation with empty field
      expect(formKey.currentState!.validate(), false);

      await tester.pump();

      // Check for required field error message
      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('should call onChanged callback', (WidgetTester tester) async {
      final controller = TextEditingController();
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              labelText: 'Test Field',
              fieldType: FieldType.custom,
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextFormField), 'test input');

      // Verify callback was called
      expect(changedValue, 'test input');
    });

    testWidgets('should use custom validator', (WidgetTester tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CustomTextField(
                controller: controller,
                labelText: 'Custom Field',
                fieldType: FieldType.custom,
                validator: (value) {
                  if (value == null || value.length < 5) {
                    return 'Must be at least 5 characters';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Enter text that fails custom validation
      await tester.enterText(find.byType(TextFormField), 'abc');

      // Trigger validation
      expect(formKey.currentState!.validate(), false);

      await tester.pump();

      // Check for custom error message
      expect(find.text('Must be at least 5 characters'), findsOneWidget);
    });
  });
}
