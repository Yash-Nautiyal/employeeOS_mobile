import 'package:url_launcher/url_launcher.dart';

String _formatGoogleCalendarDatesUtc(DateTime start, DateTime end) {
  String g(DateTime d) {
    final u = d.toUtc();
    final y = u.year.toString().padLeft(4, '0');
    final m = u.month.toString().padLeft(2, '0');
    final day = u.day.toString().padLeft(2, '0');
    final h = u.hour.toString().padLeft(2, '0');
    final min = u.minute.toString().padLeft(2, '0');
    final s = u.second.toString().padLeft(2, '0');
    return '$y$m${day}T$h$min${s}Z';
  }

  return '${g(start)}/${g(end)}';
}

/// Next full-hour slot in local time, 1 hour long (e.g. 12:34 → 13:00–14:00).
(DateTime start, DateTime end) defaultOneHourInterviewSlot([DateTime? from]) {
  final now = from ?? DateTime.now();
  var start = DateTime(now.year, now.month, now.day, now.hour);
  if (now.minute > 0 || now.second > 0 || now.millisecond > 0) {
    start = start.add(const Duration(hours: 1));
  }
  final end = start.add(const Duration(hours: 1));
  return (start, end);
}

/// Opens Google Calendar’s create-event page with prefilled fields (TEMPLATE URL).
///
/// Uses [LaunchMode.inAppBrowserView] when supported (Chrome Custom Tabs /
/// SFSafariViewController). Falls back to the system browser. Does not touch
/// app state — returning from the browser does not trigger a reload by itself.
Future<bool> openGoogleCalendarTemplateEvent({
  required String title,
  required DateTime startLocal,
  required DateTime endLocal,
  String details = '',
  String location = '',
  List<String> guests = const [],
}) async {
  final cleanGuests =
      guests.map((g) => g.trim()).where((g) => g.isNotEmpty).toSet().toList();
  final uri = Uri.https(
    'calendar.google.com',
    '/calendar/render',
    {
      'action': 'TEMPLATE',
      'text': title,
      'dates': _formatGoogleCalendarDatesUtc(startLocal, endLocal),
      if (details.isNotEmpty) 'details': details,
      if (location.isNotEmpty) 'location': location,
      if (cleanGuests.isNotEmpty) 'add': cleanGuests.join(','),
    },
  );

  final inAppOk = await supportsLaunchMode(LaunchMode.inAppBrowserView);
  final mode =
      inAppOk ? LaunchMode.inAppBrowserView : LaunchMode.externalApplication;

  return launchUrl(
    uri,
    mode: mode,
    browserConfiguration: const BrowserConfiguration(showTitle: true),
  );
}
