# type_result

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

`type_result` is a simple yet powerful Flutter package for handling operation results. It introduces a Result type that can represent either a successful outcome (Ok) or a failure (Err). This approach aids in dealing with errors in a clean, safe, and predictable manner.

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
    return Result.err("Cannot divide by zero");
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
  print('An error occurred: ${result.err}.');
}
```

### Detailed method descriptions

* `isOk`: Returns true if the result is Ok.
* `isErr`: Returns true if the result is Err.
* `okOrNull`: Returns the value if the result is Ok, or null otherwise.
* `errOrNull`: Returns the error if the result is Err, or null otherwise.

You can use `okOrNull` and `errOrNull` to retrieve the value or error without throwing an exception:

```dart
var result = divide(10, 0);
print(result.okOrNull); // null
print(result.errOrNull); // "Cannot divide by zero"
```

If you are certain about the status of a Result, you can directly access the value or error using `ok` and `err`. If the Result is not of the expected type, these methods will throw an `AssertionError`.

For transforming Result values or errors, you can use the `mapOk`, `mapErr`, `okThen`, `errThen` methods. These are handy for chaining transformations and operations.

```dart
Result<int, String> result = divide(10, 2); // Ok(5)
Result<String, String> stringResult = result.mapOk((value) => value.toString()); // Ok("5")
```

Additionally, there are convenience methods such as `okOr` and `errOr` for providing a default value if the Result is an error or a value, respectively.

```dart
Result<int, String> result = divide(10, 0); // Err("Cannot divide by zero")
print(result.okOr(0)); // 0
print(result.errOr("No error")); // "Cannot divide by zero"
```

For more advanced control flow, you can use the `when` and `map` functions.

### Future Support

`type_result` also extends the `Future<Result<V, E>>` class to support operations with asynchronous functions. Use `okThen` and `errThen` methods with asynchronous functions for chaining operations and transformations in a clean and readable manner

.

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

