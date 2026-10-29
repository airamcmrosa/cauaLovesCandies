# Prompts de Arte para o Gemini — Cauã Loves Candies

Como usar: cole primeiro o **Prompt-base para o Gemini** de `color-palette.md` (seção "Prompt-base para o Gemini"). Abaixo, `[Prompt-base da paleta]` significa exatamente isso. Os prompts de Cauã ficam em `color-palette.md` ("Prompts das poses") e não são repetidos aqui.

## Regras globais (valem para TODAS as artes)
- Paleta e contorno `#5B3A6B` do `color-palette.md`. Contorno grosso, arredondado, contínuo (~3-4 px a 512 px).
- **Nada de estrelas, brilhos, confete, faíscas ou partículas desenhados.** Tudo isso é animado em código.
- Saída final em `.webp` (gerar PNG e converter), em `assets/images/...`. Transparência quando indicado.
- Legível a 64-96 px: silhueta simples, sem detalhes finos, um tom de sombra no máximo (`#C9B6F2`).
- Regra de categoria: **só itens proibidos têm rosto** (carinha de "eca"). Doces e frutas NÃO têm rosto.
- Frutas e doces saturados; proibidos mais apagados, com aura coral `#FF7A7A` de borda **serrilhada/ondulada** (formato, não só cor, para daltonismo).

**[Negativo-global]** (já repetido em cada prompt): estrelas, brilhos, faíscas, confete, partículas, texto, letras, marca d'água, preto puro, branco puro, gradientes complexos, fotorrealismo, sombra projetada cinza/preta, contorno fino ou irregular, conteúdo assustador.

---

## 1. Alimentos (512x512, fundo transparente, 1:1)

Destino: `assets/images/items/`. Cada item: enquadrado no centro, margem 10%, vista frontal levemente de 3/4, **sem rosto**.

### 1.1 Doces (+2) — cores quentes e vibrantes

**pirulito** — `assets/images/items/candy_lollipop.webp`
```
[Prompt-base da paleta]
Item: pirulito redondo em espiral rosa #FF8FC0 e lilás #B79CFF, com palito curto #FFF5E6 e um laço
pequeno #FFE98A no palito. Silhueta circular grande sobre palito curto, bem legível pequeno.
Sem rosto. 512x512, fundo transparente.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, rosto, preto puro, branco puro,
gradiente complexo, contorno fino, sombra cinza.
```

**bala** — `assets/images/items/candy_wrapped.webp`
```
[Prompt-base da paleta]
Item: bala embrulhada clássica horizontal (papel torcido nas duas pontas), corpo #FFB36B tangerina com
listras #FFE98A e pontas em leque #FF8FC0. Silhueta de "osso/gravata" larga. Sem rosto.
512x512, fundo transparente.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, rosto, preto puro, branco puro,
gradiente complexo, contorno fino, sombra cinza.
```

**cupcake** — `assets/images/items/candy_cupcake.webp`
```
[Prompt-base da paleta]
Item: cupcake com cobertura alta de glacê rosa #FF8FC0 em espiral, forminha #7CC8FF com pregas,
uma cereja #FF5C7A no topo e granulado simples #FFE98A (poucos pontos grandes, parte do desenho,
não brilho). Silhueta triangular larga. Sem rosto. 512x512, fundo transparente.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, rosto, preto puro, branco puro,
gradiente complexo, contorno fino, sombra cinza.
```

**rosquinha** — `assets/images/items/candy_donut.webp`
```
[Prompt-base da paleta]
Item: rosquinha (donut) vista levemente de cima, massa #FFB36B com cobertura de glacê rosa #FF8FC0
em borda ondulada e buraco central bem aberto; granulado simples #FFE98A, #7CC8FF e #A8F0D1 (poucos
traços grandes, parte do desenho, não brilho). Silhueta de anel grossa. Sem rosto.
512x512, fundo transparente.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, rosto, preto puro, branco puro,
gradiente complexo, contorno fino, sombra cinza.
```

