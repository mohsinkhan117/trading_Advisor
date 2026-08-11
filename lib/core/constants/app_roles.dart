// lib/core/constants/app_roles.dart

enum AppRole {
  fsc1,
  fsc2,
  mdcat,
  all;

  String get label {
    switch (this) {
      case AppRole.fsc1:
        return 'FSc-1';
      case AppRole.fsc2:
        return 'FSc-2';
      case AppRole.mdcat:
        return 'MDcat';
      case AppRole.all:
        return 'All';
    }
  }

  String get value => name; // stored in Firestore as 'fsc1', 'fsc2', etc.

  static AppRole? fromValue(String value) {
    return AppRole.values.where((r) => r.value == value).firstOrNull;
  }
}
