import 'package:flutter/material.dart';
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
}
