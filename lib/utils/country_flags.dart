// Convert country code to flag emoji
String countryFlag(String code) {
  switch (code.toUpperCase()) {
    case 'AU':
      return '\u{1F1E6}\u{1F1FA}';
    case 'NZ':
      return '\u{1F1F3}\u{1F1FF}';
    case 'FJ':
      return '\u{1F1EB}\u{1F1EF}';
    case 'PG':
      return '\u{1F1F5}\u{1F1EC}';
    default:
      return '\u{1F3F3}';
  }
}
