## T03 — Protocolo cliente-servidor
- Qué se implementó: Se implementó la conexión cliente-servidor autoritativa local usando ENet, con el servidor escuchando en el puerto 9999 y un RPC de prueba para enviar la posición del jugador.
- Archivos: main.gd, compartido/protocolo.gd
- Cómo se probó: Servidor: `& "C:\Users\angel\Informatica\6to Sem\taller de tecnico superior\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --headless --path "C:\Users\angel\Informatica\6to Sem\taller de tecnico superior\JUEGO\ajayu-kallami" --servidor`. Cliente: `& "C:\Users\angel\Informatica\6to Sem\taller de tecnico superior\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --headless --path "C:\Users\angel\Informatica\6to Sem\taller de tecnico superior\JUEGO\ajayu-kallami" --quit-after 120`.
- Resultado: confirmado funcionando por el usuario en su propia máquina (no solo en pruebas aisladas)

## T04 — Base de datos local (JSON) y login
- Qué se implementó: Se implementó una base de datos local en JSON para usuarios, con registro, generación de salt, hash SHA-256 de contraseñas, inicio de sesión y respuestas RPC al cliente.
- Archivos: servidor/basedatos.gd, servidor/auth.gd, cambios en main.gd
- Cómo se probó: Servidor: `& "C:\Users\angel\Informatica\6to Sem\taller de tecnico superior\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --headless --path "C:\Users\angel\Informatica\6to Sem\taller de tecnico superior\JUEGO\ajayu-kallami" --servidor`. Cliente: `& "C:\Users\angel\Informatica\6to Sem\taller de tecnico superior\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --headless --path "C:\Users\angel\Informatica\6to Sem\taller de tecnico superior\JUEGO\ajayu-kallami" --quit-after 180`.
- Resultado: CONFIRMADO. El usuario se verificó directamente en el archivo real del proyecto (C:/Users/angel/AppData/Roaming/Godot/app_userdata/AjayuKallami/ajayu_basedatos.json), revisado con Get-Content por el usuario, no solo por reporte del asistente. Contenido verificado: usuario "angel_test" con id, hash_contraseña, salt y creado_en correctos.

## T05 — Sorteo de lugar y pozo, generación de testimonios
- Qué se implementó: servidor/sorteo.gd, con sortear_partida() que elige lugar_correcto y pozo_jallu_uma al azar (o con semilla fija) y genera los testimonios de pastora, comunario y niño_pastor.
- Archivos: servidor/sorteo.gd, cambios en main.gd
- Cómo se probó: mismo comando de servidor de siempre, revisando la salida de consola directamente.
- Resultado: CONFIRMADO por el usuario en su propia máquina. Se verificó sorteo aleatorio (candidatos y pozo distintos entre corridas) y prueba de determinismo con semilla fija 12345 (dos corridas dieron el mismo resultado).

## T06 — Verificación del relato de apoyo (Huayna Kallami)
- Qué se hizo: se revisó el texto completo del relato de apoyo narrado por Emilio Kapkique, ya disponible desde el inicio del proyecto.
- Resultado: el relato confirma los tres tipos de agua y su efecto ritual (chhijchi uma -> granizo, jallu uma -> lluvia, juyphi uma -> helada), pero no aporta descriptores sensoriales (color, sonido, temperatura, vegetación, olor). Los descriptores inventados por el equipo, ya declarados como tales en la sección 2.2 del GDD, se mantienen sin cambios.
- Estado: CONFIRMADO, sin acción de código requerida.

## Cambio de arquitectura — de 3D con eje bloqueado, de vuelta a 2D real
Se volvió a 2D porque los tilesets isométricos conseguidos corresponden al sistema nativo de Godot basado en TileMapLayer/TileSet 2D. En la prueba 3D hubo problemas de escala (`pixel_size`) y de texturizado: AtlasTexture repetía sobre toda la imagen fuente en vez de limitarse correctamente a la región recortada.

