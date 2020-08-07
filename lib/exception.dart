class CustomException implements Exception {
  CustomException(this.message, { String addInfo = "" });

  String message;
  String addInfo;

  @override
  String toString() {
    return this.message;
  }
}