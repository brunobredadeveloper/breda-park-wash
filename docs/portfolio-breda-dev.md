# Portfólio breda_dev — Bruno Breda

Projetos mobile e integração, com foco em comportamento verificável, experiência e decisões técnicas. Esta coleção reúne nove aplicativos de demonstração/avaliação (incluindo o sample do SDK) e um backend. Não se apresenta laboratório financeiro como adquirência real nem build de simulador como instalação em iPhone.

## Projetos

| Projeto | Plataforma | Demonstração principal |
|---|---|---|
| [Breda Wallet](https://github.com/brunobredadeveloper/breda-wallet) | Android nativo · Kotlin · Jetpack Compose | Carteira digital de demonstração com consistência de saldo e transferências idempotentes. |
| [Kotlin Payment SDK · Integration Lab](https://github.com/brunobredadeveloper/kotlin-payment-sdk) | Kotlin/JVM + sample Android · Compose | SDK Kotlin independente de Android, acompanhado de um laboratório visual de integração. |
| [Field Orders](https://github.com/brunobredadeveloper/offline-first-orders) | Android nativo · Kotlin · Room · WorkManager | Pedidos que continuam disponíveis sem rede, com fila persistente e resolução explícita de conflitos. |
| [Breda Tap Terminal](https://github.com/brunobredadeveloper/tap-on-phone-demo) | Android nativo · Kotlin · Compose · Firebase opcional | Laboratório de checkout, diagnóstico NFC e conciliação de respostas incertas. |
| [Merchant Payments Console](https://github.com/brunobredadeveloper/merchant-payments-console) | Python 3.11+ · HTTP · SQLite · painel HTML | Backend e painel web para estudar pagamentos idempotentes, estornos e conciliação. |
| [Jardim das Descobertas](https://github.com/brunobredadeveloper/jardim-das-descobertas) | Android nativo · Kotlin · Jetpack Compose | Brincadeiras offline de letras, animais, cores e formas para explorar com um responsável. |
| [Ateliê Breda](https://github.com/brunobredadeveloper/atelie-breda) | React Native · Expo SDK 57 · TypeScript · Android/iOS | Desenho e pintura infantil com galeria local, ferramentas criativas e área de responsáveis. |
| [Breda Fit](https://github.com/brunobredadeveloper/breda-fit) | Android · Compose · núcleo Kotlin Multiplatform | Exercícios em casa e acompanhamento corporal com núcleo Kotlin Multiplatform e interface Android. |
| [Breda Beats Studio](https://github.com/brunobredadeveloper/breda-beats) | Android nativo · Kotlin · Compose · AudioTrack/AudioRecord | Sampler Android com 16 pads fixos, sequências, arranjo, mixer e exportação de áudio. |
| [Breda Park & Wash](https://github.com/brunobredadeveloper/breda-park-wash) | Flutter · Dart · SQLite · Android/iOS | Gestão local de estacionamento e lava-rápido em uma aplicação Flutter. |

## Percurso sugerido para recrutadores

1. **Kotlin Payment SDK + Tap Terminal + Merchant Console:** contrato, timeout, idempotência e integração de ponta a ponta em laboratório.
2. **Field Orders:** persistência local, retentativas e resolução de conflito.
3. **Breda Beats:** manipulação PCM, ciclo de vida do microfone e interface orientada a performance.
4. **Breda Fit:** núcleo KMP, estado de sessão, métricas honestas e interface Android.
5. **Ateliê Breda:** React Native, domínio testável e experiência infantil com dados locais.
6. **Park & Wash:** Flutter, regras de negócio e persistência transacional.

Cada README possui propósito, escopo implementado, comandos, fluxos, referências ao código e evidências. Capturas reais de seis projetos foram incorporadas sem retoques; os demais têm roteiro de telas e indicação explícita da ausência de imagens verificadas nesta rodada.

## Como validar esta rodada

- [ ] Abrir os dez READMEs e conferir se a apresentação representa o produto.
- [ ] Abrir as galerias e comparar com a versão correspondente do app.
- [ ] Executar um fluxo principal e um cenário de falha por projeto.
- [ ] Conferir plataforma, modo local/Firebase e limitações antes de demonstrar.
- [ ] Ler evidências da execução correta: captura, teste automatizado e avaliação física são coisas diferentes.
- [ ] Priorizar próximos projetos após conversar com potenciais compradores.

## Oportunidades de receita a validar

As três sugestões são hipóteses de produto, não promessas de retorno. Evitar começar três implementações simultâneas. A rota inicial proposta é venda direta B2B, onboarding pago e assinatura, após piloto com cliente real e antes de uma operação comercial dependente do sistema.

| Ideia | Primeiro público | Escopo de piloto | Preço de teste sugerido, sem validação de mercado |
|---|---|---|---|
| Breda OS | Assistências técnicas e instaladores independentes | Orçamento, checklist/fotos, aprovação por link, andamento, PDF e histórico | R$ 59–99/mês; implantação R$ 199–399 |
| Breda Agenda Pet | Banho e tosa de bairro | Agenda por profissional, ficha do pet, retorno, lembrete autorizado e caixa simples | R$ 49–89/mês; implantação R$ 149–299 |
| Breda Loca | Pequenas locadoras de ferramentas e equipamentos | Disponibilidade, retirada/devolução, fotos, contrato e cobrança de atraso | R$ 79–149/mês; implantação R$ 299–599 |

Preços são hipóteses propostas pelo autor da revisão, não médias comprovadas nem valores coletados de concorrentes. Mensagens automáticas, armazenamento, pagamentos e suporte têm custos e exigem integração; não estão incluídos nos apps atuais. Não prometer validade jurídica de assinatura eletrônica própria.

### Primeiro passo comercial

Antes de novo desenvolvimento, conversar com cinco negócios de um único nicho, observar a rotina e buscar um piloto pago com escopo/entrega claros. O Park & Wash já permite demonstrar esse método com estacionamentos/lava-rápidos, depois das pendências de segurança, backup e multiusuário. Serviços de implantação/customização podem preceder escala SaaS; nenhum contato externo foi feito nesta rodada.

Referências públicas consultadas em 14/10/2026: [OSApp](https://www.osapp.com.br/), [planos OSApp](https://www.osapp.com.br/precos), [Trinks](https://negocios.trinks.com/planos/). Elas demonstram ofertas existentes nessas categorias; não comprovam demanda específica pelos produtos breda_dev. A ideia de locação é uma hipótese a pesquisar com compradores.
