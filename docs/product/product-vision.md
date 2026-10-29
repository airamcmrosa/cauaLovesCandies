---
title: Product Vision & Governance Strategy
project: Cauã Loves Candies - Birthday Game Edition
version: 1.0.0-mvp
createdAt: 2026/10/21
domain_scope:
  input: "Festa de Aniversário 6 Anos (04/11/2026) / Acesso Web Mobile via QR Code"
  output: "Flutter + Flame Engine Web App (100% Client-Side Static Hosting)"
  core_pattern: "Arcade Tap Mechanic / Progressive Conveyor Belt Speed / Zero-Backend Architecture"
reference: "/docs/product/roadmap-and-mvp-scope.md"
---

# Product Vision & Strategy: Cauã Loves Candies

> Scope note: este documento estabelece a visão do produto, diretrizes de governança, restrições técnicas e fluxo do jogo. Detalhes de implementação e roadmap de sprints até a data da festa (04/11/2026) estão centralizados no escopo executável.

---

## 🎯 Executive Elevator Pitch

- **FOR** Crianças de 6 anos (Cauã e convidados) e familiares presentes na festa de aniversário
- **WHO** buscam diversão e entretenimento instantâneo no celular, sem necessidade de baixar aplicativos, criar contas ou encarar regras complexas
- **THE Cauã Loves Candies**
- **IS AN** jogo arcade 2D *hyper-casual* web mobile desenvolvido em Flutter e Flame Engine
- **THAT** entrega uma experiência comemorativa personalizada com a versão em desenho do aniversariante, onde os jogadores controlam a boca do Cauã para comer doces e frutas em uma esteira rápida, evitando alimentos indesejados
- **UNLIKE** jogos comerciais pesados, cheios de anúncios, menus complexos ou telas de compra
- **OUR PRODUCT** é 100% gratuito, leve, focado em custo zero de infraestrutura (100% client-side), acessível via QR Code e projetado especificamente para celebrar os 6 anos do Cauã com feedback totalmente positivo.

---

## 🔄 The Bimodal Journey: Two-Phase Workflow & Game Loop

O jogo adota uma arquitetura *Zero-Backend*, dividida estritamente em duas fases de experiência de usuário sem atritos:

```text
┌────────────────────────────────────────────────────────┐     ┌────────────────────────────────────────────────────────┐
│ FASE 1: ONBOARDING & START (QR CODE TO PLAY)           │ ──> │ FASE 2: GAME LOOP & PROGRESSIVE CELEBRATION            │
│ • Entrada via QR Code sem cadastro ou login            │     │ • Fase 1: Esteira Normal (Meta: 10 pts)                │
│ • Tela Inicial com Animação e "Cauã Loves Candies"      │     │ • Fase 2: Esteira Rápida (Meta: 20 pts)                │
│ • Pre-loading silencioso de assets (Imagens/Áudios)    │     │ • Fase 3: Desafio Final & Tela de Vitória Comemorativa │
└────────────────────────────────────────────────────────┘     └────────────────────────────────────────────────────────┘

```

### Phase 1: Assessment & Onboarding (Tela Inicial & Carga)

* **Acesso Instantâneo:** Leitura do QR Code físico (disposto nas mesas da festa) que direciona direto para a URL do jogo (ex: GitHub Pages/Vercel).
* **Zero Friction Input:** Sem cadastro, sem termos de aceite e sem necessidade de preencher nome.
* **Asset Warm-up:** Carga dos spritesheets otimizados em `.webp` e trilha sonora comprimida em `.mp3` durante o carregamento da tela de abertura animada.

### Phase 2: Game Loop & Escalada de Fases (Act 2 - Gameplay)

* **Mecânica Principal (Tap Controls):** O usuário toca na tela (*tap*) para abrir ou fechar a boca do avatar vetorizado do Cauã.
* **Lógica da Esteira (Conveyor Belt):**
* **Doces:** Concedem **+2 pontos**.
* **Frutas:** Concedem **+1 ponto**.
* **Itens Proibidos (Alimentos indesejados):** Reduzem a vida (HP) do Cauã se forem engolidos.


* **Progressão de Dificuldade:**
* **Fase 1:** Velocidade padrão da esteira. Objetivo: Alcançar **10 pontos**.
* **Fase 2:** Incremento na velocidade da esteira e frequência de itens. Objetivo: Alcançar **20 pontos**.
* **Fase 3:** Nível final comemorativo e ritmo acelerado.


* **Celebração Individual (End-Game):** Ao concluir as 3 fases, dispara tela final comemorativa com confete, mensagens de parabéns para o Cauã e opção de jogar novamente (*Restart*).

---

## 🎯 Target Success Metrics & FinOps Strategy

* **Custo de Infraestrutura & Licenciamento (FinOps Impact):** **R$ 0,00 (100% Free Tier)** aproveitando GitHub Pages / Vercel para hospedagem estática, assets de áudio royalty-free e imagem vetorial gerada por IA.
* **Performance & Time-to-Load:** Download do *bundle* web em menos de **3 segundos** em conexões 4G, garantindo inicialização rápida em navegadores iOS (Safari) e Android (Chrome).
* **Data da Entrega (Deadline Inegociável):** Deploy final testado e homologado até **01/11/2026** (3 dias antes do aniversário em 04/11/2026).
* **Usabilidade Infantil (UX Target):** Interface adaptada para crianças de 6 anos com botões grandes, feedback sonoro alegre a cada ponto e taxa de sucesso garantida para evitar frustração.