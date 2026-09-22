/// Minimal `Either<F, S>`-style type, used instead of a functional-programming
/// package (e.g. dartz, fpdart) so repositories can return typed
/// success/failure results without throwing.
///
/// `F` is the failure type (left), `S` the success type (right):
///
/// ```dart
/// Result<Failure, User> login() => const ResultSuccess(user);
///
/// result.fold(
///   (failure) => print(failure.message),
///   (user) => print(user.name),
/// );
/// ```
sealed class Result<F, S> {
  const Result();

  /// Whether this is a [ResultSuccess].
  bool get isSuccess => this is ResultSuccess<F, S>;

  /// Whether this is a [ResultFailure].
  bool get isFailure => this is ResultFailure<F, S>;

  /// The success value, or `null` when this is a [ResultFailure].
  ///
  /// A success carrying a nullable `S` also yields `null`, so prefer [fold]
  /// or [isSuccess] when `null` is a valid success value.
  S? get successOrNull => switch (this) {
    ResultSuccess<F, S>(:final value) => value,
    ResultFailure<F, S>() => null,
  };

  /// The failure value, or `null` when this is a [ResultSuccess].
  F? get failureOrNull => switch (this) {
    ResultFailure<F, S>(:final value) => value,
    ResultSuccess<F, S>() => null,
  };

  /// Collapses both branches into a single value of type [T].
  T fold<T>(T Function(F failure) onFailure, T Function(S success) onSuccess) {
    return switch (this) {
      ResultFailure<F, S>(:final value) => onFailure(value),
      ResultSuccess<F, S>(:final value) => onSuccess(value),
    };
  }

  /// Transforms the success value, leaving a failure untouched.
  Result<F, T> map<T>(T Function(S success) transform) {
    return switch (this) {
      ResultSuccess<F, S>(:final value) => ResultSuccess(transform(value)),
      ResultFailure<F, S>(:final value) => ResultFailure(value),
    };
  }

  /// Transforms the failure value, leaving a success untouched.
  Result<T, S> mapFailure<T>(T Function(F failure) transform) {
    return switch (this) {
      ResultFailure<F, S>(:final value) => ResultFailure(transform(value)),
      ResultSuccess<F, S>(:final value) => ResultSuccess(value),
    };
  }

  /// Chains another [Result]-returning operation onto a success.
  Result<F, T> flatMap<T>(Result<F, T> Function(S success) transform) {
    return switch (this) {
      ResultSuccess<F, S>(:final value) => transform(value),
      ResultFailure<F, S>(:final value) => ResultFailure(value),
    };
  }

  /// The success value, or the result of [orElse] applied to the failure.
  S getOrElse(S Function(F failure) orElse) {
    return switch (this) {
      ResultSuccess<F, S>(:final value) => value,
      ResultFailure<F, S>(:final value) => orElse(value),
    };
  }
}

/// A successful [Result], carrying the success [value].
final class ResultSuccess<F, S> extends Result<F, S> {
  /// Wraps [value] as a success.
  const ResultSuccess(this.value);

  /// The success value.
  final S value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultSuccess<F, S> && other.value == value;

  @override
  int get hashCode => Object.hash(ResultSuccess, value);

  @override
  String toString() => 'ResultSuccess($value)';
}

/// A failed [Result], carrying the failure [value].
final class ResultFailure<F, S> extends Result<F, S> {
  /// Wraps [value] as a failure.
  const ResultFailure(this.value);

  /// The failure value.
  final F value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultFailure<F, S> && other.value == value;

  @override
  int get hashCode => Object.hash(ResultFailure, value);

  @override
  String toString() => 'ResultFailure($value)';
}
