import 'package:flutter_test/flutter_test.dart';

import '../lib/type_result.dart';

void main() {
  test('test Ok', () {
    final result = Result<int, String>.ok(42);

    expect(result.isOk, true);
    expect(result.isExcept, false);

    expect(result.ok, 42);
    expect(() => result.except, throwsAssertionError);

    expect(result.okOrNull, 42);
    expect(result.exceptOrNull, null);

    expect(result.mapOk((ok) => ok.toString()).ok, "42");
    expect(result.mapExcept<int>((err) => 42).exceptOrNull, null);

    expect(result.okThen((ok) => Result.ok(ok.toString())).ok, "42");
    expect(result.exceptThen((err) => Result.ok(100)).okOrNull, 42);

    expect(result.okOr(100), 42);
    expect(result.exceptOr("hello"), "hello");

    result.when(
      (ok) => expect(ok, 42),
      (_) => expect(true, false), // not called
    );

    expect(
      result.map<double>((ok) => ok.toDouble(), (_) => 0.0),
      42.0,
    );
  });

  test('test Err', () {
    final result = Result<int, String>.except("Error");

    expect(result.isOk, false);
    expect(result.isExcept, true);

    expect(() => result.ok, throwsAssertionError);
    expect(result.except, "Error");

    expect(result.okOrNull, null);
    expect(result.exceptOrNull, "Error");

    expect(result.mapOk((ok) => ok.toString()).okOrNull, null);
    expect(result.mapExcept<int>((err) => 42).except, 42);

    expect(result.okThen((ok) => Result.ok(ok.toString())).except, "Error");
    expect(result.exceptThen((err) => Result.ok(100)).okOrNull, 100);

    expect(result.okOr(100), 100);
    expect(result.exceptOr("hello"), "Error");

    result.when(
      (ok) => expect(true, false), // not called
      (err) => expect(err, "Error"),
    );

    expect(
      result.map<double>((ok) => ok.toDouble(), (_) => 0.0),
      0.0,
    );
  });

  test('test runTry', () async {
    final ok = Result.tryRun(
      () => 42,
      (e) => Exception(),
    );

    final err = Result.tryRun(
      () => throw Exception(),
      (e) => "Error",
    );

    expect(ok.ok, 42);
    expect(err.except, "Error");

    Future<int> fetchNumber() async {
      return 42;
    }

    Future<int> fetchError() async {
      throw Exception();
    }

    final futureOk = await Result.tryAsyncRun(() => fetchNumber(), (e) => null);
    expect(futureOk.ok, 42);

    final futureErr =
        await Result.tryAsyncRun(() => fetchError(), (e) => "Error");
    expect(futureErr.except, "Error");
  });

  test("async Usecase", () async {
    Future<Result<int, Exception>> authedUserId() async {
      return Result.ok(2);
    }

    Future<Result<int, Exception>> getUserIdFromName(String name) async {
      if (name == "soraef") {
        return Result.ok(1);
      }
      return Result.except(Exception());
    }

    Future<Result<void, Exception>> sendDm(
      int fromId,
      int toId,
      String message,
    ) async {
      return Result.ok(null);
    }

    Future<Result<void, Exception>> sendHelloUsecase(String userName) {
      return authedUserId().okThen((myUserId) {
        return getUserIdFromName(userName).okThen(
          (searchedUserId) => sendDm(myUserId, searchedUserId, "Hello"),
        );
      });
    }

    Future<Result<void, Exception>> sendHelloUsecase2(
      String userName,
    ) async {
      final myUserId = await authedUserId();
      final toUserId = await getUserIdFromName(userName);

      if (myUserId.isOk && toUserId.isOk) {
        return sendDm(myUserId.ok, toUserId.ok, "Hello");
      }

      return Result.except(Exception());
    }

    expect(await sendHelloUsecase("soraef").then((e) => e.isOk), true);
    expect(await sendHelloUsecase("zoraef").then((e) => e.isExcept), true);

    expect(await sendHelloUsecase2("soraef").then((e) => e.isOk), true);
    expect(await sendHelloUsecase2("zoraef").then((e) => e.isExcept), true);
  });

  test("future_result", () async {
    final value1 =
        await Future.value(Result.ok(42)).map((ok) => ok * 2, (err) => 0);
    expect(value1, 42 * 2);

    final value2 = await Future.value(Result.except("Error"))
        .map((ok) => ok * 2, (err) => 0);
    expect(value2, 0);
  });
}
