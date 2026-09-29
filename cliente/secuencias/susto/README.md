# Prueba visual de susto y separación del ajayu

Abrir `cliente/secuencias/susto/prueba_susto.tscn` y presionar F6.
Enter, E o Espacio inicia la secuencia. Al terminar, R la reinicia.
En esta escena aislada se controla la reproducción, no el movimiento con WASD.

La versión integrada se prueba con F6 sobre
`cliente/niveles/cerro/cerro_prologo.tscn`: WASD hasta Claro del cerro,
activación automática y R al terminar para volver a Inicio.

## Qué muestra

La Ñanqha aparece usando la hoja de sprites entregada por el usuario,
una figura oscura con pequeños ojos claros. El abuelo se asusta,
cae y queda tendido. Un eco luminoso de su silueta se separa del cuerpo,
asciende con destellos y desaparece; la Ñanqha se desvanece.
La narración aparece en un panel inferior.

Son una adaptación visual y textos originales del juego, no descripciones
visuales ni citas literales del relato. No se afirma que la Ñanqha tenga
este aspecto ni que el ajayu sea una luz de este color en la tradición.

## Hoja del abuelo

`cliente/sprites/npc/abuelo/susto_caida.png` mide 1254x1254 y tiene alpha.
Las filas reales no forman una cuadrícula uniforme. El script usa bandas
medidas: y=49..375, 411..710, 795..955 y 1081..1213, con columnas propias
para cada fila y cuatro píxeles de margen de seguridad.
Se recortan sin alterar el PNG y se apoyan en un lienzo virtual común
de 320x334. La escala es fija: 27/326, no se recalcula por pose.
Animaciones: susto (4 cuadros a 7 fps), caída (8 a 10 fps), tendido
(4 a 4 fps). Las dos primeras no hacen loop; tendido sí.
Si se reemplaza la hoja por otra, hay que volver a verificar sus bandas.

## Efectos reutilizables

- `cliente/efectos/ajayu/ajayu.tscn`: `separar_desde(sprite, destino_global,
  duracion)` copia la pose de un AnimatedSprite2D, aplica el shader del eco,
  añade halo/destellos y emite `separacion_terminada` al finalizar.
  `reiniciar()` cancela el tween y oculta el efecto.
- `cliente/personajes/enemigos/nanqha.tscn`: AnimatedSprite2D con filtro
  Nearest. API: `aparecer()` y `desvanecer()`; todavía no tiene IA ni
  colisiones. Reemplaza la sombra provisional dibujada con polígonos.

## Hoja de la Ñanqha

`cliente/sprites/enemigos/nanqha/aparicion_idle.png` mide 1254x1254,
tiene transparencia y 16 cuadros. Las bandas reales son y=0..336,
336..636, 636..931 y 931..1254; las columnas se delimitan en
x=0, 314, 627, 941 y 1254. No se supone una cuadrícula uniforme.

El script recorta las siluetas sin modificar el PNG original. Alinea
horizontalmente la parte superior de cada figura y apoya los cuadros en
un lienzo virtual común de 256x294. La escala fija es 40/288; no se
recalcula por cuadro, para evitar cambios artificiales de tamaño.

Los primeros 8 cuadros forman `aparicion` (8 fps, sin loop) y los últimos
8 forman `idle` (6 fps, con loop). La desaparición reproduce la aparición
al revés. Su duración se ajusta con el argumento de cada llamada.
Si se reemplaza esta hoja por otra, hay que volver a verificar los recortes.

Los efectos no requieren HDR ni glow del proyecto. El abuelo real conserva
su script y escena; los ajustes de reproducción solo afectan esta instancia
de prueba. Todos los recursos usan rutas completas; no se usa class_name.

## Evento reutilizable en el cerro

`evento_susto.tscn` y `evento_susto.gd` reciben al abuelo existente con
`iniciar(abuelo) -> bool`. Rechazan otra activación mientras corren o cuando
ya terminaron. Emiten `iniciado` y `terminado`; `reiniciar() -> bool` restaura
el estado guardado del personaje, pero no cambia su posición. El mapa es
quien lo devuelve a Inicio. No se permite reiniciar durante la reproducción.

La secuencia guarda/restaura SpriteFrames, animación, escala, posición local,
volteos, velocidad de animación y estado de control/procesamiento físico.
Desconecta temporalmente el reajuste de caminata para no alterar la escala
de la caída y lo reconecta una sola vez. `hoja_susto.gd` comparte los recortes
entre el evento y la antigua prueba aislada.

`ambiente_externo` permite apuntar al CanvasModulate existente del mapa;
en el cerro es `../AmbienteAtardecer`. Solo se crea un modulador propio si
no se proporciona uno externo; nunca se superponen dos. Al reiniciar se
recupera el color original, no un blanco impuesto.
La escena no agrega otra cámara ni otro personaje.

## Alcance y prueba

Se verificaron en Godot los 16 recortes, su lienzo común, la aparición,
el idle y la desaparición inversa durante dos reproducciones. También se
probó la secuencia completa dos veces y se revisaron capturas de la Ñanqha
formada junto al abuelo y del ajayu elevándose tras la caída. La prueba
gráfica terminó sin errores. No se modifica el servidor ni el protocolo.

El evento ya está conectado a ZonaSusto del cerro mediante un Area2D.
Se verificaron dos reproducciones completas en el mapa, inicio automático
caminando, R, restauración de controles/conexiones y modo recorrido libre.
También se revisaron capturas renderizadas sin rótulos superpuestos.
La función `iniciar_susto()` del mapa permite activarlo desde otro evento;
su señal `ajayu_perdido` deja preparado el siguiente paso narrativo.

No está conectado al HUD, al sorteo ni a una transición al pueblo. El claro
no determina cuál es el candidato correcto de la partida. El siguiente paso
es enlazar el final del prólogo con el pueblo y la misión del nieto.