**granulado** — `assets/images/items/candy_sprinkles.webp`
```
[Prompt-base da paleta]
Item: potinho redondo e baixo de granulado colorido (tampa aberta), vidro #E6D9FF com contorno grosso,
cheio de traços grandes e arredondados em #FF8FC0, #FFE98A, #7CC8FF, #A8F0D1, #B79CFF e #FFB36B
transbordando um pouco no topo, rótulo liso #FF8FC0 sem texto. Silhueta de pote largo, bem legível
pequeno (traços grandes, nunca finos). Sem rosto. 512x512, fundo transparente.
Negativo: estrelas, brilhos, faíscas, confete solto fora do pote, partículas, texto, rosto, preto puro,
branco puro, gradiente complexo, contorno fino, sombra cinza.
```

**algodao_doce** — `assets/images/items/candy_cotton.webp`
```
[Prompt-base da paleta]
Item: algodão-doce em nuvem grande e fofa de formato irregular arredondado, cor #FF8FC0 com tufos em
#B79CFF, sobre palito/cone #FFF5E6 curto. Contorno ink grosso mesmo nos tufos (obrigatório, para não
sumir em fundo pastel). Sem rosto. 512x512, fundo transparente.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, rosto, preto puro, branco puro,
gradiente complexo, contorno fino ou ausente, sombra cinza.
```

**chiclete** — `assets/images/items/candy_gum.webp`
```
[Prompt-base da paleta]
Item: bola de chiclete: uma esfera grande #7CC8FF com sombra flat #C9B6F2 e um reflexo flat simples
(forma curva, nunca estrela), com uma bolinha menor colada à direita e um pedacinho de chiclete #FF8FC0
esticado embaixo. Contorno ink grosso. Sem rosto. 512x512, fundo transparente.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, rosto, preto puro, branco puro,
gradiente complexo, contorno fino, sombra cinza.
```

### 1.2 Frutas (+1) — saturadas, um pouco mais naturais que os doces

**morango** — `assets/images/items/fruit_strawberry.webp`
```
[Prompt-base da paleta]
Item: morango gordinho em formato de coração arredondado, corpo #FF5C7A, sementes #FFE98A grandes e
poucas (6-8), folhas #A8F0D1 com contorno ink. Sem rosto. 512x512, fundo transparente.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, rosto, preto puro, branco puro,
gradiente complexo, contorno fino, sombra cinza.
```

**banana** — `assets/images/items/fruit_banana.webp`
```
[Prompt-base da paleta]
Item: uma banana curvada em arco largo (silhueta de meia-lua), casca #FFE98A com sombra #FFB36B e
ponta/cabinho #A8F0D1 esverdeado escuro com contorno ink. Sem rosto. 512x512, fundo transparente.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, rosto, preto puro, branco puro,
gradiente complexo, contorno fino, sombra cinza.
```

**uva** — `assets/images/items/fruit_grape.webp`
```
[Prompt-base da paleta]
Item: cacho de uvas em formato de triângulo invertido, 7 a 9 uvas grandes e bem separadas por contorno
ink grosso, cor #B79CFF com sombra #C9B6F2 e ponto de luz flat #E6D9FF; talo marrom-ameixa #5B3A6B e uma
folha #A8F0D1. Contorno ink extra grosso (a cor roxa é próxima da esteira). Sem rosto.
512x512, fundo transparente.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, rosto, preto puro, branco puro,
gradiente complexo, contorno fino, sombra cinza.
```

**laranja** — `assets/images/items/fruit_orange.webp`
```
[Prompt-base da paleta]
Item: laranja redonda, #FFB36B, com textura simples de 3 pontinhos de poro e uma fatia/gomo aparecendo
na lateral, folha #A8F0D1 no topo. Contorno ink grosso. Sem rosto. 512x512, fundo transparente.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, rosto, preto puro, branco puro,
gradiente complexo, contorno fino, sombra cinza.
```

**melancia** — `assets/images/items/fruit_watermelon.webp`
```
[Prompt-base da paleta]
Item: fatia de melancia em meia-lua grossa, polpa #FF5C7A, casca verde #A8F0D1 com faixa interna
#FFF5E6 e sementes grandes e simples em #5B3A6B (poucas, parte do desenho). Contorno ink grosso.
Silhueta de meia-lua larga, bem legível pequeno. Sem rosto. 512x512, fundo transparente.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, rosto, preto puro, branco puro,
gradiente complexo, contorno fino, sombra cinza.
```

