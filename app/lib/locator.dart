import 'package:app/state-manager.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.I;

void setupLocator() {
  locator.registerSingleton<StateManager>(StateManager());
}
