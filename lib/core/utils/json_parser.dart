abstract final class JsonParser {
  static int toInt(Object? value) => switch (value) {
    int v => v,
    num v => v.toInt(),
    String v => int.parse(v),
    _ => throw FormatException('Invalid int value: $value'),
  };

  static double toDouble(Object? value) => switch (value) {
    num v => v.toDouble(),
    String v => double.parse(v),
    _ => throw FormatException('Invalid double value: $value'),
  };
}
