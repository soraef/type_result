abstract class Result<V, E> {
  const Result();

  factory Result.runTry(
    V Function() onTry,
    E Function(Object e) onCatch,
  ) {
    try {
      return Ok(onTry());
    } catch (e) {
      return Err(onCatch(e));
    }
  }

  static Future<Result<V, E>> asyncRunTry<V, E>(
    Future<V> Function() onTry,
    E Function(Object e) onCatch,
  ) async {
    try {
      return Ok(await onTry());
    } catch (e) {
      return Err(onCatch(e));
    }
  }

  factory Result.ok(V value) {
    return Ok(value);
  }

  factory Result.err(E error) {
    return Err(error);
  }

  /// return true if result is ok
  bool get isOk => this is Ok<V, E>;

  /// return true if result is error
  bool get isErr => this is Err<V, E>;

  /// return value or null if result is ok
  V? get okOrNull => isOk ? (this as Ok<V, E>).value : null;

  /// return err value or null if return is err
  E? get errOrNull => isErr ? (this as Err<V, E>).value : null;

  /// Return value if result is ok
  V get ok {
    if (isOk) {
      return (this as Ok<V, E>).value;
    }

    throw AssertionError("Result is not Ok");
  }

  /// Return err value if result is err
  E get err {
    if (isErr) {
      return (this as Err<V, E>).value;
    }

    throw AssertionError("Result is not Err");
  }

  /// Returns a Result type that converts the value of Ok from type V to type U
  Result<U, E> mapOk<U>(U Function(V ok) transform) {
    return okThen((ok) => Ok(transform(ok)));
  }

  /// Returns a Result type that converts the value of Err from type E to type U
  Result<V, U> mapErr<U>(U Function(E err) transform) {
    return errThen((err) => Result.err(transform(err)));
  }

  /// return new result value
  /// transform value if result is ok
  /// return this if result is err
  Result<U, E> okThen<U>(Result<U, E> Function(V ok) transform) {
    if (isOk) {
      return transform(ok);
    } else {
      return Err(this.err);
    }
  }

  Result<V, U> errThen<U>(Result<V, U> Function(E err) transform) {
    if (isErr) {
      return transform(err);
    } else {
      return Ok(this.ok);
    }
  }

  V okOr(V defaultValue) {
    return isOk ? okOrNull! : defaultValue;
  }

  E errOr(E defaultErr) {
    return isErr ? errOrNull! : defaultErr;
  }

  void when(
    Function(V value) onOk,
    Function(E error) onErr,
  ) {
    map<void>(onOk, onErr);
  }

  U map<U>(
    U Function(V ok) onOk,
    U Function(E err) onErr,
  ) {
    if (isOk) {
      return onOk(ok);
    } else {
      return onErr(err);
    }
  }
}

class Ok<V, E> extends Result<V, E> {
  final V value;
  Ok(this.value) : super();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Ok<V, E> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Ok($value)';
}

class Err<V, E> extends Result<V, E> {
  final E value;
  Err(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Err<V, E> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Err($value)';
}

extension FutureResult<V, E> on Future<Result<V, E>> {
  Future<Result<U, E>> okThen<U>(
      Future<Result<U, E>> Function(V ok) transform) async {
    final result = await this;
    if (result.isOk) {
      return transform(result.ok);
    } else {
      return Err(result.err);
    }
  }

  Future<Result<V, U>> errThen<U>(
    Future<Result<V, U>> Function(E err) transform,
  ) async {
    final result = await this;
    if (result.isErr) {
      return transform(result.err);
    } else {
      return Ok(result.ok);
    }
  }
}
