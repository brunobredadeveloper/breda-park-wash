import 'models.dart';

abstract interface class StayPricing {
  int quote(Stay stay, DateTime exit);
}

class RollingDailyPricing implements StayPricing {
  @override
  int quote(Stay stay, DateTime exit) {
    if (exit.isBefore(stay.enteredAt)) {
      throw ArgumentError('Saída anterior à entrada.');
    }
    if (stay.kind == StayKind.monthly) return 0;
    final millis = exit.difference(stay.enteredAt).inMilliseconds;
    final days = (millis / Duration.millisecondsPerDay).ceil();
    return (days < 1 ? 1 : days) * stay.dailyCents;
  }
}

String normalizePlate(String value) =>
    value.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
bool validPlate(String value) =>
    RegExp(r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$').hasMatch(normalizePlate(value));

abstract interface class ParkRepository {
  Future<ParkState> load();
  Future<void> save(ParkState state);
}
