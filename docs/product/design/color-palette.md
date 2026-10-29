# Paleta de Cores — Cauã Loves Candies

Direção: **Candy Pastel** — cores de bala, algodão-doce e marshmallow. Saturação média-alta nos itens (o que a criança precisa enxergar), pastel suave nos fundos (para o item "saltar" da tela). Sem preto puro e sem branco puro.

## Tokens

### Fundos e superfícies (calmos, pastel)
| Token | Hex | Nome | Uso |
|---|---|---|---|
| `bg-cream` | `#FFF5E6` | Marshmallow | Fundo base do jogo, cards de diálogo |
| `bg-sky` | `#CDEBFF` | Céu Bebê | Fundo do cenário (topo) |
| `bg-cotton` | `#FFD6E8` | Algodão-doce | Fundo do cenário (base), título |
| `bg-lavender` | `#E6D9FF` | Névoa Lavanda | Painéis, HUD, overlay do tutorial |

### Marca e UI (saturadas)
| Token | Hex | Nome | Uso |
|---|---|---|---|
| `brand-bubblegum` | `#FF8FC0` | Chiclete | Cor primária: botões, logo, destaque |
| `brand-bubblegum-dark` | `#E5609D` | Chiclete Escuro | Botão pressionado, sombra do botão |
| `accent-lemon` | `#FFE98A` | Limão-bala | Estrelas, pontos, brilho de acerto |
| `accent-sky` | `#7CC8FF` | Azul Pirulito | Botão secundário, detalhes |
| `accent-grape` | `#B79CFF` | Uva | Faixas da esteira, confete |
| `accent-mint` | `#A8F0D1` | Menta | Feedback positivo, barra de progresso |
| `accent-tangerine` | `#FFB36B` | Tangerina | Confete, acentos quentes |

### Gameplay
| Token | Hex | Nome | Uso |
|---|---|---|---|
| `belt-base` | `#CDB8F0` | Esteira | Corpo da esteira (pálido, para os itens contrastarem) |
| `belt-stripe` | `#B79CFF` | Esteira Listra | Listras/setas de movimento |
| `heart` | `#FF5C7A` | Morango | Ícone de HP (coração) |
| `danger-soft` | `#FF7A7A` | Coral Alerta | Aura/borda dos itens proibidos e perda de HP |

### Texto e contorno
| Token | Hex | Nome | Uso |
|---|---|---|---|
| `ink` | `#5B3A6B` | Ameixa | Texto e contorno dos desenhos (substitui o preto) |
| `ink-soft` | `#8A6A9B` | Ameixa Suave | Texto secundário |

Contraste: `ink` sobre `bg-cream` ≈ 8:1 e sobre `bg-cotton` ≈ 6:1 (AA ok). Texto branco **não** deve ficar sobre as cores pastel; em `brand-bubblegum` use `ink`.

## Regras de composição
1. **Itens vs. fundo:** itens saturados sobre esteira/fundo pastel. Nunca item pastel sobre fundo pastel.
2. **Doces (+2):** cores quentes e vibrantes — chiclete, limão, tangerina, uva.
3. **Frutas (+1):** tons naturais um pouco mais "terrosos" que os doces (morango, laranja, banana, uva verde/menta), para a criança distinguir de doce pelo formato e pela cor.
4. **Itens proibidos (-1 HP):** não depender só de cor (daltonismo, 6 anos). Devem ter **formato distinto + aura coral `danger-soft`** e um tom levemente mais apagado/esverdeado (ex.: brócolis, cebola, sabão, meia suja) com carinha de "eca" fofa, nada assustador.
5. **Contorno:** linha grossa e arredondada em `ink` (~3–4 px a 512 px) em todos os sprites — dá coesão de adesivo/stickers e ajuda no contraste.
6. **Sombra:** sombras em `bg-lavender` escurecido (`#C9B6F2`), nunca cinza ou preto.
7. **Cauã:** manter pele, cabelo e roupa fiéis à referência da família; a boca interna em `#FF6F91` e língua `#FF9FB5`.
8. **Fases:** o céu muda de matiz por fase, mantendo o resto da paleta:
   - Fase 1: `bg-sky` → `bg-cream`
   - Fase 2: `bg-cotton` → `bg-cream`
   - Fase 3 (final): `bg-lavender` → `bg-cotton` + confete multicolor

## Prompt-base para o Gemini (cole no início de cada geração)
```
Estilo: ilustração vetorial 2D fofa, tipo adesivo (sticker), para jogo infantil de 6 anos.
Contorno grosso, arredondado e contínuo na cor #5B3A6B (nunca preto). Formas redondas e simples,
olhos grandes brilhantes quando houver rosto, sombreamento flat com no máximo 1 tom de sombra.
Paleta permitida: #FF8FC0, #E5609D, #FFE98A, #7CC8FF, #B79CFF, #A8F0D1, #FFB36B, #FF5C7A,
#FFF5E6, #CDEBFF, #FFD6E8, #E6D9FF. Sem preto puro, sem branco puro, sem gradientes complexos.
Fundo transparente (ou cor sólida #FFF5E6 se transparência não for possível).
Enquadramento centralizado, margem de 10%, 1:1.
```

