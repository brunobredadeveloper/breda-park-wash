# Fluxos de uso — Breda Park & Wash

Acompanhar veículos, vagas, lavagens, mensalidades e recebimentos no mesmo fluxo de operação.

## Mapa de telas

| Tela / área | O que a pessoa faz | Referência de implementação |
|---|---|---|
| Hoje | Ver vagas, lavagens e valores registrados no dia. | [park_app.dart](../lib/presentation/park_app.dart) |
| Pátio | Registrar entradas e confirmar saídas. | [park_app.dart](../lib/presentation/park_app.dart) |
| Lavagens | Avançar fila, lavagem, pronto e entrega. | [park_app.dart](../lib/presentation/park_app.dart) |
| Clientes | Cadastrar veículo e registrar mensalidade. | [park_app.dart](../lib/presentation/park_app.dart) |
| Caixa e configurações | Consultar recebimentos e ajustar vagas/tarifa. | [park_view_model.dart](../lib/presentation/park_view_model.dart) |

## Demonstração guiada

Use dados fictícios, em ambiente de avaliação.

1. Cadastre um cliente e veículo com dados fictícios.
2. Registre entrada por diária e tente entrada duplicada.
3. Confirme a saída e registre a forma de pagamento recebido.
4. Crie lavagem e avance até entregar; confira o recebimento no caixa.
5. Registre mensalidade, entre como mensalista e reabra o app para conferir persistência.

## Casos que merecem atenção

- Falha de gravação não pode confirmar uma alteração na interface.
- Tarifa alterada não modifica estadias já iniciadas.
- Renovação vigente soma 30 dias ao vencimento; não é mês calendário.

## Escopo e resultado esperado

Avaliação local de um estabelecimento, sem autenticação, backup, multiusuário ou sincronização. Pix/cartão são apenas formas de pagamento informadas; não processam cobranças. Não usar como sistema único comercial nesta fase. Plano que vence durante estadia não acrescenta cobrança nessa estadia; definir política comercial.

## Checklist para validação do proprietário

- [ ] Instalar/abrir a versão correspondente às evidências.
- [ ] Percorrer a jornada principal e uma condição de falha.
- [ ] Confirmar navegação, retorno, teclado e leitura em tela pequena.
- [ ] Fechar/reabrir e verificar os dados que devem persistir.
- [ ] Avaliar os recursos nativos pertinentes no aparelho real.
- [ ] Registrar versão, aparelho, resultado esperado e observado em eventual relato.

[Voltar ao README](../README.md) · [Evidências](evidencias.md)
