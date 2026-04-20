import 'package:flutter_riverpod/flutter_riverpod.dart';

// Settings states
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final emailEnabledProvider = StateProvider<bool>((ref) => true);
final locationEnabledProvider = StateProvider<bool>((ref) => false);