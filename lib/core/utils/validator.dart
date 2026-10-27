const _maxNameLength = 60;
const _minPasswordLength = 8;

// name validators
String? nameValidator(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) {
    return 'Name is required';
  }
  if (name.length > _maxNameLength) {
    return 'Name must be at most $_maxNameLength characters';
  }
  // Any script's letters, plus the punctuation real names use (O'Brien, Jean-Luc).
  if (!RegExp(r"^[\p{L}\p{M}\s'.-]+$", unicode: true).hasMatch(name)) {
    return 'Name can only contain letters, spaces, apostrophes and hyphens';
  }
  return null;
}

// email validators
String? emailValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }

  // Shape check only; Firebase is the authority. No TLD length cap
  // (.museum, .technology are valid).
  final emailRegex = RegExp(r'^[\w.+-]+@([\w-]+\.)+[A-Za-z]{2,}$');
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Enter a valid email address';
  }
  return null;
}

/// Sign-in: presence only. Rules may have changed since the account was
/// created, so the server decides whether the password is right.
String? loginPasswordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  return null;
}

/// Sign-up strength rule. Any characters are allowed so passphrases work.
String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < _minPasswordLength) {
    return 'Password must be at least $_minPasswordLength characters';
  }
  if (!RegExp(r'[A-Za-z]').hasMatch(value) || !RegExp(r'\d').hasMatch(value)) {
    return 'Password must contain letters and numbers';
  }
  return null;
}

String? confirmPasswordValidator(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  }
  if (value != password) {
    return 'Passwords do not match';
  }
  return null;
}
