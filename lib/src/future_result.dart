import 'dart:async';

import 'result.dart';

extension FutureResult<V, E> on Future<Result<V, E>> {
  Future<Result<U, E>> okThen<U>(
      Future<Result<U, E>> Function(V ok) transform) async {
    final result = await this;
    if (result.isOk) {
      return transform(result.ok);
    } else {
      return Except(result.except);
    }
  }

  Future<Result<V, U>> errThen<U>(
    Future<Result<V, U>> Function(E err) transform,
  ) async {
    final result = await this;
    if (result.isExcept) {
      return transform(result.except);
    } else {
      return Ok(result.ok);
    }
  }

  Future<U> map<U>(
    FutureOr<U> Function(V ok) onOk,
    FutureOr<U> Function(E err) onErr,
  ) async {
    final result = await this;
    if (result.isOk) {
      return onOk(result.ok);
    } else {
      return onErr(result.except);
    }
  }

  Future<void> when(
    FutureOr<void> Function(V value) onOk,
    FutureOr<void> Function(E error) onErr,
  ) async {
    await map<void>(onOk, onErr);
  }

  Future<V> okOr(V defaultValue) async {
    final result = await this;
    return result.isOk ? result.ok : defaultValue;
  }

  Future<E> errOr(E defaultErr) async {
    final result = await this;
    return result.isExcept ? result.except : defaultErr;
  }

  Future<V?> get okOrNull async {
    final result = await this;
    return result.isOk ? result.ok : null;
  }

  Future<E?> get errOrNull async {
    final result = await this;
    return result.isExcept ? result.except : null;
  }

  Future<V> get ok async {
    final result = await this;
    if (result.isOk) {
      return result.ok;
    } else {
      throw AssertionError("Result is Err");
    }
  }

  Future<E> get err async {
    final result = await this;
    if (result.isExcept) {
      return result.except;
    } else {
      throw AssertionError("Result is Ok");
    }
  }
}
