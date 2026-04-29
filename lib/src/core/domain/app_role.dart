enum AppRole { judge, participant }

extension AppRoleX on AppRole {
  String get title {
    switch (this) {
      case AppRole.judge:
        return 'Судья';
      case AppRole.participant:
        return 'Участник';
    }
  }
}