## T07 (versión final) — Personaje 2D con sprites reales y mapa con tileset isométrico
- Qué se implementó: `cliente/jugador.tscn` contiene un `CharacterBody2D`, colisión rectangular, `AnimatedSprite2D` con filtro Nearest y cámara 2D. Sus animaciones actuales son `idle` y `caminar`, usando los cinco sprites reales en el orden solicitado. `cliente/jugador.gd` implementa movimiento con combinación de teclas WASD mediante `Input.get_vector`, animación idle/caminar y volteo horizontal. `cliente/mapa_prueba_2d.tscn` usa varias capas `TileMapLayer` (`background`, `background2`, `foreground2`, `foreground` y `detalles`) con atlas reales de los tiles.
- Archivos: `cliente/jugador.tscn`, `cliente/jugador.gd`, `cliente/mapa_prueba_2d.tscn`, `cliente/sprites/caminante/idle.png`, `paso_der_1.png`, `paso_der_2.png`, `paso_izq_1.png`, `paso_izq_2.png`, `cliente/sprites/tiles_raw/TilesetField.png`, `TilesetFloor.png`, `TilesetElement.png`, `TilesetHouse.png` y `TilesetNature.png`.
- Assets de arte usados: sprites del personaje (generados con IA, 6 poses: idle, paso derecho x2, paso izquierdo x2); actualmente las animaciones conectan cinco cuadros y también existe `idle_vela.png`, sin estar conectado a las animaciones. Tiles de `TilesetField.png` (licencia CC0, conseguidos en internet, sin atribución obligatoria pero se dará crédito si se identifica la fuente).
- Cómo se probó: F6 sobre `cliente/mapa_prueba_2d.tscn`, movimiento con WASD y revisión visual directa en la máquina del usuario.
- Resultado: CONFIRMADO por el usuario en su propia máquina.
- Verificación adicional: el nodo `foreground` tiene un `TileSet` embebido con `physics_layer_0` y polígonos de colisión para sus tiles. No existe actualmente un archivo externo `.tres`, ni se encontró una configuración nativa explícita de forma/layout isométrico en el `TileSet`; el mapa sí es 2D y usa `TileMapLayer` con tiles reales. El proyecto sigue configurando `res://main.tscn` como escena principal, por lo que el mapa se prueba manualmente con F6.

## Estado actual del proyecto (checkpoint de fin de sesión)
- T01: no hay una entrada T01 ni evidencia suficiente en los archivos o commits actuales para confirmar su alcance; queda pendiente de reconstrucción/verificación.
- T02: no hay una entrada T02 ni evidencia suficiente en los archivos o commits actuales para confirmar su alcance; queda pendiente de reconstrucción/verificación.
- T03: protocolo cliente-servidor con ENet y envío de posiciones mediante `Vector2`, documentado como confirmado por el usuario.
- T04: base de datos JSON local, registro/login, salt y hash SHA-256 en `servidor/basedatos.gd` y `servidor/auth.gd`; el usuario verificó el archivo real de datos. Confirmado.
- T05: `servidor/sorteo.gd` con sorteo de lugar/pozo, semilla fija y testimonios; determinismo y sorteo aleatorio confirmados por el usuario.
- T06: relato de apoyo de Huayna Kallami revisado; confirma los tres tipos de agua y no agrega descriptores sensoriales verificables. Confirmado, sin acción de código.
- T07: existe un personaje 2D jugable con sprites y animaciones reales, y un mapa 2D con capas `TileMapLayer`, atlas reales y colisiones en `foreground`. La prueba visual con F6 y WASD fue confirmada por el usuario. Como discrepancias pendientes, el script actual usa `VELOCIDAD = 150.0` y movimiento 2D directo normalizado; no contiene la fórmula de transformación isométrica pedida originalmente. Tampoco se encontró configuración nativa isométrica explícita en el `TileSet`.
- T08: no se encontró implementación ni evidencia verificable en el repositorio actual; pendiente.
- T09: no se encontró implementación ni evidencia verificable en el repositorio actual; pendiente.
- T10: no se encontró implementación ni evidencia verificable en el repositorio actual; pendiente.
