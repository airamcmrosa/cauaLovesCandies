---
title: User Stories
project: Cauã Loves Candies - Birthday Game Edition
version: 1.0.0-mvp
createdAt: 2026/10/21
target_date: 2026/11/04
references:
  - "/docs/product/product-vision.md"
---

# 📖 User Stories & Requirements Specification

Este documento centraliza todas as **User Stories** do jogo *Cauã Loves Candies*, organizadas por épicos, contendo a matriz de rastreabilidade (Index, Status, Tasks e ADRs associados) e os critérios de aceite para a entrega da MVP até a data do aniversário (**04/11/2026**).

---

### EP01: Onboarding e Experiência do Aniversariante

#### **US01 - Tela de Abertura e Boas-Vindas**
- **Como** criança convidada na festa,
- **Quero** ver uma tela inicial colorida, animada e com a foto em desenho do Cauã ao abrir o jogo pelo QR Code,
- **Para que** eu identifique imediatamente o tema da festa de 6 anos e saiba onde clicar para começar.

**Critérios de Aceite:**
1. Exibir o título animado *"Cauã Loves Candies"*.
2. Exibir o avatar em versão vetor/desenho do Cauã.
3. Exibir um botão grande e destacado: **"JOGAR"**.
4. Executar uma música de fundo alegre (com opção de toque para liberar o áudio no navegador mobile).
5. Carregar em background (*pre-load*) todos os sprites e sons antes de iniciar a partida.

---

#### **US06 - Tutorial Visual Rápido (*Hands-On Overlay*)**
- **Como** criança de 6 anos jogando pela primeira vez,
- **Quero** ver uma instrução visual animada assim que a partida começar,
- **Para que** eu entenda instantaneamente como abrir e fechar a boca do Cauã sem precisar ler textos longos.

**Critérios de Aceite:**
1. **Exibição Automática:** Ao clicar em "JOGAR", o jogo inicia em estado de pausa/câmera lenta na Fase 1 com um *overlay* semitransparente.
2. **Animação Indicativa (Mãozinha/Dedo):**
   - Exibir animação de um dedo fazendo o gesto de *tap* na tela.
   - Mostrar a boca do Cauã alternando visualmente entre aberta e fechada em sincronia com o toque.
3. **Identificação Visual dos Alimentos:**
   - Ícone de **Doce/Fruta** apontando para **✓ (Verde)**.
   - Ícone de **Objeto Proibido (ex: Brócolis)** apontando para **✗ (Vermelho)**.
4. **Dismissal:** Ao primeiro toque (*tap*) na tela, o tutorial desaparece suavesamente (*fade-out*) e a esteira começa a rodar imediatamente.
5. **Duração Máxima:** Compreendido em menos de 3 segundos.

---

### EP02: Mecânica Core e Controle (Game Loop)

#### **US02 - Controle de Abrir/Fechar a Boca (*Tap Mechanic*)**
- **Como** jogador,
- **Quero** tocar na tela (*tap*) para abrir ou fechar a boca do Cauã,
- **Para que** eu escolha quais itens da esteira ele vai comer ou ignorar.

**Critérios de Aceite:**
1. Por padrão, a boca do Cauã alterna seu estado ou responde ao comando de clique/toque de forma instantânea.
2. Resposta imediata sem lag de input no navegador mobile.
3. Feedback visual claro do avatar trocando entre os estados de boca aberta e boca fechada.

---

#### **US03 - Esteira de Alimentos e Pontuação**
- **Como** jogador,
- **Quero** ver os itens passando na esteira e ganhar pontos ao comer alimentos corretos,
- **Para que** eu consiga avançar de fase no jogo.

**Critérios de Aceite:**
1. Os itens devem avançar pela esteira em velocidade constante por fase.
2. **Classificação dos Itens e Pontuação:**
   - **Doces (+2 pontos):** Pirulito, Rosquinha/Donut, Granulado. Efeito sonoro festivo.
   - **Frutas (+1 ponto):** Morango, Banana, Melancia. Efeito sonoro positivo.
   - **Itens Proibidos (Penalidade / -1 HP):** Brócolis, Sabão, Meia/Meleca. Efeito sonoro cômico ("yuck/oops").
3. Exibir contador visual de pontuação e barra/ícones de vida (HP) no topo da tela.

---

### EP03: Progressão de Fases e Dificuldade

#### **US04 - Transição e Progressão das 3 Fases**
- **Como** jogador,
- **Quero** que a esteira fique mais rápida a cada fase concluída,
- **Para que** o jogo continue divertido e desafiador.

**Critérios de Aceite:**
1. **Fase 1 (Nível Fácil):** Velocidade baixa (**1.0x**). Meta: **10 pontos**.
2. **Fase 2 (Nível Médio):** Velocidade média (**1.35x**). Meta: **20 pontos** (pontuação total acumulada).
3. **Fase 3 (Nível Final):** Velocidade rápida (**1.65x**). Meta: **30 pontos** (pontuação total acumulada).
4. Exibir aviso rápido na tela (*ex: "Fase 2 - Mais Rápido!"*) ao mudar de fase sem travar o jogo.

---

### EP04: Celebração e Encerramento

#### **US05 - Tela de Vitória e Celebração Final**
- **Como** jogador,
- **Quero** ver uma tela comemorativa com confetes e mensagem para o Cauã ao vencer a Fase 3,
- **Para que** eu celebre o aniversário de 6 anos junto com ele.

**Critérios de Aceite:**
1. Disparar animação de confetes/fogos 2D na tela ao concluir a Fase 3.
2. Exibir mensagem: *"Parabéns, você ajudou o Cauã a comer todos os doces! Feliz Aniversário, Cauã!"*.
3. Tocar efeito sonoro de celebração.
4. Exibir botão grande: **"JOGAR NOVAMENTE"**.
5. Se o HP zerar, exibir tela amigável (*"Tente de Novo!"*) com reinício instantâneo.