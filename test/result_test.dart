import 'package:result_type/result_type.dart';
import 'package:test/test.dart';

void main() {
  const success = ResultSuccess<String, int>(1);
  const failure = ResultFailure<String, int>('boom');

  group('isSuccess/isFailure', () {
    test('reflect the variant', () {
      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(failure.isFailure, isTrue);
      expect(failure.isSuccess, isFalse);
    });
  });

  group('fold', () {
    test('runs onSuccess for a success', () {
      expect(success.fold((f) => 'f:$f', (s) => 's:$s'), 's:1');
    });

    test('runs onFailure for a failure', () {
      expect(failure.fold((f) => 'f:$f', (s) => 's:$s'), 'f:boom');
    });
  });

  group('successOrNull/failureOrNull', () {
    test('expose only the matching branch', () {
      expect(success.successOrNull, 1);
      expect(success.failureOrNull, isNull);
      expect(failure.failureOrNull, 'boom');
      expect(failure.successOrNull, isNull);
    });
  });

  group('map', () {
    test('transforms a success value', () {
      expect(success.map((s) => s + 1), const ResultSuccess<String, int>(2));
    });

    test('keeps a failure untouched', () {
      expect(
        failure.map((s) => s + 1),
        const ResultFailure<String, int>('boom'),
      );
    });

    test('can change the success type', () {
      final Result<String, String> mapped = success.map((s) => 'n$s');
      expect(mapped.successOrNull, 'n1');
    });
  });

  group('mapFailure', () {
    test('transforms a failure value', () {
      expect(
        failure.mapFailure((f) => f.toUpperCase()),
        const ResultFailure<String, int>('BOOM'),
      );
    });

    test('keeps a success untouched', () {
      expect(
        success.mapFailure((f) => f.toUpperCase()),
        const ResultSuccess<String, int>(1),
      );
    });
  });

  group('flatMap', () {
    test('chains onto a success', () {
      expect(
        success.flatMap((s) => ResultSuccess<String, int>(s + 10)),
        const ResultSuccess<String, int>(11),
      );
    });

    test('can turn a success into a failure', () {
      expect(
        success.flatMap((s) => const ResultFailure<String, int>('nope')),
        const ResultFailure<String, int>('nope'),
      );
    });

    test('short-circuits on a failure', () {
      var called = false;
      final result = failure.flatMap((s) {
        called = true;
        return ResultSuccess<String, int>(s);
      });
      expect(called, isFalse);
      expect(result, const ResultFailure<String, int>('boom'));
    });
  });

  group('getOrElse', () {
    test('returns the success value', () {
      expect(success.getOrElse((f) => -1), 1);
    });

    test('falls back using the failure', () {
      expect(failure.getOrElse((f) => f.length), 4);
    });
  });

  group('equality', () {
    test('compares by contained value', () {
      expect(const ResultSuccess<String, int>(1), success);
      expect(const ResultFailure<String, int>('boom'), failure);
      expect(const ResultSuccess<String, int>(2), isNot(success));
    });

    test('a success never equals a failure', () {
      expect(
        const ResultSuccess<String, String>('x'),
        isNot(const ResultFailure<String, String>('x')),
      );
    });
  });
}
