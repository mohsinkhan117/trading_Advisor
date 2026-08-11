// Shared slip-number parsing for the admin "Student ID" field.
//
// One entry can be any text the admin types (e.g. "ph2 1205", "ad123", a bare
// name) -- no particular internal structure is required or validated; the
// admin is trusted to enter something sensible. Multiple entries for the same
// student are dash-separated, e.g. "ph2 1205-ad123-ch2 1876" -- each
// dash-separated chunk is stored as its own slipCodes array element.

class SlipEntry {
  final List<String> codes;
  final String number;
  const SlipEntry(this.codes, this.number);
}

class SlipParseResult {
  final List<SlipEntry> entries;
  final bool hasUnparsed;
  const SlipParseResult(this.entries, this.hasUnparsed);
}

class SlipNumberUtils {
  static SlipParseResult parse(String raw) {
    final entries = <SlipEntry>[];
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return SlipParseResult(entries, false);

    final chunks =
        trimmed.split('-').map((s) => s.trim()).where((s) => s.isNotEmpty);
    for (final chunk in chunks) {
      // codes stays empty -- no structure is enforced on the chunk's text.
      entries.add(SlipEntry(const [], chunk));
    }
    return SlipParseResult(entries, false);
  }

  static List<String> extractCodes(String raw) =>
      parse(raw).entries.map((e) => e.number).toList();

  /// Normalize an entry for duplicate comparison -- "ad123" and "ad 123"
  /// must be treated as the same entry.
  static String normalizeEntry(String text) =>
      text.replaceAll(RegExp(r'\s+'), '');

  static final RegExp _pureDigits = RegExp(r'^\d+$');

  /// Extract the bare physical slip number from ONE entry's raw text (spaces
  /// intact, e.g. "ch2 1206"), or null if it doesn't cleanly split into a
  /// trailing all-digit token.
  ///
  /// Splits on whitespace BEFORE stripping anything, so a code's own
  /// trailing digit (the "2" in "ch2", the "1" in "ph1") never gets fused
  /// with the real number -- "ch2 1206" -> ["ch2","1206"] -> "1206". Only
  /// works when the admin puts a space between the code and the number; a
  /// jammed entry like "ch21206" has no reliable split point and returns
  /// null (excluded from this check, same as any other freeform text with
  /// no extractable number).
  static String? extractBareNumber(String entryRawText) {
    final tokens = entryRawText
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return null;
    final last = tokens.last;
    return _pureDigits.hasMatch(last) ? last : null;
  }
}
