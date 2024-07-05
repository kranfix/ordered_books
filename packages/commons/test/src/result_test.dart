// ignore_for_file: prefer_const_constructors
import 'package:commons/commons.dart';
import 'package:test/test.dart';

enum MyException implements Exception { someException }

enum OtherException implements Exception { someException }

void main() {
  group('Result', () {
    test('Ok can be unwrapped', () {
      final ok1 = Ok<String, Exception>('hi');
      final ok2 = Result<String, Exception>.ok('hi');
      expect(ok1.unwrap(), 'hi');
      expect(ok2.unwrap(), 'hi');
    });

    test('Err.unwrap must throw E', () {
      const exception = MyException.someException;
      final err1 = Err<String, MyException>(exception);
      final err2 = Result<String, MyException>.err(exception);
      expect(err1.unwrap, throwsA(MyException.someException));
      expect(err2.unwrap, throwsA(MyException.someException));
    });

    test('Ok.unwrapErr must throw a ResultUnwrapException', () {
      final ok = Ok<String, Exception>('hi');
      final matcher = isA<ResultUnwrapException<String, Exception>>();
      expect(ok.unwrapErr, throwsA(matcher));
    });

    test('Err.unwrapErr must return E', () {
      const exception = MyException.someException;
      final err = Err<String, MyException>(exception);
      expect(err.unwrapErr(), MyException.someException);
    });

    test('Ok.map must map the value', () {
      final result = Ok<int, Exception>(1).map((v) => v.toString());
      expect(result, isA<Ok<String, Exception>>());
      expect(result.unwrap(), '1');
    });

    test('Err.map must keep the Exception', () {
      final result = Err<int, MyException>(MyException.someException)
          .map((v) => v.toString());
      expect(result, isA<Err<String, MyException>>());
      expect(result.unwrapErr(), MyException.someException);
    });

    test('Ok.mapErr must keep the value', () {
      final ok = Ok<int, MyException>(1);
      final result = ok.mapErr((_) => OtherException.someException);
      expect(result, isA<Ok<int, OtherException>>());
      expect(result.unwrap(), 1);
    });

    test('Err.mapErr must map E to E2', () {
      final result = Err<int, MyException>(MyException.someException)
          .mapErr((_) => OtherException.someException);
      expect(result, isA<Err<int, OtherException>>());
      expect(result.unwrapErr(), OtherException.someException);
    });

    test('Result.unwrapOrNull', () {
      final ok = Ok<int, MyException>(1);
      expect(ok.unwrapOrNull(), 1);

      final err = Err<int, MyException>(MyException.someException);
      expect(err.unwrapOrNull(), isNull);
    });
  });
}
