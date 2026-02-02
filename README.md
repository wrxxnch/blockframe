# BlockFrame

📦 **BlockFrame** é um mod para Minetest que permite pré-visualizar e posicionar blocos (ou qualquer item) com precisão antes de colocá-los no mundo.  
Ideal para construção detalhada ou para testar posições antes de confirmar.

---

## **Funcionalidades**

- Pré-visualização de blocos com tamanho, rotação e espelhamento ajustáveis.
- Aceita **qualquer item**, não só blocos.
- Snap (grade) ajustável para posicionamento preciso.
- Posicionamento absoluto ou relativo à mira do jogador.
- Undo e delete com devolução do item.
- Comandos de ajuda e cancelamento.

---

## **Comandos**

- `/blockframe <args>` — Cria ou atualiza o preview do bloco.  
  **Args possíveis:**
  - `size=x,y,z` — Tamanho do bloco (1 valor = x=y=z)  
  - `rotate=x,y,z` — Rotação em graus nos eixos X, Y e Z  
  - `mirror=x|y|z` — Espelhamento  
  - `pos=x,y,z` — Posição absoluta do bloco  
  - `step=valor` — Snap da mira  

  **Exemplos:**
/blockframe size=0.5
/blockframe size=1,0.5 rotate=0,90,0
/blockframe pos=1,2,3 step=0.1
/blockframe mirror=x rotate=45,0,90


- `/blockframe_set` — Coloca o bloco no mundo com base no preview.
- `/blockframe_cancel` — Cancela o preview ativo.
- `/blockframe_undo` — Remove o último bloco colocado e devolve o item.
- `/blockframe_del` — Remove um bloco apontado e devolve o item.
- `/blockframe_help` — Mostra ajuda com exemplos.

---

## **Arquivos do mod**

blockframe/
├── init.lua # Código completo do mod, incluindo preview, placed, comandos e memoria
├── README.md # Este arquivo
└── LICENSE.txt # Licença MIT


> Todos os arquivos estão contidos em uma pasta `blockframe/`.

---

## **Instalação**

1. Copie a pasta `blockframe` para a pasta `mods/` do Minetest.
2. Ative o mod no seu mundo (`world.mt` ou menu de mods).
3. Inicie o mundo e use `/blockframe_help` para começar.

---

## **Exemplo de uso**

1. Segure um bloco ou item.
2. Digite:
/blockframe size=1,0.5 rotate=0,90,0

3. Ajuste o preview usando `pos` ou `step`.
4. Confirme com `/blockframe_set`.
5. Para desfazer, use `/blockframe_undo`.

---

## **Licença**

Este mod é distribuído sob a **MIT License**. Veja LICENSE.txt para detalhes.
