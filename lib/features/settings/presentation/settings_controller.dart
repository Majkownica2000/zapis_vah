import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_repository.dart';
import '../../../core/providers.dart';

class SettingsState {
  final String unit;
  SettingsState({required this.unit});
}

class SettingsController extends StateNotifier<AsyncValue<SettingsState>> {
  SettingsController(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final SettingsRepository _repo;

  Future<void> _load() async {
    final unit = await _repo.getUnit();
    state = AsyncValue.data(SettingsState(unit: unit));
  }

  Future<void> setUnit(String unit) async {
    await _repo.setUnit(unit);
    state = AsyncValue.data(SettingsState(unit: unit));
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AsyncValue<SettingsState>>((ref) {
  return SettingsController(ref.watch(settingsRepositoryProvider));
});
