/// Maps a Firestore error code to user-facing text. Raw SDK messages are
/// developer-oriented and must never reach the UI.
String mapFirestoreError(String code, {required String fallback}) {
  return switch (code) {
    'unavailable' || 'deadline-exceeded' =>
      "Can't reach the server. Check your connection and try again.",
    'permission-denied' ||
    'unauthenticated' => 'Your session has expired. Please sign in again.',
    'resource-exhausted' => 'Too many requests. Please try again shortly.',
    _ => fallback,
  };
}
