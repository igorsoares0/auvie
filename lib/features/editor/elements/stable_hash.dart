/// FNV-1a: a hash that stays the same across runs and Dart versions, used
/// to seed brush and overlay textures so they never change once drawn.
int stableHash(String value) {
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}
