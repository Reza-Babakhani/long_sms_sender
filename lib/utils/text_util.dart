class TextUtil {
  static List<String> splitEveryNth(String text, int splitSize) {
    List<String> msgs = [];

    for (int i = 0; i < text.length; i += splitSize) {
      int to = i + splitSize > text.length ? text.length : i + splitSize;
      msgs.add(text.substring(i, to));
    }

    return msgs;
  }

  static int countSequence(String text, int sequenceSize) {
    return (text.length / sequenceSize).ceil();
  }

  static bool phoneNumberValidate(String phone) {
    RegExp regex =
        RegExp(r'^((\+?[1-9]{1,3})?([1-9]{1}[0-9]{9}))|(0[0-9]{10})$');
    if (!regex.hasMatch(phone)) {
      return false;
    } else {
      return true;
    }
  }
}
