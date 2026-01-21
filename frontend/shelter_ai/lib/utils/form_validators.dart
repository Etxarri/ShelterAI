/// Validadores de formulario comunes para reducir duplicación
class FormValidators {
  /// Valida que un campo no esté vacío
  static String? required(String? value, [String message = 'Required']) {
    return (value == null || value.trim().isEmpty) ? message : null;
  }

  /// Valida que un campo no esté vacío (en español)
  static String? requerido(String? value, [String message = 'Requerido']) {
    return (value == null || value.trim().isEmpty) ? message : null;
  }

  /// Valida formato de email
  static String? email(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Required' : null;
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Invalid email';
    }
    return null;
  }

  /// Valida formato de email (en español)
  static String? emailEs(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Requerido' : null;
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email no válido';
    }
    return null;
  }

  /// Valida longitud mínima de password
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.length < minLength) {
      return 'Minimum $minLength characters';
    }
    return null;
  }

  /// Valida longitud mínima de password (en español)
  static String? passwordEs(String? value, {int minLength = 6}) {
    if (value == null || value.length < minLength) {
      return 'Mínimo $minLength caracteres';
    }
    return null;
  }

  /// Valida que dos passwords coincidan
  static String? confirmPassword(String? value, String? originalPassword) {
    return (value == null || value != originalPassword)
        ? 'Passwords do not match'
        : null;
  }

  /// Valida que dos passwords coincidan (en español)
  static String? confirmPasswordEs(String? value, String? originalPassword) {
    return (value == null || value != originalPassword)
        ? 'Las contraseñas no coinciden'
        : null;
  }

  /// Valida número de teléfono básico
  static String? phone(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Required' : null;
    }
    if (value.trim().length < 6) {
      return 'Phone must have at least 6 digits';
    }
    return null;
  }

  /// Valida número de teléfono básico (en español)
  static String? phoneEs(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Requerido' : null;
    }
    if (value.trim().length < 6) {
      return 'Teléfono debe tener al menos 6 dígitos';
    }
    return null;
  }

  /// Valida edad
  static String? age(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Required' : null;
    }
    final age = int.tryParse(value.trim());
    if (age == null || age < 0 || age > 150) {
      return 'Invalid age';
    }
    return null;
  }

  /// Valida edad (en español)
  static String? ageEs(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Requerido' : null;
    }
    final age = int.tryParse(value.trim());
    if (age == null || age < 0 || age > 150) {
      return 'Edad no válida';
    }
    return null;
  }
}
