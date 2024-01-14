import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final globalKeyProvider =
    Provider((ref) => GlobalKey<ScaffoldMessengerState>());
