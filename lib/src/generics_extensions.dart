import 'result.dart';

extension Generics<T> on T {
  Ok<T, U> toOk<U>() => Ok(this);
  Except<U, T> toExcept<U>() => Except(this);
}
