enum OnboardingStep {
  introduction,
  about,
  permission,
  storage,
  completed;

  static OnboardingStep fromString(String? value) {
    return OnboardingStep.values.firstWhere(
      (OnboardingStep e) => e.name == value,
      orElse: () => OnboardingStep.introduction,
    );
  }

  String toStorageString() => name;
}
