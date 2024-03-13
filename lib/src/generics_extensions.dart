import 'result.dart';

extension Generics<T> on T {
  Ok<T, U> toOk<U>() => Ok(this);
  Err<U, T> toErr<U>() => Err(this);
}
