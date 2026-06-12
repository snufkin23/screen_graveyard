## What's Changed

**Version:** 1.0.0 | **Build:** 20

### ✨ Features
- feat: update splash screen assets and colors for Android and iOS
- feat: add default case to AppStartupCubit listener for improved state handling
- feat: update AppStartupCubit listener to navigate to WelcomeRoute on initial state
- feat: update AppStartupCubit listener to navigate to WelcomeRoute on default state
- feat: refactor WelcomePage to integrate BlocProvider and BlocListener for state management
- feat: implement welcome flow with state management, UI updates, and localization
- feat: update app icons and splash images, modify launch screen dimensions, and add status management
- feat: Implement onboarding flow with state management and UI updates
- feat: enhance onboarding flow with new views and localization updates
- feat: implement GlobalConfigProvider and GlobalSettings for centralized app configuration management
- feat: add local target to Makefile for intl_utils generation
- feat: integrate Firebase into the project; update .env.example, .gitignore, and configuration files

### 🐛 Bug Fixes
- fix: update image paths for launcher icons and splash screen
- fix: update routing to replace OnboardingWrapperRoute with HomeRoute for authenticated users

### ♻️ Refactors
- refactor: remove unused OnboardingCubit import and streamline onboarding page structure

---
_Generated automatically from commit messages_
