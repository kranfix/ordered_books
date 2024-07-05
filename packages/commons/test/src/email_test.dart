// ignore_for_file: prefer_const_constructors
import 'package:commons/commons.dart';
import 'package:test/test.dart';

void main() {
  group('Email', () {
    test('Email parses a string with good format', () {
      const text = 'frank@email.com';

      final email1 = Email.parse(text);
      expect(email1, text);

      final email2 = Email.maybeFrom(text);
      expect(email2, isNotNull);
      expect(email2, text);

      final result = Email.tryFrom(text);
      expect(result, isA<Result<Email, EmailError>>());
      expect(result.unwrap(), text);
    });

    test('String can be converted to Email if it is well formatte', () {
      const text = 'frank@email.com';
      expect(text.isValidEmail(), isTrue);

      final email1 = text.maybeIntoEmail();
      expect(email1, isNotNull);
      expect(email1, text);

      final result = Email.tryFrom(text);
      expect(result, isA<Ok<Email, EmailError>>());
      expect(result.unwrap(), text);
    });

    test('Email can not be created with a bad formatted text', () {
      const text = 'bademail.com';

      expect(() => Email.parse(text), throwsA(EmailError.invalidFormat));

      final email2 = Email.maybeFrom(text);
      expect(email2, isNull);

      final result = Email.tryFrom(text);
      expect(result, isA<Err<Email, EmailError>>());
      expect(result.unwrapErr(), EmailError.invalidFormat);
    });

    test('String can not be converted to Email if it is bad formatted', () {
      const text = 'bademail.com';
      expect(text.isValidEmail(), isFalse);

      final email2 = text.maybeIntoEmail();
      expect(email2, isNull);

      final result = text.tryIntoEmail();
      expect(result, isA<Err<Email, EmailError>>());
      expect(result.unwrapErr(), EmailError.invalidFormat);
    });
  });
}
