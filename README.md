# Breda Park & Wash

**Gestão local de estacionamento e lava-rápido em uma aplicação Flutter.**

Projeto de **Bruno Breda · breda_dev**. Acompanhar veículos, vagas, lavagens, mensalidades e recebimentos no mesmo fluxo de operação.

**Plataforma:** Flutter · Dart · SQLite · Android/iOS  
**Estado:** implementação de portfólio em evolução; esteira aprovada na execução referenciada.

[Fluxos e demonstração](docs/fluxos.md) · [Engenharia](docs/engenharia.md) · [Builds e evidências](docs/evidencias.md) · [Portfólio completo](https://github.com/brunobredadeveloper/breda-park-wash/blob/main/docs/portfolio-breda-dev.md)

## O que você pode avaliar

- Clientes e veículos com validação de placa e bloqueio de duplicidade.
- Entrada/saída com limite de vagas e tarifa capturada na entrada.
- Diárias de 24h iniciadas e planos pré-pagos de 30 dias.
- Lavagens em etapas, caixa manual e persistência SQLite transacional.

## Experiência e navegação

Veja o [mapa das telas e o roteiro de avaliação](docs/fluxos.md). Esta revisão não adiciona capturas sem origem verificável; imagens conceituais não são apresentadas como telas do aplicativo.

## Fluxo principal

1. Cadastre um cliente e veículo com dados fictícios.
2. Registre entrada por diária e tente entrada duplicada.
3. Confirme a saída e registre a forma de pagamento recebido.
4. Crie lavagem e avance até entregar; confira o recebimento no caixa.
5. Registre mensalidade, entre como mensalista e reabra o app para conferir persistência.

## Executar e validar

Flutter 3.47.7 e Dart compatível, conforme a esteira. Android SDK/JDK para Android; macOS/Xcode para iOS.

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
# macOS/Xcode, build iOS sem assinatura:
flutter build ios --release --no-codesign
```

Configuração, Firebase quando aplicável, assinatura e comandos adicionais: [referência técnica](docs/referencia-tecnica.md).

[Abrir a execução verificada no GitHub Actions](https://github.com/brunobredadeveloper/breda-park-wash/actions/runs/38485523598). A conclusão dessa execução é **success**; consulte os artefatos e a revisão de código em [evidências](docs/evidencias.md).

## Limites do produto

Avaliação local de um estabelecimento, sem autenticação, backup, multiusuário ou sincronização. Pix/cartão são apenas formas de pagamento informadas; não processam cobranças. Não usar como sistema único comercial nesta fase. Plano que vence durante estadia não acrescenta cobrança nessa estadia; definir política comercial.

## Para quem revisa o portfólio

Donos de pequenos estabelecimentos e equipes que avaliam regras comerciais e Flutter. As [decisões de engenharia](docs/engenharia.md) conectam responsabilidades, arquivos e testes. O [roteiro funcional](docs/fluxos.md) ajuda a avaliar comportamento, falhas e preservação de dados. Funcionalidade planejada não é apresentada como implementada.

## Próximos passos

- Validar os percursos no dispositivo real e registrar os resultados.
- Revisar acessibilidade, interrupções e falhas de armazenamento/rede aplicáveis.
- Concluir requisitos de distribuição, suporte e segurança antes de uso comercial.

Código, mídias e dependências mantêm seus respectivos termos. Consulte os créditos e os avisos existentes no repositório.
