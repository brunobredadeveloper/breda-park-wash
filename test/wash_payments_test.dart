import 'package:flutter_test/flutter_test.dart';
import 'package:breda_park_wash/domain/models.dart';
import 'package:breda_park_wash/presentation/park_view_model.dart';

import 'operations_test.dart' show MemoryRepository;

void main() {
  late MemoryRepository repo;
  late ParkViewModel vm;
  late String id;
  var now = DateTime(2026, 10, 16, 23, 59);

  setUp(() async {
    now = DateTime(2026, 10, 16, 23, 59);
    repo = MemoryRepository();
    vm = ParkViewModel(repo, clock: () => now);
    await vm.load();
    await vm.addCustomer('Cliente teste', '', 'ABC1D23', 'Carro teste');
    await vm.addWash(vm.state.customers.single.id, 'Completa', 6000);
    id = vm.state.washes.single.id;
  });

  test('Entrega sem recebimento mantém dívida e pode receber depois', () async {
    for (var i = 0; i < 3; i++) {
      expect(await vm.advanceWash(id), isTrue);
    }
    expect(vm.state.washes.single.status, WashStatus.delivered);
    expect(vm.state.receipts, isEmpty);
    expect(vm.outstandingWashCents, 6000);
    now = now.add(const Duration(minutes: 2));
    expect(await vm.receiveWash(id, 'Pix'), isTrue);
    expect(vm.outstandingWashCents, 0);
    expect(vm.receiptsOn(DateTime(2026, 10, 16)), isEmpty);
    expect(vm.receiptsOn(DateTime(2026, 10, 17)), hasLength(1));
    expect(await vm.receiveWash(id, 'Dinheiro'), isFalse);
    expect(vm.state.receipts, hasLength(1));
  });

  test('Pagamento antecipado não duplica na entrega e persiste', () async {
    expect(await vm.receiveWash(id, 'Cartão'), isTrue);
    await vm.advanceWash(id);
    await vm.advanceWash(id);
    expect(await vm.advanceWash(id, 'Pix'), isFalse);
    expect(await vm.advanceWash(id), isTrue);
    final restored = ParkState.fromJson(repo.state.toJson());
    expect(restored.washes.single.paid, isTrue);
    expect(restored.washes.single.status, WashStatus.delivered);
    expect(restored.receipts, hasLength(1));
    expect(restored.receipts.single.method, 'Cartão');
  });

  test('Falha ao salvar pagamento não altera caixa nem pendência', () async {
    repo.fail = true;
    expect(await vm.receiveWash(id, 'Pix'), isFalse);
    expect(vm.state.washes.single.paid, isFalse);
    expect(vm.state.receipts, isEmpty);
    repo.fail = false;
    expect(await vm.receiveWash(id, 'Pix'), isTrue);
    expect(vm.state.receipts, hasLength(1));
  });

  test(
    'Entrega com recebimento falha atomicamente e permite tentar de novo',
    () async {
      await vm.advanceWash(id);
      await vm.advanceWash(id);
      repo.fail = true;
      expect(await vm.advanceWash(id, 'Dinheiro'), isFalse);
      expect(vm.state.washes.single.status, WashStatus.ready);
      expect(vm.state.washes.single.paid, isFalse);
      expect(vm.state.receipts, isEmpty);
      repo.fail = false;
      expect(await vm.advanceWash(id, 'Dinheiro'), isTrue);
      expect(await vm.advanceWash(id, 'Dinheiro'), isFalse);
      expect(vm.state.receipts, hasLength(1));
    },
  );

  test(
    'Forma inválida e toques concorrentes não geram recebimentos extras',
    () async {
      expect(await vm.receiveWash(id, ''), isFalse);
      expect(await vm.receiveWash(id, 'Crédito imaginário'), isFalse);
      expect(vm.state.receipts, isEmpty);
      final results = await Future.wait([
        vm.receiveWash(id, 'Pix'),
        vm.receiveWash(id, 'Pix'),
      ]);
      expect(results.where((ok) => ok), hasLength(1));
      expect(vm.state.receipts, hasLength(1));
    },
  );

  test('Migração preserva entregas antigas e pendências novas', () {
    final legacy = vm.state.washes.single.toJson()..remove('paid');
    expect(Wash.fromJson(legacy).paid, isFalse);
    legacy['status'] = 'delivered';
    expect(Wash.fromJson(legacy).paid, isTrue);
    legacy['paid'] = false;
    expect(Wash.fromJson(legacy).paid, isFalse);
  });
}
