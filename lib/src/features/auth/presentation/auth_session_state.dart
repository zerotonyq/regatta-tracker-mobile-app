import '../../../core/domain/app_role.dart';

enum AuthSessionStatus {
  unauthenticated,
  restoring,
  authenticated,
  refreshing,
  expired,
  failure,
}

class AuthSessionState {
  const AuthSessionState({
    required this.status,
    this.selectedRole,
    this.userId,
    this.error,
  });

  const AuthSessionState.unauthenticated({AppRole? selectedRole, String? error})
    : this(
        status: AuthSessionStatus.unauthenticated,
        selectedRole: selectedRole,
        error: error,
      );

  final AuthSessionStatus status;
  final AppRole? selectedRole;
  final int? userId;
  final String? error;

  bool get isAuthenticated =>
      status == AuthSessionStatus.authenticated ||
      status == AuthSessionStatus.refreshing;

  AuthSessionState copyWith({
    AuthSessionStatus? status,
    AppRole? selectedRole,
    int? userId,
    String? error,
    bool clearError = false,
  }) {
    return AuthSessionState(
      status: status ?? this.status,
      selectedRole: selectedRole ?? this.selectedRole,
      userId: userId ?? this.userId,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
