class MyValidator {
  static String? productNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "required field";
    }
    if (value.length <= 3 || value.length > 120) {
      return "the name is < 4 & > 120";
    }
    return null;
  }

  static String? priceValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "required field";
    }
    if (value.startsWith("0")) {
      return "false field";
    }
  }

  static String? quantityValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "required field";
    }
    if (value.startsWith("0")) {
      return "false field";
    }
  }

  static String? descriptionValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "required field";
    }
    if (value.length < 20 || value.length > 1000) {
      return "the description is < 20 & > 1000";
    }
    return null;
  }
}
