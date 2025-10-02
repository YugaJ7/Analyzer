// name validators
String? nameValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Name is required';
  }
  if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
    return 'Name can only contain letters and spaces';
  }
  return null;
}

// email validators
String? emailValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }

  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Enter a valid email address';
  }
  return null;
}

// password validators
String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }

  final complexRegex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d!@#\$%^&*()_+\-=\[\]{}":\\"|,.<>\/?]{6,}$');
  // RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');
  if (!complexRegex.hasMatch(value)) {
    return 'Password must contain letters and numbers';
  }

  return null;
}