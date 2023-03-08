class TextUtil {
  static List<String?> SplitEveryNth(String text, int splitSize) {
    RegExp exp = RegExp(r"\d{$splitSize}");

    Iterable<Match> matches = exp.allMatches(text);
    return matches.map((m) => m.group(0)).toList();
  }
}