## Lista de artes e cores-guia
| Arte | Cores-guia |
|---|---|
| Cauã boca fechada / aberta / feliz / "eca" | pele e cabelo da referência; boca `#FF6F91` |
| Doces (pirulito, bala, cupcake, algodão-doce, chiclete) | `#FF8FC0` `#FFE98A` `#B79CFF` `#7CC8FF` |
| Frutas (morango, banana, uva, laranja) | `#FF5C7A` `#FFE98A` `#B79CFF` `#FFB36B` + folhas `#A8F0D1` |
| Itens proibidos | tons apagados + aura `#FF7A7A` |
| Esteira | `#CDB8F0` com listras `#B79CFF` |
| Cenário (3 variações de fundo) | ver "Fases" |
| Coração HP (cheio/vazio) | `#FF5C7A` / contorno `#5B3A6B` com miolo `#FFF5E6` |
| Logo "Cauã Loves Candies" | `#FF8FC0` com contorno `#5B3A6B` e brilhos `#FFE98A` |
| Confete / estrelas | `#FFE98A` `#FF8FC0` `#7CC8FF` `#A8F0D1` `#B79CFF` `#FFB36B` |

---

# Personagem — Cauã

Referências em `.dev/test-runs/`: `caua-recente.jpg` (principal: cabelo, cabeça, pele), `caua-1.png` (expressão e rosto; cabelo mais curto, **não** usar para cabelo), `caua-2.png` (boca aberta com língua; desfocada, usar só a forma).

## Traços
| Traço | Descrição | Cor |
|---|---|---|
| Cabelo | Cacheado, volumoso, comprimento médio, cachos soltos e arrepiados no topo, franja lateral sobre a testa, volume até as orelhas. Marca registrada. | `#3B2A20` (reflexo `#5A4232`) |
| Pele | Morena clara e quente, bochechas coradas | `#D9A07A` (sombra `#B97E5C`) |
| Olhos | Castanho-escuros, amendoados, sobrancelhas finas | `#3A2A22` |
| Rosto | Redondinho, bochechas cheias, nariz pequeno e arredondado | — |
| Boca | Lábios rosa-salmão `#D98A7A`; interna `#FF6F91`; língua `#FF9FB5`; dentes `#FFF5E6` | — |
| Roupa | Camiseta azul suave com gola V (do royal da foto para a paleta) | `#7CC8FF` ou `#5B8DEF` |

## Adaptação ao estilo candy
- Cabelo simplificado em 4 a 6 cachos grandes em formato de nuvem, mantendo silhueta bagunçada e um cacho solto no topo.
- Olhos grandes e brilhantes com um ponto de luz; blush `#FFB3C7` nas bochechas.
- Contorno `#5B3A6B`, estilo adesivo, como no prompt-base.

## Prompts das poses
Anexar `caua-recente.jpg` e `caua-1.png` em toda geração. Para manter consistência, gere a primeira pose, aprove e **anexe-a como referência nas demais**. Cole o prompt-base da paleta antes de cada prompt abaixo.

**Bloco de identidade (repetir em todos):**
```
Personagem: Cauã, menino de 6 anos, versão cartoon fofa baseada nas fotos anexas.
Cabelo castanho-escuro #3B2A20, cacheado e volumoso, em 4 a 6 cachos grandes arredondados,
com um cacho solto e arrepiado no topo e franja lateral. Pele morena clara #D9A07A, bochechas
redondas com blush #FFB3C7. Olhos castanhos grandes e brilhantes com ponto de luz.
Camiseta azul suave #7CC8FF com gola V. Enquadramento: cabeça e ombros, de frente, centralizado.
Mesmo desenho, proporções e cabelo em todas as poses.
```

**1. Boca fechada (neutro, esperando)**
```
[Bloco de identidade] Expressão: boca fechada, sorriso pequeno e fofo, olhos abertos olhando
para a frente, atento e animado.
```

**2. Boca aberta (comendo)**
```
[Bloco de identidade] Expressão: boca bem aberta em oval grande, língua rosa #FF9FB5 saindo
levemente para fora, interior da boca #FF6F91, dentes superiores brancos #FFF5E6 visíveis,
olhos arregalados e empolgados, sobrancelhas levantadas. A abertura da boca deve ocupar cerca
de 35% do rosto e ficar bem visível, pois é a área onde os itens entram.
```

**3. Feliz (mastigando / acerto)**
```
[Bloco de identidade] Expressão: olhos fechados em arco sorridente (^ ^), bochechas estufadas
com blush mais forte, boca fechada em sorriso largo, pequenas estrelinhas #FFE98A ao redor
da cabeça.
```

**4. "Eca" (item proibido / perde HP)**
```
[Bloco de identidade] Expressão: carinha de "eca" fofa e engraçada, nariz franzido, língua
para fora de lado, olhos meio fechados, sobrancelhas inclinadas. Pequena gotinha de suor
#7CC8FF. Divertido, nada triste, sem lágrimas e sem raiva.
```

**5. Vitória (tela final)**
```
[Bloco de identidade] Expressão: boca aberta num sorriso enorme de alegria, olhos brilhando,
braços para cima comemorando, corpo até a cintura. Confete #FF8FC0 #FFE98A #7CC8FF #A8F0D1
#B79CFF ao redor.
```

## Checklist de aprovação
- [ ] Cabelo reconhecível como o do Cauã (cachos bagunçados, não liso nem curto)
- [ ] Mesma cor de pele, camiseta e proporções entre as poses
- [ ] Boca aberta grande o bastante para o gameplay
- [ ] Fundo transparente e legível em ~120 px de largura no celular
- [ ] "Eca" claramente diferente da boca aberta mesmo em tamanho pequeno
