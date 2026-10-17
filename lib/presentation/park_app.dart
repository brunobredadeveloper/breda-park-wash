import 'package:flutter/material.dart';

import '../domain/models.dart';
import 'park_view_model.dart';

const teal = Color(0xFF007D79),
    ink = Color(0xFF102D35),
    cream = Color(0xFFF4F6F4);
String money(int cents) =>
    'R\$ ${(cents / 100).toStringAsFixed(2).replaceAll('.', ',')}';
String date(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
int? parseMoney(String value) {
  final n = double.tryParse(value.trim().replaceAll(',', '.'));
  return n != null && n.isFinite ? (n * 100).round() : null;
}

class ParkApp extends StatelessWidget {
  final ParkViewModel model;
  const ParkApp({super.key, required this.model});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Breda Park & Wash',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: teal),
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: ink,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          backgroundColor: teal,
        ),
      ),
    ),
    home: ParkHome(model: model),
  );
}

class ParkHome extends StatefulWidget {
  final ParkViewModel model;
  const ParkHome({super.key, required this.model});
  @override
  State<ParkHome> createState() => _ParkHomeState();
}

class _ParkHomeState extends State<ParkHome> {
  int tab = 0;
  String search = '';
  String washSearch = '';
  WashStatus? washFilter;
  bool onlyUnpaid = false;
  bool cashToday = true;
  ParkViewModel get vm => widget.model;
  @override
  void initState() {
    super.initState();
    vm.load();
  }

