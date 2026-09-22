# either_result

Minimal `Either<F, S>`-style `Result` type for repositories/use cases that
need to return typed success/failure values without throwing — without
pulling in a functional-programming package (dartz, fpdart, ...).

## Usage

```dart
import 'package:either_result/either_result.dart';

Future<Result<Failure, UserEntity>> login() async {
  try {
    return ResultSuccess(await api.login());
  } on AuthException catch (error) {
    return ResultFailure(AuthFailure(error.message));
  }
}

final result = await login();

result.fold(
  (failure) => showError(failure.message),
  (user) => goHome(user),
);
```

`F` is the failure type (left), `S` the success type (right). The failure type
is deliberately generic — this package has no opinion on your error
hierarchy; define your own `Failure`/`AppError`/etc. in the consuming app and
use it as `F`.

## Installation

Not published to pub.dev. Depend on it via git:

```yaml
dependencies:
  either_result:
    git:
      url: https://github.com/ronipaschoal/either_result.git
      ref: v0.1.0 # tag, branch or commit
```

## API

| Member | Description |
| --- | --- |
| `isSuccess` / `isFailure` | Which variant this is. |
| `fold(onFailure, onSuccess)` | Collapses both branches into one value. |
| `map(transform)` | Transforms the success value, leaves a failure alone. |
| `mapFailure(transform)` | Transforms the failure value, leaves a success alone. |
| `flatMap(transform)` | Chains another `Result`-returning call onto a success. |
| `getOrElse(orElse)` | The success value, or a fallback built from the failure. |
| `successOrNull` / `failureOrNull` | The matching branch, or `null`. |

`ResultSuccess` and `ResultFailure` compare by their contained value.

## Development

```sh
dart pub get
dart test
dart analyze
```
