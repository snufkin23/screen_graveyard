enum WelcomeStatus {
  initial,
  completed;

  static WelcomeStatus fromString(String? value) {
    return WelcomeStatus.values.firstWhere(
      (WelcomeStatus e) => e.name == value,
      orElse: () => WelcomeStatus.initial,
    );
  }

  String toStorageString() => name;
}
