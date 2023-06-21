import 'package:flutter_test/flutter_test.dart';

import 'package:type_result/type_result.dart';

void main() {
  test('test Ok', () {
    final result = Result<int, String>.ok(42);

    expect(result.isOk, true);
    expect(result.isErr, false);

    expect(result.ok, 42);
    expect(() => result.err, throwsAssertionError);

    expect(result.okOrNull, 42);
    expect(result.errOrNull, null);

    expect(result.mapOk((ok) => ok.toString()).ok, "42");
    expect(result.mapErr<int>((err) => 42).errOrNull, null);

    expect(result.okThen((ok) => Result.ok(ok.toString())).ok, "42");
    expect(result.errThen((err) => Result.ok(100)).okOrNull, 42);

    expect(result.okOr(100), 42);
    expect(result.errOr("hello"), "hello");

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
    final result = Result<int, String>.err("Error");

    expect(result.isOk, false);
    expect(result.isErr, true);

    expect(() => result.ok, throwsAssertionError);
    expect(result.err, "Error");

    expect(result.okOrNull, null);
    expect(result.errOrNull, "Error");

    expect(result.mapOk((ok) => ok.toString()).okOrNull, null);
    expect(result.mapErr<int>((err) => 42).err, 42);

    expect(result.okThen((ok) => Result.ok(ok.toString())).err, "Error");
    expect(result.errThen((err) => Result.ok(100)).okOrNull, 100);

    expect(result.okOr(100), 100);
    expect(result.errOr("hello"), "Error");

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
    final ok = Result.runTry(
      () => 42,
      (e) => Exception(),
    );

    final err = Result.runTry(
      () => throw Exception(),
      (e) => "Error",
    );

    expect(ok.ok, 42);
    expect(err.err, "Error");

    Future<int> fetchNumber() async {
      return 42;
    }

    Future<int> fetchError() async {
      throw Exception();
    }

    final futureOk = await Result.asyncRunTry(() => fetchNumber(), (e) => null);
    expect(futureOk.ok, 42);

    final futureErr =
        await Result.asyncRunTry(() => fetchError(), (e) => "Error");
    expect(futureErr.err, "Error");
  });

  test("async Usecase", () async {
    Future<Result<int, Exception>> authedUserId() async {
      return Result.ok(2);
    }

    Future<Result<int, Exception>> getUserIdFromName(String name) async {
      if (name == "soraef") {
        return Result.ok(1);
      }
      return Result.err(Exception());
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

      return Result.err(Exception());
    }

    expect(await sendHelloUsecase("soraef").then((e) => e.isOk), true);
    expect(await sendHelloUsecase("zoraef").then((e) => e.isErr), true);

    expect(await sendHelloUsecase2("soraef").then((e) => e.isOk), true);
    expect(await sendHelloUsecase2("zoraef").then((e) => e.isErr), true);
  });
}
