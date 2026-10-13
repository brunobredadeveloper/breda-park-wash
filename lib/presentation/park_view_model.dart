import 'package:flutter/foundation.dart';

import '../domain/models.dart';
import '../domain/parking_policy.dart';

class ParkViewModel extends ChangeNotifier {
  final ParkRepository repository;
  final StayPricing pricing;
  final DateTime Function() clock;
  ParkState state = const ParkState();
  bool busy = false, loaded = false;
  String? error;
  int _serial = 0;
  ParkViewModel(
    this.repository, {
    StayPricing? pricing,
    DateTime Function()? clock,
  }) : pricing = pricing ?? RollingDailyPricing(),
       clock = clock ?? DateTime.now;
  String get nextId => '${clock().microsecondsSinceEpoch}-${_serial++}';
  Future<void> load() async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      state = await repository.load();
      loaded = true;
    } catch (_) {
      error = 'Não foi possível abrir os dados. Tente novamente.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> change(ParkState Function() action) async {
    if (busy || !loaded) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      final next = action();
      await repository.save(next);
      state = next;
      return true;
    } on ArgumentError catch (e) {
      error = e.message.toString();
      return false;
    } catch (_) {
      error = 'Falha ao salvar. Nenhuma alteração foi confirmada.';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> addCustomer(
    String name,
    String phone,
    String plate,
    String vehicle,
  ) => change(() {
    final p = normalizePlate(plate);
    if (name.trim().isEmpty || vehicle.trim().isEmpty || !validPlate(p)) {
      throw ArgumentError('Informe nome, veículo e placa brasileira válida.');
    }
    if (state.customers.any((c) => c.plate == p)) {
      throw ArgumentError('Esta placa já está cadastrada.');
    }
    return state.copy(
      customers: [
        ...state.customers,
        Customer(
          id: nextId,
          name: name.trim(),
          phone: phone.trim(),
          plate: p,
          vehicle: vehicle.trim(),
        ),
      ],
    );
  });
  Future<bool> enter(String customerId, StayKind kind) => change(() {
    state.customer(customerId);
    if (state.stays.length >= state.capacity) {
      throw ArgumentError('Estacionamento lotado.');
    }
    if (state.stays.any((s) => s.customerId == customerId)) {
      throw ArgumentError('Veículo já está no pátio.');
    }
    if (kind == StayKind.monthly &&
        !state.memberships.any(
          (m) => m.customerId == customerId && m.activeAt(clock()),
        )) {
      throw ArgumentError('Este cliente não tem mensalidade vigente.');
    }
    return state.copy(
      stays: [
        ...state.stays,
        Stay(
          id: nextId,
          customerId: customerId,
          kind: kind,
          enteredAt: clock(),
          dailyCents: state.dailyCents,
        ),
      ],
    );
  });
  Future<bool> exit(String id, String method) => change(() {
    final stay = state.stays.firstWhere((s) => s.id == id);
    final total = pricing.quote(stay, clock());
    return state.copy(
      stays: state.stays.where((s) => s.id != id).toList(),
      receipts: total == 0
          ? state.receipts
          : [
              ...state.receipts,
              Receipt(
                id: nextId,
                customerId: stay.customerId,
                description: 'Estacionamento · diária',
                method: method,
                paidAt: clock(),
                cents: total,
              ),
            ],
    );
  });
  Future<bool> addWash(String customerId, String service, int cents) =>
      change(() {
        state.customer(customerId);
        if (cents <= 0 || service.trim().isEmpty) {
          throw ArgumentError('Serviço e preço devem ser válidos.');
        }
        return state.copy(
          washes: [
            ...state.washes,
            Wash(
              id: nextId,
              customerId: customerId,
              service: service.trim(),
              priceCents: cents,
            ),
          ],
        );
      });
  Future<bool> advanceWash(String id, String method) => change(() {
    final wash = state.washes.firstWhere((w) => w.id == id);
    if (wash.status == WashStatus.delivered) {
      throw ArgumentError('Lavagem já entregue.');
    }
    final next = wash.advance();
    return state.copy(
      washes: state.washes.map((w) => w.id == id ? next : w).toList(),
      receipts: next.status != WashStatus.delivered
          ? state.receipts
          : [
              ...state.receipts,
              Receipt(
                id: nextId,
                customerId: wash.customerId,
                description: wash.service,
                method: method,
                paidAt: clock(),
                cents: wash.priceCents,
              ),
            ],
    );
  });
  Future<bool> renew(String customerId, int cents, String method) => change(() {
    state.customer(customerId);
    if (cents <= 0) throw ArgumentError('Informe um valor positivo.');
    final current = state.memberships
        .where((m) => m.customerId == customerId)
        .firstOrNull;
    final base = current != null && current.activeAt(clock())
        ? current.expiresAt
        : clock();
    return state.copy(
      memberships: [
        ...state.memberships.where((m) => m.customerId != customerId),
        Membership(
          id: nextId,
          customerId: customerId,
          expiresAt: base.add(const Duration(days: 30)),
          priceCents: cents,
        ),
      ],
      receipts: [
        ...state.receipts,
        Receipt(
          id: nextId,
          customerId: customerId,
          description: 'Mensalidade · 30 dias',
          method: method,
          paidAt: clock(),
          cents: cents,
        ),
      ],
    );
  });
  Future<bool> configure(int capacity, int dailyCents) => change(() {
    if (capacity < state.stays.length || capacity < 1 || dailyCents <= 0) {
      throw ArgumentError('Capacidade ou tarifa inválida.');
    }
    return state.copy(capacity: capacity, dailyCents: dailyCents);
  });
}