### 1.3 Itens proibidos (-1 HP) — formato distinto + aura coral serrilhada + carinha de "eca" fofa

Todos: corpo em tom **apagado/esverdeado** (saturação baixa), aura `#FF7A7A` em formato de **borda ondulada/serrilhada (estilo nuvem de cheiro) colada ao contorno**, não um brilho; carinha de "eca" (olhos meio fechados, boca torta, língua de lado), engraçada, **sem lágrimas, sem raiva, sem dentes pontudos**. A aura deve ser desenhada como forma sólida plana, não como brilho/glow.


**cebola** — `assets/images/items/bad_onion.webp`
```
[Prompt-base da paleta]
Item proibido: cebola em formato de gota/pião (bojo redondo, ponta torcida em cima com 2 raízes
finas na base), cor roxo-acinzentado apagado #B8A0C8 com camadas em curva #D8C8E0. Rosto "eca" fofo
no bojo: olhos meio fechados, boca torta, uma única gotinha #7CC8FF de suor (desenhada, não brilho).
Borda ondulada sólida #FF7A7A ao redor do contorno #5B3A6B. Nada assustador. 512x512, fundo transparente.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, glow/neon, lágrimas, raiva, preto
puro, branco puro, gradiente complexo, contorno fino.
```

**sabao** — `assets/images/items/bad_soap.webp`
```
[Prompt-base da paleta]
Item proibido: barra de sabão retangular de cantos bem arredondados, azul-acinzentado apagado #9CC0D6
com face superior #BCD6E4, 3 bolhas simples (círculos contorno ink, miolo #E6D9FF, sem reflexo) coladas
numa quina. Rosto "eca" fofo na face frontal: olhos meio fechados, boca em onda, língua de lado.
Borda ondulada sólida #FF7A7A ao redor do contorno #5B3A6B. Nada assustador. 512x512, fundo transparente.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, glow/neon, lágrimas, raiva, preto
puro, branco puro, gradiente complexo, contorno fino.
```

**meia_suja** — `assets/images/items/bad_sock.webp`
```
[Prompt-base da paleta]
Item proibido: meia suja em formato de "bota" (perna vertical + pé dobrado para a direita), cor bege
acinzentado apagado #CDBFA8 com faixas #B5A68C e remendo/mancha marrom-ameixa suave #A8928A. Rosto
"eca" fofo na perna: olhos meio fechados, boca torta. Duas linhas onduladas de cheiro #A8F0D1 esverdeado
saindo do topo (desenhadas, contorno ink, parte do objeto). Borda ondulada sólida #FF7A7A ao redor do
contorno #5B3A6B. Nada assustador, só engraçado. 512x512, fundo transparente.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, glow/neon, lágrimas, raiva, preto
puro, branco puro, gradiente complexo, contorno fino.
```

### 1.4 Sprite sheet opcional por categoria
Só use se os itens individuais já estiverem aprovados e fixos (anexar as imagens aprovadas). Depois recortar em 512x512 cada. Destino: `assets/images/items/sheet_<categoria>.webp`.

**sheet_doces** — 5 células, 2560x512, fundo transparente
```
[Prompt-base da paleta]
Anexe as 5 imagens aprovadas de doces como referência. Gere um sprite sheet horizontal 2560x512 com
5 células iguais de 512x512, na ordem: pirulito, bala, cupcake, algodão-doce, chiclete. Mesmo traço,
mesma espessura de contorno, mesma luz, itens centralizados com margem de 10% por célula, sem linhas
de grade, fundo transparente. Sem rosto.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, grade visível, preto puro, branco
puro, gradiente complexo, itens cortados na borda da célula.
```

