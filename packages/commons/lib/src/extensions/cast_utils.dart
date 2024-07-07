/// Exposes methods for casting types
extension CastUtils<T> on T {
  /// Validates if a variable [T] can be casted as [R]
  bool canBeCastedAs<R>() => this is R;

  /// Validates if a variable [T] can be casted as [R]
  /// And return null or the variables casted
  R? maybeCastedAs<R>() => this is R ? this as R : null;
}

/// Is thought to be used with sealed classes
/// but not limited to it
mixin Castable<T> {
  /// Validates if a variable [T] can be casted as [R]
  bool isA<R extends T>() => canBeCastedAs<R>();

  /// Validates if a variable [T] can be casted as [R]
  /// And return null or the variables casted
  R? maybeAs<R extends T>() => maybeCastedAs<R>();
}
