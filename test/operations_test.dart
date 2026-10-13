import 'package:flutter_test/flutter_test.dart';
import 'package:breda_park_wash/domain/models.dart';
import 'package:breda_park_wash/domain/parking_policy.dart';
import 'package:breda_park_wash/presentation/park_view_model.dart';

class MemoryRepository implements ParkRepository {
  ParkState state = const ParkState();
  bool fail = false;
  @override
  Future<ParkState> load() async => state;
  @override
  Future<void> save(ParkState s) async {
    if (fail) throw StateError('disk');
    state = s;
  }
}

void main() {
  final start = DateTime.utc(2026, 10, 13, 10);
  test('Diárias respeitam limite exato de 24 horas e tarifa contratada', () {
    final p = RollingDailyPricing();
    final stay = Stay(
      id: '1',
      customerId: 'c',
      kind: StayKind.daily,
      enteredAt: start,
      dailyCents: 2500,
    );
    expect(p.quote(stay, start), 2500);
    expect(p.quote(stay, start.add(const Duration(hours: 24))), 2500);
    expect(
      p.quote(stay, start.add(const Duration(hours: 24, milliseconds: 1))),
      5000,
    );
    expect(
      () => p.quote(stay, start.subtract(const Duration(seconds: 1))),
      throwsArgumentError,
    );
  });
  test('Placas antigas e Mercosul são normalizadas e validadas', () {
    expect(validPlate('abc-1234'), isTrue);
    expect(validPlate('ABC1D23'), isTrue);
    expect(validPlate('1234567'), isFalse);
  });
  test('Pátio bloqueia duplicidade, lotação e mensalista sem plano', () async {
    final vm = ParkViewModel(MemoryRepository(), clock: () => start);
    await vm.load();
    await vm.configure(1, 2500);
    await vm.addCustomer('Ana', '', 'ABC1D23', 'HB20');
    final a = vm.state.customers.first.id;
    expect(await vm.enter(a, StayKind.monthly), isFalse);
    expect(await vm.enter(a, StayKind.daily), isTrue);
    expect(await vm.enter(a, StayKind.daily), isFalse);
    await vm.addCustomer('Bia', '', 'DEF1234', 'Civic');
    expect(await vm.enter(vm.state.customers.last.id, StayKind.daily), isFalse);
  });
  test(
    'Saída e recebimento persistem juntos; tarifa nova não muda estadia',
    () async {
      var now = start;
      final repo = MemoryRepository();
      final vm = ParkViewModel(repo, clock: () => now);
      await vm.load();
      await vm.addCustomer('Ana', '', 'ABC1D23', 'HB20');
      await vm.enter(vm.state.customers.first.id, StayKind.daily);
      await vm.configure(30, 9000);
      now = start.add(const Duration(hours: 25));
      final id = vm.state.stays.first.id;
      repo.fail = true;
      expect(await vm.exit(id, 'Pix'), isFalse);
      expect(vm.state.stays, hasLength(1));
      expect(vm.state.receipts, isEmpty);
      repo.fail = false;
      expect(await vm.exit(id, 'Pix'), isTrue);
      expect(vm.state.stays, isEmpty);
      expect(vm.state.receipts.single.cents, 5000);
      expect(await vm.exit(id, 'Pix'), isFalse);
      expect(vm.state.receipts, hasLength(1));
    },
  );
  test(
    'Lavagem só gera recebimento na entrega e não cobra duas vezes',
    () async {
      final vm = ParkViewModel(MemoryRepository(), clock: () => start);
      await vm.load();
      await vm.addCustomer('Ana', '', 'ABC1D23', 'HB20');
      await vm.addWash(vm.state.customers.first.id, 'Completa', 6000);
      final id = vm.state.washes.single.id;
      await vm.advanceWash(id, '');
      await vm.advanceWash(id, '');
      expect(vm.state.receipts, isEmpty);
      await vm.advanceWash(id, 'Dinheiro');
      expect(vm.state.receipts.single.cents, 6000);
      expect(await vm.advanceWash(id, 'Dinheiro'), isFalse);
    },
  );
  test(
    'Renovação antecipa 30 dias a partir do vencimento e mantém plano',
    () async {
      final vm = ParkViewModel(MemoryRepository(), clock: () => start);
      await vm.load();
      await vm.addCustomer('Ana', '', 'ABC1D23', 'HB20');
      final id = vm.state.customers.first.id;
      await vm.renew(id, 35000, 'Pix');
      await vm.renew(id, 35000, 'Pix');
      expect(
        vm.state.memberships.single.expiresAt,
        start.add(const Duration(days: 60)),
      );
      expect(await vm.enter(id, StayKind.monthly), isTrue);
      await vm.exit(vm.state.stays.single.id, 'Mensalista');
      expect(vm.state.receipts, hasLength(2));
    },
  );
  test(
    'Dados sobrevivem à serialização incluindo valores em centavos',
    () async {
      final vm = ParkViewModel(MemoryRepository(), clock: () => start);
      await vm.load();
      await vm.addCustomer('Ana', '', 'ABC1D23', 'HB20');
      await vm.renew(vm.state.customers.first.id, 35000, 'Cartão');
      final restored = ParkState.fromJson(vm.state.toJson());
      expect(restored.customers.single.plate, 'ABC1D23');
      expect(restored.receipts.single.cents, 35000);
      expect(
        restored.memberships.single.expiresAt,
        start.add(const Duration(days: 30)),
      );
    },
  );
}
