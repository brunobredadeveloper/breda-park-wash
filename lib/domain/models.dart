enum StayKind { daily, monthly }

enum WashStatus { queued, washing, ready, delivered }

class Customer {
  final String id, name, phone, plate, vehicle;
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.plate,
    required this.vehicle,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'plate': plate,
    'vehicle': vehicle,
  };
  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
    id: j['id'],
    name: j['name'],
    phone: j['phone'],
    plate: j['plate'],
    vehicle: j['vehicle'],
  );
}

class Stay {
  final String id, customerId;
  final StayKind kind;
  final DateTime enteredAt;
  final int dailyCents;
  const Stay({
    required this.id,
    required this.customerId,
    required this.kind,
    required this.enteredAt,
    required this.dailyCents,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'kind': kind.name,
    'enteredAt': enteredAt.toIso8601String(),
    'dailyCents': dailyCents,
  };
  factory Stay.fromJson(Map<String, dynamic> j) => Stay(
    id: j['id'],
    customerId: j['customerId'],
    kind: StayKind.values.byName(j['kind']),
    enteredAt: DateTime.parse(j['enteredAt']),
    dailyCents: j['dailyCents'],
  );
}

class Membership {
  final String id, customerId;
  final DateTime expiresAt;
  final int priceCents;
  const Membership({
    required this.id,
    required this.customerId,
    required this.expiresAt,
    required this.priceCents,
  });
  bool activeAt(DateTime time) => time.isBefore(expiresAt);
  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'expiresAt': expiresAt.toIso8601String(),
    'priceCents': priceCents,
  };
  factory Membership.fromJson(Map<String, dynamic> j) => Membership(
    id: j['id'],
    customerId: j['customerId'],
    expiresAt: DateTime.parse(j['expiresAt']),
    priceCents: j['priceCents'],
  );
}

class Wash {
  final String id, customerId, service;
  final int priceCents;
  final WashStatus status;
  const Wash({
    required this.id,
    required this.customerId,
    required this.service,
    required this.priceCents,
    this.status = WashStatus.queued,
  });
  Wash advance() => Wash(
    id: id,
    customerId: customerId,
    service: service,
    priceCents: priceCents,
    status: WashStatus.values[status.index + 1],
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'service': service,
    'priceCents': priceCents,
    'status': status.name,
  };
  factory Wash.fromJson(Map<String, dynamic> j) => Wash(
    id: j['id'],
    customerId: j['customerId'],
    service: j['service'],
    priceCents: j['priceCents'],
    status: WashStatus.values.byName(j['status']),
  );
}

class Receipt {
  final String id, customerId, description, method;
  final DateTime paidAt;
  final int cents;
  const Receipt({
    required this.id,
    required this.customerId,
    required this.description,
    required this.method,
    required this.paidAt,
    required this.cents,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'description': description,
    'method': method,
    'paidAt': paidAt.toIso8601String(),
    'cents': cents,
  };
  factory Receipt.fromJson(Map<String, dynamic> j) => Receipt(
    id: j['id'],
    customerId: j['customerId'],
    description: j['description'],
    method: j['method'],
    paidAt: DateTime.parse(j['paidAt']),
    cents: j['cents'],
  );
}

class ParkState {
  final List<Customer> customers;
  final List<Stay> stays;
  final List<Wash> washes;
  final List<Membership> memberships;
  final List<Receipt> receipts;
  final int capacity, dailyCents;
  const ParkState({
    this.customers = const [],
    this.stays = const [],
    this.washes = const [],
    this.memberships = const [],
    this.receipts = const [],
    this.capacity = 30,
    this.dailyCents = 2500,
  });
  ParkState copy({
    List<Customer>? customers,
    List<Stay>? stays,
    List<Wash>? washes,
    List<Membership>? memberships,
    List<Receipt>? receipts,
    int? capacity,
    int? dailyCents,
  }) => ParkState(
    customers: customers ?? this.customers,
    stays: stays ?? this.stays,
    washes: washes ?? this.washes,
    memberships: memberships ?? this.memberships,
    receipts: receipts ?? this.receipts,
    capacity: capacity ?? this.capacity,
    dailyCents: dailyCents ?? this.dailyCents,
  );
  Customer customer(String id) => customers.firstWhere((c) => c.id == id);
  Map<String, dynamic> toJson() => {
    'customers': customers.map((v) => v.toJson()).toList(),
    'stays': stays.map((v) => v.toJson()).toList(),
    'washes': washes.map((v) => v.toJson()).toList(),
    'memberships': memberships.map((v) => v.toJson()).toList(),
    'receipts': receipts.map((v) => v.toJson()).toList(),
    'capacity': capacity,
    'dailyCents': dailyCents,
  };
  factory ParkState.fromJson(Map<String, dynamic> j) => ParkState(
    customers: (j['customers'] as List)
        .map((v) => Customer.fromJson(v))
        .toList(),
    stays: (j['stays'] as List).map((v) => Stay.fromJson(v)).toList(),
    washes: (j['washes'] as List).map((v) => Wash.fromJson(v)).toList(),
    memberships: (j['memberships'] as List)
        .map((v) => Membership.fromJson(v))
        .toList(),
    receipts: (j['receipts'] as List).map((v) => Receipt.fromJson(v)).toList(),
    capacity: j['capacity'],
    dailyCents: j['dailyCents'],
  );
}
