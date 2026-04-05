String getInitials(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  if (words.isEmpty) return '';
  final first = words[0].isNotEmpty ? words[0][0] : '';
  final second = words.length > 1 && words[1].isNotEmpty ? words[1][0] : '';
  return (first + second).toUpperCase();
}