**sheet_frutas** — 4 células, 2048x512 (mesma lógica: morango, banana, uva, laranja; mesmo negativo).
**sheet_proibidos** — 4 células, 2048x512 (brócolis, cebola, sabão, meia suja; manter aura serrilhada #FF7A7A e rostinho "eca" em todas; mesmo negativo + sem glow).

---

## 2. Logo "Cauã Loves Candies"

**Decisão:** o logo é gerado **sem estrelas/brilhos desenhados** — eles serão partículas animadas no jogo (twinkle sobre o logo), e as `#FFE98A` brilham melhor animadas; reservar espaço livre no canto superior direito de "Candies" e acima do "ã".
Destino: `assets/images/ui/logo_caua_loves_candies.webp` — 1600x800 (2:1), fundo transparente.
```
[Prompt-base da paleta]
Logo tipográfico "Cauã Loves Candies" em duas linhas: "Cauã" grande em cima (com til no ã bem
visível) e "Loves Candies" menor embaixo, com um coração #FF5C7A pequeno no lugar do "o" de Loves.
Letras gordas, arredondadas, estilo bala/chiclete 3D-flat, preenchimento #FF8FC0, sombra interna
#E5609D só na base de cada letra, contorno externo grosso #5B3A6B e uma segunda borda externa
#FFF5E6 de 6 px (efeito adesivo). Letras ligeiramente irregulares/saltitantes na linha de base.
Deixe espaço livre em volta (margem 8%) e áreas de respiro sobre "ã" e fim de "Candies" (sem desenhos).
1600x800, fundo transparente. Legível a 280 px de largura.
Negativo: estrelas, brilhos, faíscas, confete, partículas, doces desenhados dentro das letras, rosto,
texto extra, tagline, preto puro, branco puro, gradiente complexo, serifa, fonte fina.
```

---

## 3. Fundo do menu / tela de título
Destino: `assets/images/bg/menu_bg.webp` — 1080x1920 (9:16), fundo opaco.
```
[Prompt-base da paleta]
Cenário de título para jogo infantil em retrato 1080x1920: céu degradê suave de duas cores chapadas
(faixas) #FFD6E8 no topo para #FFF5E6 embaixo, com 4 a 5 nuvens fofas #FFF5E6 de contorno #5B3A6B no
terço superior e uma fileira de colinas arredondadas doces (#A8F0D1, #CDEBFF, #E6D9FF) na base, com
2 pirulitos e 1 cupcake pequenos como cenário distante nas colinas (muito menores, bem nas bordas).
**Zona central livre** (do 20% ao 80% da altura, 15% a 85% da largura): apenas céu liso, sem
objetos, para logo e botão JOGAR. Sem texto, sem personagem. Cores pastel suaves e baixo contraste
para os itens decorativos não competirem com o logo.
Negativo: estrelas, brilhos, faíscas, confete, partículas, balões, texto, letras, personagem, objetos
na zona central, preto puro, branco puro, gradiente complexo, contraste forte.
```

---

## 4. Céus / cenários de fase
Portrait 1080x1920, opacos. **Área inferior livre (últimos 38% da altura, a partir de y≈1190)**: só cor lisa/pouco detalhe para a esteira e o Cauã. Horizonte baixo e suave; nuvens apenas no terço superior. Contraste baixo: o fundo nunca deve competir com os itens.

**Fase 1** — `assets/images/bg/stage1_sky.webp`
```
[Prompt-base da paleta]
Cenário de jogo em retrato 1080x1920: céu em faixas suaves de #CDEBFF (topo) para #FFF5E6 (base),
3 a 4 nuvens fofas #FFF5E6 com contorno #5B3A6B no terço superior, bem espaçadas e pequenas. Do 62% de
altura até embaixo: faixa lisa #FFF5E6 totalmente livre (sem objetos) para esteira e personagem.
Sem texto, sem personagem.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, personagem, objetos na área inferior,
preto puro, branco puro, gradiente complexo, contraste forte.
```

**Fase 2** — `assets/images/bg/stage2_sky.webp`
```
[Prompt-base da paleta]
Cenário de jogo em retrato 1080x1920: céu em faixas suaves de #FFD6E8 (topo) para #FFF5E6 (base),
nuvens #FFF5E6 com contorno #5B3A6B no terço superior, algumas em formato de algodão-doce, bem
espaçadas e pequenas. Do 62% de altura até embaixo: faixa lisa #FFF5E6 totalmente livre.
Sem texto, sem personagem.
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, personagem, objetos na área inferior,
preto puro, branco puro, gradiente complexo, contraste forte.
```

**Fase 3** — `assets/images/bg/stage3_sky.webp`
```
[Prompt-base da paleta]
Cenário de jogo em retrato 1080x1920: céu em faixas suaves de #E6D9FF (topo) para #FFD6E8 (base),
nuvens #FFF5E6 com contorno #5B3A6B no terço superior, um pouco maiores e com arco-íris pastel simples
(faixas #FF8FC0, #FFE98A, #A8F0D1, #7CC8FF) atrás das nuvens, sem brilho. Do 62% de altura até
embaixo: faixa lisa #FFD6E8 totalmente livre. Sem texto, sem personagem. Clima de festa, mas SEM
confete, balões, serpentinas ou estrelas desenhados (o confete é animado).
Negativo: estrelas, brilhos, faíscas, confete, serpentinas, balões, partículas, texto, personagem,
objetos na área inferior, preto puro, branco puro, gradiente complexo, contraste forte.
```

---

## 5. Elementos de tela de jogo

**Fundo de balcão/horizonte (opcional, só se o céu não cobrir a base)** — `assets/images/bg/game_counter.webp`, 1080x640, opaco
```
[Prompt-base da paleta]
Faixa horizontal 1080x640 de balcão de doceria vista de frente: topo plano #FFF5E6 com borda
arredondada contorno #5B3A6B, frente em listras verticais largas #FFD6E8 e #FFF5E6, base #E6D9FF.
Muito simples, sem objetos em cima (a esteira e o Cauã serão sobrepostos).
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, objetos sobre o balcão, preto puro,
branco puro, gradiente complexo.
```

**Esteira (tile repetível)** — `assets/images/game/belt_tile.webp`, 512x192 (tile horizontal, opaco)
```
[Prompt-base da paleta]
Tile horizontal sem emenda (bordas esquerda e direita idênticas, repetível) 512x192 de esteira vista de
lado: corpo #BFA6EC com contorno superior e inferior grosso #5B3A6B; setas/chevrons de movimento em
#8F72D6 (mais escuras que o corpo) espaçadas igualmente com período de 128 px (4 repetições exatas por
tile); faixa inferior #C9B6F2 de sombra. Sem rebites irregulares, sem detalhes que quebrem o padrão
na emenda. (Valores recomendados na análise de contraste; se não aprovados, usar #CDB8F0 e #B79CFF.)
Negativo: estrelas, brilhos, faíscas, confete, partículas, texto, emenda visível, elementos que passem
da borda esquerda/direita, preto puro, branco puro, gradiente complexo, uva-roxa idêntica à cor da listra.
```

**Coração HP cheio** — `assets/images/ui/heart_full.webp`, 256x256, transparente
```
[Prompt-base da paleta]
Coração gordinho simétrico, corpo #FF5C7A, contorno grosso #5B3A6B, reflexo flat curvo #FF8FC0 no lobo
esquerdo (uma forma, não brilho em estrela). Sem rosto. 256x256, fundo transparente, margem 8%.
Negativo: estrelas, brilhos, faíscas, partículas, texto, rosto, preto puro, branco puro, gradiente complexo.
```

**Coração HP vazio** — `assets/images/ui/heart_empty.webp`, 256x256, transparente
```
[Prompt-base da paleta]
Mesmo coração (mesma silhueta, tamanho e contorno do heart_full), miolo #FFF5E6, contorno #5B3A6B igual
de grosso, sem reflexo. Deve ser claramente "vazio", mas ainda visível. 256x256, fundo transparente.
Negativo: estrelas, brilhos, faíscas, partículas, texto, rosto, rachadura, lágrima, preto puro, branco
puro, gradiente complexo.
```

**Ícone check (✓)** — `assets/images/ui/icon_check.webp`, 256x256, transparente
```
[Prompt-base da paleta]
Círculo adesivo #A8F0D1 com contorno grosso #5B3A6B e um símbolo de check ✓ grosso e arredondado em
verde mais escuro #2E9E6B (com contorno ink) no centro. Forma de ✓ nítida (o formato diz "certo", não
só a cor). 256x256, fundo transparente.
Negativo: estrelas, brilhos, faíscas, partículas, texto, rosto, preto puro, branco puro, gradiente complexo.
```

**Ícone X (✗)** — `assets/images/ui/icon_cross.webp`, 256x256, transparente
```
[Prompt-base da paleta]
Círculo adesivo #FF7A7A com contorno grosso #5B3A6B e um X grosso e arredondado em #FFF5E6 com contorno
ink no centro. Forma de X nítida (o formato diz "errado", não só a cor). Mesma espessura e tamanho do
ícone check. 256x256, fundo transparente.
Negativo: estrelas, brilhos, faíscas, partículas, texto, rosto, preto puro, branco puro, gradiente complexo.
```

**Mão/dedo de toque (tutorial)** — `assets/images/ui/tap_hand.webp`, 384x384, transparente
```
[Prompt-base da paleta]
Mão de desenho infantil com o dedo indicador apontando para cima-esquerda (gesto de toque), punho
fechado fofo, pele #D9A07A com sombra #B97E5C, contorno grosso #5B3A6B, manga curta #7CC8FF. Ponta do
dedo no canto superior esquerdo do enquadramento (âncora do toque) para encaixe da animação. Sem
ondas, círculos de toque ou setas desenhadas (animados no jogo). 384x384, fundo transparente.
Negativo: estrelas, brilhos, faíscas, ondas de toque, setas, partículas, texto, rosto, dedos extras,
mão realista, preto puro, branco puro, gradiente complexo.
```

---

## 6. Frames faltantes do Cauã (TASK-012)
Anexe sempre o frame de referência indicado e mantenha o mesmo estilo de entrega dos frames já
aprovados: borda branca de adesivo fechada em volta do personagem e fundo sólido creme (o recorte
automático depende da borda branca). Nada de estrelas, brilhos ou confete.

**caua_mouth_closed_eyes_half** — referência: `caua_mouth_closed_eyes_open.png`
```
Mesma imagem anexa, alterando APENAS os olhos para semicerrados (pálpebras na metade, meio caminho
entre aberto e fechado). Boca, cabelo, bochechas, camiseta, enquadramento, tamanho 2048x2048 e
borda branca de adesivo idênticos. Nada mais muda.
```

**caua_mouth_open_eyes_open** — referência: `caua_mouth_open_eyes_half.png`
```
Mesma imagem anexa, alterando APENAS os olhos para totalmente abertos, grandes e brilhantes com ponto
de luz, empolgados. Boca aberta, cabelo, bochechas, camiseta, enquadramento, tamanho 2048x2048 e
borda branca de adesivo idênticos. Nada mais muda.
```

**caua_chew_eyes_open** — referência: `caua_chew_eyes_half.png`
```
Mesma imagem anexa (bochechas estufadas, boca fechada mastigando), alterando APENAS os olhos para
totalmente abertos, grandes e brilhantes com ponto de luz. Cabelo, bochechas, boca, camiseta,
enquadramento, tamanho 2048x2048 e borda branca de adesivo idênticos. Nada mais muda.
```

## Checklist de consistência entre gerações
- [ ] Gerar primeiro **um** item (ex.: morango), aprovar e anexá-lo como referência em todas as gerações seguintes.
- [ ] Mesma espessura de contorno `#5B3A6B` em todas as artes (conferir a 512 px: ~3-4 px).
- [ ] Mesma direção de luz (do alto-esquerda) e **um** tom de sombra flat (`#C9B6F2`).
- [ ] Conferir hex dominante com conta-gotas; rejeitar preto/branco puros e gradientes.
- [ ] Redução de teste: abrir cada sprite a 64 px e 96 px sobre a esteira — silhueta reconhecível sem cor (teste em escala de cinza/deuteranopia).
- [ ] Doces e frutas sem rosto; proibidos sempre com rosto "eca" + aura serrilhada.
- [ ] Nenhuma estrela, brilho, confete ou partícula na imagem; fundo transparente de fato (sem halo claro nas bordas).
- [ ] Esteira: testar repetição lado a lado (emenda invisível).
- [ ] Converter para `.webp` e conferir peso (sprites < 40 KB, fundos < 150 KB) pelo orçamento de carga <3 s em 4G.
