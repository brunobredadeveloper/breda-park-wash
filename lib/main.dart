import 'package:flutter/material.dart';

import 'data/sqlite_repository.dart';
import 'presentation/park_view_model.dart';
import 'presentation/park_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ParkApp(model: ParkViewModel(SqliteParkRepository())));
}
