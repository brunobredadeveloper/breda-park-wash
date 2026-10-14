# Engenharia — Breda Park & Wash

## Problema técnico

Acompanhar veículos, vagas, lavagens, mensalidades e recebimentos no mesmo fluxo de operação.

## Responsabilidades e código

| Fronteira | Responsabilidade real | Onde inspecionar |
|---|---|---|
| Domínio | Modelos, contratos e regras de tarifa | [parking_policy.dart](../lib/domain/parking_policy.dart) |
| Apresentação | ParkViewModel e injeção de repositório/relógio | [park_view_model.dart](../lib/presentation/park_view_model.dart) |
| Persistência | SQLite com transação | [sqlite_repository.dart](../lib/data/sqlite_repository.dart) |
| Interface | Cinco áreas Material 3 | [park_app.dart](../lib/presentation/park_app.dart) |

## Invariantes e decisões

- Falha de gravação não pode confirmar uma alteração na interface.
- Tarifa alterada não modifica estadias já iniciadas.
- Renovação vigente soma 30 dias ao vencimento; não é mês calendário.

## Como examinar os testes

Os arquivos abaixo fazem parte do código versionado. A existência de uma suíte não comprova sua aprovação; o resultado remoto está em [evidências](evidencias.md).

- [test/operations_test.dart](../test/operations_test.dart)
- [test/widget_test.dart](../test/widget_test.dart)

## Limites e compromissos

Avaliação local de um estabelecimento, sem autenticação, backup, multiusuário ou sincronização. Pix/cartão são apenas formas de pagamento informadas; não processam cobranças. Não usar como sistema único comercial nesta fase. Plano que vence durante estadia não acrescenta cobrança nessa estadia; definir política comercial.

A separação de responsabilidades documentada é a encontrada no código. Não se afirma certificação SOLID, paridade com produtos comerciais, auditoria de segurança ou operação em produção.

## Reproduzir a validação

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
# macOS/Xcode, build iOS sem assinatura:
flutter build ios --release --no-codesign
```

[Voltar ao README](../README.md) · [Fluxos](fluxos.md)
