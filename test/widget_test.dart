import 'package:flutter/material.dart';
import 'package:breda_park_wash/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:breda_park_wash/presentation/park_app.dart';
import 'package:breda_park_wash/presentation/park_view_model.dart';

import 'operations_test.dart' show MemoryRepository;

void main() {
  testWidgets('Navegação apresenta pátio, cadastro e caixa vazio', (
    tester,
  ) async {
    await tester.pumpWidget(ParkApp(model: ParkViewModel(MemoryRepository())));
    await tester.pumpAndSettle();
    expect(find.text('Seu negócio, em movimento.'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.local_parking).last);
    await tester.pumpAndSettle();
    expect(find.text('Pátio ao vivo'), findsOneWidget);
    await tester.tap(find.text('Clientes').last);
    await tester.pumpAndSettle();
    expect(find.text('Clientes & mensalistas'), findsOneWidget);
    await tester.tap(find.text('Caixa').last);
    await tester.pumpAndSettle();
    expect(find.text('Caixa com clareza.'), findsOneWidget);
  });
  testWidgets('Cadastro pelo formulário salva sem erro de ciclo de vida', (
    tester,
  ) async {
    final vm = ParkViewModel(MemoryRepository());
    await tester.pumpWidget(ParkApp(model: vm));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clientes').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novo cliente'));
    await tester.pumpAndSettle();
    final inputs = find.byType(TextField);
    await tester.enterText(inputs.at(1), 'Ana');
    await tester.enterText(inputs.at(3), 'ABC1D23');
    await tester.enterText(inputs.at(4), 'HB20');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(vm.state.customers.single.name, 'Ana');
    expect(tester.takeException(), isNull);
  });
  testWidgets('Entrega pendente exige confirmação e recebimento separado', (
    tester,
  ) async {
    final repo = MemoryRepository();
    final vm = ParkViewModel(repo);
    await vm.load();
    await vm.addCustomer('Ana', '', 'ABC1D23', 'HB20');
    await vm.addWash(vm.state.customers.single.id, 'Completa', 6000);
    final id = vm.state.washes.single.id;
    await vm.advanceWash(id);
    await vm.advanceWash(id);
    await tester.pumpWidget(ParkApp(model: vm));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lavagens').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Entregar veículo'));
    await tester.tap(find.text('Entregar veículo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(vm.state.washes.single.status, WashStatus.ready);
    await tester.tap(find.text('Entregar veículo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar entrega'));
    await tester.pumpAndSettle();
    expect(vm.state.washes.single.status, WashStatus.delivered);
    expect(vm.state.receipts, isEmpty);
    await tester.ensureVisible(find.text('Registrar recebimento'));
    await tester.tap(find.text('Registrar recebimento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pix'));
    await tester.pumpAndSettle();
    expect(vm.state.receipts.single.cents, 6000);
    expect(find.text('Pago'), findsOneWidget);
    expect(find.text('Registrar recebimento'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
