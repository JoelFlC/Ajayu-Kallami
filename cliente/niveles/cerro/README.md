# Sendero del prólogo del Kallami

Abrir `cliente/niveles/cerro/cerro_prologo.tscn` y ejecutar con F6.
WASD mueve al abuelo; combina teclas para caminar en diagonal.
Seguir el sendero de tierra desde el extremo inferior izquierdo hasta el
claro del extremo superior derecho. No requiere servidor.

## Mapa editable

Escena 2D de 640x448 píxeles, en celdas cuadradas de 16x16, igual que los
atlas existentes del mapa de prueba (no un TileSet romboidal nativo).
Capas: Pasto, Sendero, Detalles y Entidades/Rocas. Se pintaron celdas
persistentes: el mapa aparece en el editor y no depende de generación al jugar.
El recurso compartido es `cliente/recursos/tilesets/sendero_kallami.tres`.
Reutiliza los PNG originales TilesetField y TilesetNature sin modificarlos.
Las rocas tienen polígonos de colisión. El perímetro limita el mapa.
Hay ordenamiento Y entre las rocas y el abuelo.
CanvasModulate aplica un ambiente de atardecer ajustable en el inspector;
no sustituye el sistema de iluminación nocturna de la partida.

## Personaje y límites del paso

`cliente/personajes/npc/abuelo.tscn` y `abuelo.gd` usan las tres hojas
existentes, con recortes según sus bandas reales. Los cuadros de cada dirección
comparten un lienzo transparente y una escala fija, alineados por el sombrero
para evitar vibraciones al cambiar de frame. Altura del lienzo: 27 píxeles;
el movimiento natural de piernas y brazos se conserva sin deformar los PNG.
Son 16 frames por dirección, a 8 fps; idle usa el primer frame.
Velocidad propia del abuelo: 85 unidades/segundo. No modifica al nieto.
Colisión en los pies y cámara con límites del mapa.

Los Marker2D Inicio y ZonaSusto preparan la siguiente tarea. No hay evento
de susto, caída, pérdida de ajayu ni transición al pueblo todavía.
Tampoco cambia el mapa de prueba, el pueblo, main ni el protocolo de red.
Este tramo se podrá instanciar o ampliar para construir el cerro definitivo,
manteniendo separado el recorrido introductorio del puzzle de la partida.
