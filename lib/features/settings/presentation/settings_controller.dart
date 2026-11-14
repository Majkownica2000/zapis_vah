import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_repository.dart';
import '../../../core/providers.dart';

class SettingsState {
  final String unit;
  final ThemeMode themeMode;
  SettingsState({required this.unit, required this.themeMode});
}

class SettingsController extends StateNotifier<AsyncValue<SettingsState>> {
  SettingsController(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final SettingsRepository _repo;

  Future<void> _load() async {
    final unit = await _repo.getUnit();
    final themeMode = await _repo.getThemeMode();
    state = AsyncValue.data(SettingsState(unit: unit, themeMode: themeMode));
  }

  Future<void> setUnit(String unit) async {
    await _repo.setUnit(unit);
    final current = state.valueOrNull;
    state = AsyncValue.data(SettingsState(
      unit: unit,
      themeMode: current?.themeMode ?? ThemeMode.system,
    ));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _repo.setThemeMode(mode);
    final current = state.valueOrNull;
    state = AsyncValue.data(SettingsState(
      unit: current?.unit ?? 'kg',
      themeMode: mode,
    ));
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AsyncValue<SettingsState>>((ref) {
  return SettingsController(ref.watch(settingsRepositoryProvider));
});
