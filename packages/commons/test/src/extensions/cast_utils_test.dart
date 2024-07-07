import 'package:commons/commons.dart';
import 'package:test/test.dart';

void main() {
  group('CastUtils extention', () {
    test('validates is can be casted on non-null', () {
      // ignore: unnecessary_nullable_for_final_variable_declarations, prefer_const_declarations
      final Object? obj = 'Hello world';

      expect(obj?.canBeCastedAs<String>(), isTrue);
      expect(obj.canBeCastedAs<String>(), isTrue);
      expect(obj?.canBeCastedAs<int>(), isFalse);
      expect(obj.canBeCastedAs<int>(), isFalse);

      expect(obj?.maybeCastedAs<String>(), isA<String>());
      expect(obj.maybeCastedAs<String>(), isA<String>());
      expect(obj?.maybeCastedAs<int>(), isNull);
      expect(obj.maybeCastedAs<int>(), isNull);
    });

    test('validates is can be casted on null', () {
      // ignore: unnecessary_nullable_for_final_variable_declarations, prefer_const_declarations
      final Object? obj = null;

      expect(obj?.canBeCastedAs<String>(), isNull);
      expect(obj.canBeCastedAs<String>(), isFalse);
      expect(obj?.canBeCastedAs<int>(), isNull);
      expect(obj.canBeCastedAs<int>(), isFalse);

      expect(obj?.maybeCastedAs<String>(), isNull);
      expect(obj.maybeCastedAs<String>(), isNull);
      expect(obj?.maybeCastedAs<int>(), isNull);
      expect(obj.maybeCastedAs<int>(), isNull);
    });
  });

  group('SealedIsA', () {
    test('Result can be validated as Ok or Err', () {
      final Result<String, Exception> ok = Ok('hello word');
      expect(ok.isA<Ok<String, Exception>>(), isTrue);
      expect(ok.isA<Err<String, Exception>>(), isFalse);

      final Result<String, Exception> err = Err(Exception('Cry'));
      expect(err.isA<Ok<String, Exception>>(), isFalse);
      expect(err.isA<Err<String, Exception>>(), isTrue);
    });

    test('Result maybeCastedAs Ok or Err', () {
      final Result<String, Exception> ok = Ok('hello world');
      expect(ok.maybeAs<Ok<String, Exception>>()?.unwrap(), 'hello world');
      expect(ok.maybeAs<Err<String, Exception>>(), isNull);

      final Result<String, Exception> err = Err(Exception('Cry'));
      expect(err.maybeAs<Ok<String, Exception>>(), isNull);
      expect(
        err.maybeAs<Err<String, Exception>>()?.unwrapErr(),
        isA<Exception>(),
      );
    });
  });
}
