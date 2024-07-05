import 'package:commons/src/result.dart';

/// Email is an String that was validated with the email format
extension type Email._(String _value) implements String {
  /// Parse an [String] to validate its format.
  /// Throws an [EmailError] is it does not satisfies the format.
  factory Email.parse(String value) => Email.tryFrom(value).unwrap();

  /// If the input is a valid email, return an [Email], otherwise returns null
  static Email? maybeFrom(String value) =>
      value.isValidEmail() ? Email._(value) : null;

  /// Try to parse a [String] and returns a [Result]<[Email], [EmailError]>
  static Result<Email, EmailError> tryFrom(String value) {
    return value.isValidEmail()
        ? Ok(Email._(value))
        : Err(EmailError.invalidFormat);
  }
}

/// Some [EmailUtils] on [String]
extension EmailUtils on String {
  /// Evaluates an [String] to check if it follows the email format
  bool isValidEmail() {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Converts an [String] to [Email]. If the [String] doesn't
  /// satisfies the email format, it returns `null`.
  Email? maybeIntoEmail() => Email.maybeFrom(this);

  /// Try to parse a [String] and returns a [Result]<[Email], [EmailError]>
  Result<Email, EmailError> tryIntoEmail() => Email.tryFrom(this);
}

/// Error on validation if a [String] is an [Email]
enum EmailError implements Exception {
  /// When the [String] has an invalid format
  invalidFormat;
}
