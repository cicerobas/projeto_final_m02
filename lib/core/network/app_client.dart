abstract interface class AppClient {
  Future<Map<String, dynamic>> get(String path);

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data});

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, dynamic> fields,
    Map<String, String> files = const {},
  });
}
