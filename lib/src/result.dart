sealed class Result<V, E> {
  const Result();

  factory Result.tryRun(
    V Function() onTry,
    E Function(Object e) onCatch,
  ) {
    try {
      return Ok(onTry());
    } catch (e) {
      return Except(onCatch(e));
    }
  }

  static Future<Result<V, E>> tryAsyncRun<V, E>(
    Future<V> Function() onTry,
    E Function(Object e) onCatch,
  ) async {
    try {
      return Ok(await onTry());
    } catch (e) {
      return Except(onCatch(e));
    }
  }

  factory Result.ok(V value) {
    return Ok(value);
  }

  factory Result.except(E error) {
    return Except(error);
  }

  /// return true if result is ok
  bool get isOk => this is Ok<V, E>;

  /// return true if result is except
  bool get isExcept => this is Except<V, E>;

  /// return value or null if result is ok
  V? get okOrNull => isOk ? (this as Ok<V, E>).value : null;

  /// return except value or null if return is except
  E? get exceptOrNull => isExcept ? (this as Except<V, E>).value : null;

  /// Return value if result is ok
  V get ok {
    if (isOk) {
      return (this as Ok<V, E>).value;
    }

    throw AssertionError("Result is not Ok");
  }

  /// Return except value if result is except
  E get except {
    if (isExcept) {
      return (this as Except<V, E>).value;
    }

    throw AssertionError("Result is not Except");
  }

  /// Returns a Result type that converts the value of Ok from type V to type U
  Result<U, E> mapOk<U>(U Function(V ok) transform) {
    return okThen((ok) => Ok(transform(ok)));
  }

  /// Returns a Result type that converts the value of Except from type E to type U
  Result<V, U> mapExcept<U>(U Function(E except) transform) {
    return exceptThen((except) => Result.except(transform(except)));
  }

  /// return new result value
  /// transform value if result is ok
  /// return this if result is except
  Result<U, E> okThen<U>(Result<U, E> Function(V ok) transform) {
    if (isOk) {
      return transform(ok);
    } else {
      return Except(this.except);
    }
  }

  Result<V, U> exceptThen<U>(Result<V, U> Function(E except) transform) {
    if (isExcept) {
      return transform(except);
    } else {
      return Ok(this.ok);
    }
  }

  V okOr(V defaultValue) {
    return isOk ? okOrNull! : defaultValue;
  }

  E exceptOr(E defaultExcept) {
    return isExcept ? exceptOrNull! : defaultExcept;
  }

  void when(
    Function(V value) onOk,
    Function(E except) onExcept,
  ) {
    map<void>(onOk, onExcept);
  }

  U map<U>(
    U Function(V ok) onOk,
    U Function(E except) onExcept,
  ) {
    if (isOk) {
      return onOk(ok);
    } else {
      return onExcept(except);
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

class Except<V, E> extends Result<V, E> {
  final E value;
  Except(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Except<V, E> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Except($value)';
}
