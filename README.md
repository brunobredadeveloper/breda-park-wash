# Breda Park & Wash

Aplicativo Flutter para gestão de estacionamento e lava-rápido, Android e iOS, da breda_dev. Versão 0.1: operação local de um estabelecimento, sem servidor ou autenticação.

## Implementado
- Painel de vagas, lavagens, mensalistas e recebimentos do dia.
- Cadastro de cliente e veículo com placa validada e duplicidade bloqueada.
- Entrada/saída, lotação e diária por cada período de 24h iniciado (mínimo uma diária).
- Tarifa registrada na entrada: alterações futuras não modificam estadias abertas.
- Mensalidade pré-paga de 30 dias; renovação vigente soma 30 dias ao vencimento.
- Lavagem: fila, em lavagem, pronto e entregue. Recebimento na entrega.
- Caixa com forma de pagamento informada manualmente. Não processa pagamentos.
- Persistência SQLite transacional; alteração em memória só após sucesso na gravação.
- Material 3, identidade própria, cinco áreas com navegação, estados de carga/erro e formulários.

## Arquitetura
Domínio Dart independente da UI; Repository para armazenamento; Strategy para cálculo de estadia; ViewModel observável com injeção das dependências e relógio testável; Views focadas na apresentação. MVVM e separação de responsabilidades sem padrões desnecessários.

## Execução
Instale Flutter stable. `flutter pub get`, `flutter analyze`, `flutter test`, `flutter run`.
Android: `flutter build apk --debug`. iOS (macOS/Xcode): `flutter build ios --release --no-codesign` para validar compilação. Instalar/distribuir no iPhone requer conta e assinatura Apple; arquivo sem assinatura não é instalador.

## Limites antes de operação comercial
Não há autenticação, múltiplos funcionários/dispositivos, servidor, backup/restauração, exportação, conciliação, recibo fiscal, auditoria ou integração bancária. Dados pessoais ficam no sandbox local do aparelho, sem criptografia adicional. Desinstalar pode apagar os registros. Não usar como sistema único de um negócio nesta etapa.
Cada cliente cadastrado corresponde a um veículo. Diárias de 24h e planos de 30 dias são regras explícitas desta versão, não mês calendário. Lavagens são independentes de vaga de estacionamento. Após expirar durante uma estadia mensalista, essa estadia continua sem cobrança; definir política comercial antes da produção.

## Evolução comercial planejada
SaaS por estabelecimento: conta do proprietário, papéis proprietário/operador, isolamento entre empresas, sincronização/backup, fechamento de caixa, trilha de auditoria, comprovantes, tabela de preços, relatórios/exportação e portal do cliente. Cobrança B2B por assinatura da plataforma; pagamentos do cliente para o estabelecimento são um fluxo separado.

## Assets e direitos
Sem modelos Renderpeople ou outros assets visuais externos. Ícones Material do Flutter e interface própria. Dependências têm seus próprios termos, mantidos pelos fornecedores. Código do produto não é licenciado para redistribuição por terceiros nesta entrega.
