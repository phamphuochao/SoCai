class Validators {
  const Validators._();

  static String? required(String? value, String message) =>
      value == null || value.trim().isEmpty ? message : null;

  static String? nonNegativeNumber(
    String? value, {
    required String invalidMessage,
    required String negativeMessage,
  }) {
    final number = num.tryParse(value ?? '');
    if (number == null) return invalidMessage;
    if (number < 0) return negativeMessage;
    return null;
  }

  static String? positiveNumber(String? value, String message) {
    final number = num.tryParse(value ?? '');
    if (number == null || number <= 0) return message;
    return null;
  }
}
