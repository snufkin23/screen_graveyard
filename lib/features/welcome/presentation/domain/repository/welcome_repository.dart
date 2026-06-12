abstract interface class WelcomeRepository {
  Future<bool> isWelcome();
  Future<void> setWelcome();
}
