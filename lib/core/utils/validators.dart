class Validators {
  Validators._();

  static final _emailPattern = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  static final _upperCasePattern = RegExp('[A-Z]');
  static final _numberPattern = RegExp(r'\d');
  static final _specialCharPattern = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=/\\\[\]`~;]');
  static final Set<String> _commonPasswords = {
    'password',
    'password1',
    '12345678',
    '123456789',
    'qwerty',
    'qwerty123',
    '11111111',
    'letmein',
    'welcome',
    'admin123',
    'abc12345',
  };

  static String? email(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    if (email.length > 200) {
      return 'Email must be 200 characters or fewer';
    }

    if (!_emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!_upperCasePattern.hasMatch(password)) {
      return 'Password must include an uppercase letter';
    }

    if (!_numberPattern.hasMatch(password)) {
      return 'Password must include a number';
    }

    if (!_specialCharPattern.hasMatch(password)) {
      return 'Password must include a special character';
    }

    if (_commonPasswords.contains(password.toLowerCase())) {
      return 'Password is too common';
    }

    return null;
  }

  static String? fullName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Full name is required';
    }

    if (name.length < 3) {
      return 'Full name must be at least 3 characters';
    }

    if (name.length > 100) {
      return 'Full name must be 100 characters or fewer';
    }

    return null;
  }
}
