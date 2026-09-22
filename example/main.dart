import 'package:either_result/either_result.dart';

/// App-defined failure type — the package has no opinion on your error
/// hierarchy, so any type works as `F`.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

final class User {
  const User(this.id, this.name);

  final int id;
  final String name;
}

const _users = {1: User(1, 'Ada'), 2: User(2, 'Linus')};

Result<Failure, int> parseId(String input) {
  final id = int.tryParse(input);
  if (id == null) {
    return ResultFailure(ValidationFailure('Invalid id: $input'));
  }
  return ResultSuccess(id);
}

Result<Failure, User> findUser(int id) {
  final user = _users[id];
  if (user == null) {
    return ResultFailure(NotFoundFailure('No user with id $id'));
  }
  return ResultSuccess(user);
}

void main() {
  for (final input in ['1', 'abc', '42']) {
    // Chain operations: a failure short-circuits the rest of the pipeline.
    final result = parseId(input).flatMap(findUser);

    // Collapse both branches into a single value.
    final message = result.fold(
      (failure) => 'Error: ${failure.message}',
      (user) => 'Found: ${user.name}',
    );
    print(message);
  }

  // Transform the success value, leaving failures untouched.
  final greeting = findUser(2).map((user) => 'Hello, ${user.name}!');
  print(greeting.getOrElse((failure) => 'Hello, stranger!'));

  // Transform the failure value, e.g. into a user-facing string.
  final Result<String, User> uiResult = findUser(
    99,
  ).mapFailure((failure) => 'Something went wrong (${failure.message})');
  print(uiResult.failureOrNull);

  // Exhaustive pattern matching on the sealed type.
  switch (parseId('abc')) {
    case ResultSuccess(:final value):
      print('Parsed $value');
    case ResultFailure(value: ValidationFailure(:final message)):
      print('Validation: $message');
    case ResultFailure(value: NotFoundFailure(:final message)):
      print('Not found: $message');
  }
}
