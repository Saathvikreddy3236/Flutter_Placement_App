class AppFormatters {
  AppFormatters._();

  static String date(String raw) {
    final DateTime? parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}';
  }
}
