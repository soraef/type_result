# type_result

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

`type_result` is a simple yet powerful Flutter package for handling operation results. It introduces a Result type that can represent either a successful outcome (Ok) or a exception (Except). 

This approach aids in dealing with errors in a clean, safe, and predictable manner.

## Installation

Add `type_result` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  type_result: ^1.0.0
```

Then run the `flutter packages get` command in your terminal.

## Usage

### Basics of the Result class

The `Result<V, E>` class is designed to handle operations that may fail. For instance:

```dart
Result<int, String> divide(int dividend, int divisor) {
  if (divisor == 0) {
    return Result.except("Cannot divide by zero");
  } else {
    return Result.ok(dividend / divisor);
  }
}
```

In this context, `V` represents the type of the successful result, and `E` is the type of the error that can be returned.

Here's how you could use the `divide` function:

```dart
var result = divide(10, 2);
if(result.isOk) {
  print('The result is ${result.ok}.'); // The result is 5.
} else {
  print('An exception occurred: ${result.except}.');
}
```

Result type is a sealed class, so you can use `switch` statement to handle it.

```dart
switch (result) {
  case Ok(:final value):
    print('The result is $value.');
  case Except(:final value):
    print('An exception occurred: $value.');
}
```

### Detailed method descriptions

* `isOk`: Returns true if the result is Ok.
* `isExcept`: Returns true if the result is Except.
* `okOrNull`: Returns the value if the result is Ok, or null otherwise.
* `exceptOrNull`: Returns the exception if the result is Except, or null otherwise.

You can use `okOrNull` and `exceptOrNull` to retrieve the value or exception without throwing an exception:

```dart
var result = divide(10, 0);
print(result.okOrNull); // null
print(result.exceptOrNull); // "Cannot divide by zero"
```

If you are certain about the status of a Result, you can directly access the value or exception using `ok` and `except`. If the Result is not of the expected type, these methods will throw an `AssertionError`.

For transforming Result values or exceptions, you can use the `mapOk`, `mapExcept`, `okThen`, `exceptThen` methods. These are handy for chaining transformations and operations.

```dart
Result<int, String> result = divide(10, 2); // Ok(5)
Result<String, String> stringResult = result.mapOk((value) => value.toString()); // Ok("5")
```

Additionally, there are convenience methods such as `okOr` and `exceptOr` for providing a default value if the Result is an exception or a value, respectively.

```dart
Result<int, String> result = divide(10, 0); // Err("Cannot divide by zero")
print(result.okOr(0)); // 0
print(result.exceptOr("No error")); // "Cannot divide by zero"
```

For more advanced control flow, you can use the `when` and `map` functions.

### Future Support

`type_result` also extends the `Future<Result<V, E>>` class to support operations with asynchronous functions. Use `okThen` and `exceptThen` methods with asynchronous functions for chaining operations and transformations in a clean and readable manner.

```dart
Future<Result<int, String>> futureResult = Future.value(Result.ok(10));
futureResult.okThen((value) => Future.value(Result.ok(value * 2))).then((result) {
  if (result.isOk) {
    print(result.ok); // 20
  }
});
```

## Benefits of using Result type

Using the Result type provides a clear indication of the success or failure of a function or operation. It encapsulates the return value in a success case or an error object in a failure case, hence simplifying error handling. 

This means you can avoid the common pitfalls of error handling such as forgetting to handle an error or mistakenly considering an operation successful when it actually failed. This leads to more predictable, safer code, and can greatly increase the maintainability and readability of your codebase.

