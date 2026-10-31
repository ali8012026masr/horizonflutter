class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    return _emailRegExp.hasMatch(email.trim());
  }

  static bool isValidPassword(String? password) {
    return password != null && password.trim().length >= 6;
  }

  static bool isNotEmpty(String? text) {
    return text != null && text.trim().isNotEmpty;
  }

  static bool isValidPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return true; // Phone is optional in most registration endpoints
    }
    final cleaned = phone.trim().replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    return cleaned.length >= 7 && RegExp(r'^[0-9]+$').hasMatch(cleaned);
  }

  // Form field validators (returning String? error message)
  static String? validateRequired(String? value, [String message = 'This field is required']) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!isValidEmail(value)) return 'Please enter a valid email address';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required';
    if (!isValidPassword(value)) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.trim().isEmpty) return 'Please confirm your password';
    if (value != originalPassword) return 'Passwords do not match';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!isValidPhone(value)) return 'Please enter a valid phone number';
    return null;
  }
}