  Future<void> perform(Future<bool> Function() action) async {
    final ok = await action();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Operação salva.' : vm.error ?? 'Operação indisponível.',
        ),
        backgroundColor: ok ? teal : Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: vm,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ['Visão geral', 'Pátio', 'Lava-rápido', 'Clientes', 'Caixa'][tab],
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const Text(
              'breda_dev / PARK & WASH',
              style: TextStyle(fontSize: 11, letterSpacing: 1.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: vm.loaded && !vm.busy ? settings : null,
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Configurar pátio',
          ),
        ],
      ),
      body: !vm.loaded
          ? Center(
              child: vm.busy
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_car_wash_rounded,
                          size: 72,
                          color: teal,
                        ),
                        SizedBox(height: 20),
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Preparando seu pátio…'),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(vm.error ?? 'Falha ao iniciar'),
                        FilledButton(
                          onPressed: vm.load,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
            )
          : Column(
              children: [
                if (vm.busy) const LinearProgressIndicator(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: SingleChildScrollView(
                      key: ValueKey(tab),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      child: [
                        dashboard(),
                        yard(),
                        washes(),
                        customers(),
                        cash(),
                      ][tab],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: vm.loaded
          ? FloatingActionButton.extended(
              onPressed: vm.busy
                  ? null
                  : tab == 1
                  ? entry
                  : tab == 2
                  ? newWash
                  : tab == 3
                  ? newCustomer
                  : () => setState(() => tab = 1),
              icon: Icon(tab == 2 ? Icons.water_drop_outlined : Icons.add),
              label: Text(
                tab == 1
                    ? 'Nova entrada'
                    : tab == 2
                    ? 'Nova lavagem'
                    : tab == 3
                    ? 'Novo cliente'
                    : 'Operar pátio',
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            label: 'Hoje',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_parking),
            label: 'Pátio',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_car_wash_outlined),
            label: 'Lavagens',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Clientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Caixa',
          ),
        ],
      ),
    ),
  );
  Widget card(Widget child) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(padding: const EdgeInsets.all(18), child: child),
  );
  Widget heading(String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(color: Colors.blueGrey)),
      ],
    ),
  );
  Widget empty(String text, IconData icon) => card(
    Column(
      children: [
        Icon(icon, size: 48, color: teal),
        const SizedBox(height: 16),
        Text(text, textAlign: TextAlign.center),
      ],
    ),
  );
  Widget dashboard() {
    final s = vm.state, n = vm.clock();
    final today = vm.receiptsOn(n).fold(0, (v, r) => v + r.cents);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        heading(
          'Seu negócio, em movimento.',
          'Estacionamento e cuidado com o carro no mesmo lugar.',
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [ink, teal]),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VAGAS DISPONÍVEIS',
                style: TextStyle(color: Colors.white70, letterSpacing: 2),
              ),
              Text(
                '${s.capacity - s.stays.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${s.stays.length} ocupadas de ${s.capacity}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: s.stays.length / s.capacity,
                  minHeight: 8,
                  color: const Color(0xFFB5EF79),
                  backgroundColor: Colors.white24,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: metric(
                'Recebido hoje',
                money(today),
                Icons.payments_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: metric(
                'Na lavagem',
                '${s.washes.where((w) => w.status != WashStatus.delivered).length}',
                Icons.water_drop_outlined,
              ),
            ),
          ],
        ),
        card(
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.verified_user_outlined, color: teal),
            title: const Text('Mensalistas ativos'),
            subtitle: const Text('Planos com validade de 30 dias'),
            trailing: Text(
              '${s.memberships.where((m) => m.activeAt(n)).length}',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const Text(
          'Operação local · dados neste aparelho',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blueGrey, fontSize: 12),
        ),
      ],
    );
  }

  Widget metric(String label, String value, IconData icon) => card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: teal),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
        ),
        Text(label),
      ],
    ),
  );
  Widget yard() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      heading(
        'Pátio ao vivo',
        'Diárias de 24 horas iniciadas · ${money(vm.state.dailyCents)}',
      ),
      if (vm.state.stays.isEmpty)
        empty(
          'Nenhum carro no pátio. Cadastre um cliente e registre a entrada.',
          Icons.local_parking,
        ),
      ...vm.state.stays.map((s) {
        final c = vm.state.customer(s.customerId);
        return card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.plate,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              Text('${c.vehicle} · ${c.name}'),
              const SizedBox(height: 8),
              Text(
                'Entrada ${date(s.enteredAt)} · ${s.enteredAt.hour.toString().padLeft(2, '0')}:${s.enteredAt.minute.toString().padLeft(2, '0')}',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(
                      s.kind == StayKind.monthly ? 'Mensalista' : 'Diária',
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: vm.busy ? null : () => checkout(s),
                    child: const Text('Saída'),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    ],
  );
  Widget washes() {
    const labels = ['Na fila', 'Em lavagem', 'Pronto', 'Entregue'];
    final visible = vm.state.washes.where((w) {
      final c = vm.state.customer(w.customerId);
      return (washFilter == null || w.status == washFilter) &&
          (!onlyUnpaid || !w.paid) &&
          '${c.plate} ${c.name} ${w.service}'.toLowerCase().contains(
            washSearch,
          );
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        heading(
          'Cada carro, bem cuidado.',
          'Serviço e pagamento acompanhados separadamente.',
        ),
        TextField(
          onChanged: (v) => setState(() => washSearch = v.trim().toLowerCase()),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Buscar placa, cliente ou serviço',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ChoiceChip(
              label: Text('Todas (${vm.state.washes.length})'),
              selected: washFilter == null,
              onSelected: (_) => setState(() => washFilter = null),
            ),
            ...WashStatus.values.map(
              (status) => ChoiceChip(
                label: Text(
                  '${labels[status.index]} (${vm.state.washes.where((w) => w.status == status).length})',
                ),
                selected: washFilter == status,
                onSelected: (_) => setState(() => washFilter = status),
              ),
            ),
            FilterChip(
              label: const Text('Pagamento pendente'),
              selected: onlyUnpaid,
              onSelected: (value) => setState(() => onlyUnpaid = value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (visible.isEmpty)
          empty(
            vm.state.washes.isEmpty
                ? 'Crie uma ordem de lavagem para começar.'
                : 'Nenhuma lavagem para estes filtros.',
            Icons.local_car_wash,
          ),
        // Ordem de criação: os primeiros carros da fila aparecem primeiro.
        ...visible.map((w) {
          final c = vm.state.customer(w.customerId);
          return card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  c.plate,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text('${c.name} · ${c.vehicle}'),
                Text('${w.service} · ${money(w.priceCents)}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text(labels[w.status.index])),
                    Chip(
                      avatar: Icon(
                        w.paid ? Icons.check_circle_outline : Icons.schedule,
                        size: 18,
                      ),
                      label: Text(w.paid ? 'Pago' : 'A receber'),
                    ),
                  ],
                ),
                if (w.status != WashStatus.delivered)
                  FilledButton(
                    onPressed: vm.busy ? null : () => advanceService(w),
                    child: Text(
                      w.status == WashStatus.queued
                          ? 'Iniciar lavagem'
                          : w.status == WashStatus.washing
                          ? 'Marcar como pronto'
                          : 'Entregar veículo',
                    ),
                  ),
                if (!w.paid)
                  OutlinedButton.icon(
                    onPressed: vm.busy ? null : () => receiveWash(w),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Registrar recebimento'),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> receiveWash(Wash wash) async {
    final method = await payment('Registrar recebimento', wash.priceCents);
    if (method != null) await perform(() => vm.receiveWash(wash.id, method));
  }

  Future<void> advanceService(Wash wash) async {
    if (wash.status == WashStatus.ready && !wash.paid) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Entregar com pagamento pendente?'),
          content: Text(
            '${money(wash.priceCents)} continuará a receber. A entrega não registra dinheiro no caixa.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmar entrega'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await perform(() => vm.advanceWash(wash.id));
  }

  Widget customers() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      heading(
        'Clientes & mensalistas',
        'Cadastro por veículo. Busque pelo nome ou pela placa.',
      ),
      TextField(
        onChanged: (v) => setState(() => search = v.toLowerCase()),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Nome ou placa',
        ),
      ),
      const SizedBox(height: 16),
      if (vm.state.customers.isEmpty)
        empty('Seu primeiro cliente começa aqui.', Icons.people_outline),
      ...vm.state.customers
          .where((c) => '${c.name} ${c.plate}'.toLowerCase().contains(search))
          .map((c) {
            final m = vm.state.memberships
                .where((m) => m.customerId == c.id)
                .firstOrNull;
            return card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text('${c.plate} · ${c.vehicle}'),
                  if (c.phone.isNotEmpty) Text(c.phone),
                  const SizedBox(height: 10),
                  Text(
                    m == null
                        ? 'Sem plano mensal'
                        : 'Plano até ${date(m.expiresAt)}${m.activeAt(vm.clock()) ? '' : ' · vencido'}',
                  ),
                  TextButton.icon(
                    onPressed: vm.busy ? null : () => membership(c),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Registrar pagamento de 30 dias'),
                  ),
                ],
              ),
            );
          }),
    ],
  );
  Widget cash() {
    final receipts = cashToday ? vm.receiptsOn(vm.clock()) : vm.state.receipts;
    final total = receipts.fold(0, (v, r) => v + r.cents);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        heading(
          'Caixa com clareza.',
          'Recebimentos registrados manualmente. Não processa Pix ou cartões.',
        ),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Hoje'),
              selected: cashToday,
              onSelected: (_) => setState(() => cashToday = true),
            ),
            ChoiceChip(
              label: const Text('Todo o histórico'),
              selected: !cashToday,
              onSelected: (_) => setState(() => cashToday = false),
            ),
          ],
        ),
        const SizedBox(height: 12),
        metric(
          cashToday ? 'Recebido hoje' : 'Total registrado',
          money(total),
          Icons.account_balance_wallet_outlined,
        ),
        ...ParkViewModel.paymentMethods.map(
          (method) => card(
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(method),
              trailing: Text(
                money(
                  receipts
                      .where((r) => r.method == method)
                      .fold(0, (v, r) => v + r.cents),
                ),
              ),
            ),
          ),
        ),
        card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lavagens a receber · todos os dias',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${vm.unpaidWashes.length} pendentes · ${money(vm.outstandingWashCents)}',
              ),
              TextButton(
                onPressed: () => setState(() {
                  tab = 2;
                  washFilter = null;
                  washSearch = '';
                  onlyUnpaid = true;
                }),
                child: const Text('Ver pendências'),
              ),
            ],
          ),
        ),
        if (receipts.isEmpty)
          empty(
            'Nenhum recebimento registrado neste período.',
            Icons.receipt_long,
          ),
        ...receipts.reversed.map(
          (r) => card(
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(r.description),
              subtitle: Text(
                '${vm.state.customer(r.customerId).name}\n${date(r.paidAt)} · ${r.method}',
              ),
              trailing: Text(
                money(r.cents),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: teal,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<String>?> fields(
    String title,
    List<String> labels, {
    List<String>? initial,
  }) async {
    final controls = List.generate(
      labels.length,
      (i) => TextEditingController(text: initial?[i] ?? ''),
    );
    final route = DialogRoute<List<String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              labels.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: controls[i],
                  decoration: InputDecoration(labelText: labels[i]),
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, controls.map((c) => c.text).toList()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    final result = await Navigator.of(context).push(route);
    await route.completed;
    for (final c in controls) {
      c.dispose();
    }
    return result;
  }

  Future<void> newCustomer() async {
    final v = await fields('Novo cliente e veículo', [
      'Nome',
      'Telefone (opcional)',
      'Placa',
      'Modelo / cor',
    ]);
    if (v != null) await perform(() => vm.addCustomer(v[0], v[1], v[2], v[3]));
  }

  Future<String?> chooseCustomer() async {
    if (vm.state.customers.isEmpty) {
      await newCustomer();
      if (!mounted || vm.state.customers.isEmpty) return null;
    }
    return showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Selecionar veículo'),
        children: vm.state.customers
            .map(
              (c) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, c.id),
                child: Text('${c.plate} · ${c.name}'),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> entry() async {
    final id = await chooseCustomer();
    if (id == null || !mounted) return;
    final kind = await showDialog<StayKind>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Tipo de permanência'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, StayKind.daily),
            child: Text(
              'Diária · ${money(vm.state.dailyCents)} / 24h iniciadas',
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, StayKind.monthly),
            child: const Text('Mensalista com plano vigente'),
          ),
        ],
      ),
    );
    if (kind != null) await perform(() => vm.enter(id, kind));
  }

  Future<String?> payment(String title, int cents) => showDialog<String>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text('$title\n${money(cents)}'),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('Confirme somente após receber o pagamento.'),
        ),
        ...['Pix', 'Dinheiro', 'Cartão', 'Sem cobrança (mensalista)']
            .where(
              (v) => cents == 0 ? v.startsWith('Sem') : !v.startsWith('Sem'),
            )
            .map(
              (v) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, v),
                child: Text(v),
              ),
            ),
      ],
    ),
  );
  Future<void> checkout(Stay stay) async {
    final cents = vm.pricing.quote(stay, vm.clock());
    final method = await payment('Confirmar saída', cents);
    if (method != null) await perform(() => vm.exit(stay.id, method));
  }

  Future<void> newWash() async {
    final id = await chooseCustomer();
    if (id == null || !mounted) return;
    final v = await fields(
      'Nova lavagem',
      ['Serviço', 'Preço em reais'],
      initial: ['Lavagem completa', '60,00'],
    );
    if (v != null) {
      await perform(() => vm.addWash(id, v[0], parseMoney(v[1]) ?? 0));
    }
  }

  Future<void> membership(Customer c) async {
    final v = await fields(
      'Mensalidade · ${c.plate}',
      ['Preço em reais'],
      initial: ['350,00'],
    );
    if (v == null || !mounted) return;
    final cents = parseMoney(v[0]) ?? 0;
    if (cents <= 0) {
      await perform(() => vm.renew(c.id, 0, ''));
      return;
    }
    final method = await payment('Registrar mensalidade', cents);
    if (method != null) await perform(() => vm.renew(c.id, cents, method));
  }

  Future<void> settings() async {
    final v = await fields(
      'Configurar operação',
      ['Número de vagas', 'Diária em reais'],
      initial: [
        '${vm.state.capacity}',
        (vm.state.dailyCents / 100).toStringAsFixed(2),
      ],
    );
    if (v != null) {
      await perform(
        () => vm.configure(int.tryParse(v[0]) ?? 0, parseMoney(v[1]) ?? 0),
      );
    }
  }
}
