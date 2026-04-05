import 'package:flutter/material.dart';

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool isSameMinute(DateTime a, DateTime b) {
  return a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute;
}

String formatDate(DateTime date) {
  final now = DateTime.now();
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Today';
  } else if (date.year == now.year &&
      date.month == now.month &&
      date.day == now.day - 1) {
    return 'Yesterday';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}

String formatRelativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 60) return 'a few seconds ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min';
  if (diff.inHours < 24) return '${diff.inHours} hr';
  return '${diff.inDays} days';
}

String fmtDate(DateTime? d) {
  if (d == null) return '';
  const months = [
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
    'Dec'
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

String fmtTime(DateTime d) {
  int h = d.hour;
  final m = d.minute.toString().padLeft(2, '0');
  final am = h < 12;
  if (h == 0) h = 12;
  if (h > 12) h -= 12;
  return '$h:$m ${am ? 'am' : 'pm'}';
}

String formatDateRange(DateTimeRange range) {
  final start = range.start;
  final end = range.end;

  // If same day, show single date
  if (isSameDay(start, end)) {
    return formatDate(start);
  }

  // If same month, show "1-15 Jan 2024"
  if (start.year == end.year && start.month == end.month) {
    const months = [
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
      'Dec'
    ];
    return '${start.day}-${end.day} ${months[start.month - 1]} ${start.year}';
  }

  // If same year, show "1 Jan - 15 Feb 2024"
  if (start.year == end.year) {
    const months = [
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
      'Dec'
    ];
    return '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${start.year}';
  }

  // Different years, show full dates
  return '${formatDate(start)} - ${formatDate(end)}';
}

String getMonthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return months[month - 1];
}

/// Parses DOB from ISO or `d/m/y` (same as account date picker / metadata).
DateTime? tryParseDobString(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final iso = DateTime.tryParse(s);
  if (iso != null) return DateTime(iso.year, iso.month, iso.day);
  final parts = s.split(RegExp(r'[/.\-]'));
  if (parts.length == 3) {
    final d = int.tryParse(parts[0].trim());
    final m = int.tryParse(parts[1].trim());
    final y = int.tryParse(parts[2].trim());
    if (d != null && m != null && y != null && y > 31) {
      return DateTime(y, m, d);
    }
  }
  return null;
}

/// Full years lived as of [reference] (defaults to today). Null if [birthDate] is in the future.
int? ageInYears(DateTime birthDate, [DateTime? reference]) {
  final today = reference ?? DateTime.now();
  final birth = DateTime(birthDate.year, birthDate.month, birthDate.day);
  final refDay = DateTime(today.year, today.month, today.day);
  if (birth.isAfter(refDay)) return null;
  var age = refDay.year - birth.year;
  final birthdayThisYear = DateTime(refDay.year, birth.month, birth.day);
  if (refDay.isBefore(birthdayThisYear)) {
    age--;
  }
  return age;
}
