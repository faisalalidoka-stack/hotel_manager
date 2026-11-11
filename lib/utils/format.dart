String formatUgx(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return 'UGX $buf';
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

// Strips the time part so dates can be compared safely
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

// Format used when saving dates in SQLite: yyyy-MM-dd
String toDbDate(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}


// Number with thousand separators, e.g. 1250 -> 1,250
String formatNumber(int value) => formatUgx(value).replaceFirst('UGX ', '');
