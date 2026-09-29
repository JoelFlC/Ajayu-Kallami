# Cerro Kallami completo como escenario de prueba

Abrir `cliente/niveles/cerro/cerro_prologo.tscn` y ejecutar con F6.
WASD mueve al abuelo; combinar teclas permite caminar en diagonal.
El prólogo se activa automáticamente al entrar al Claro del cerro.
No requiere servidor. Se conserva el nombre de la escena para no romper
referencias, aunque ahora contiene el recorrido físico completo del cerro.

## Prólogo: el abuelo pierde su ajayu

Seguir el sendero desde Inicio hasta el marcador Claro del cerro, en
coordenadas locales (568,72). Su Area2D de 48x40 detecta al abuelo real.
No hace falta pulsar E ni abrir la antigua escena aislada de prueba.

Se detiene el movimiento, aparece la Ñanqha con sus sprites y se reproducen
el susto, la caída y la separación del ajayu. La narración ocupa el panel
inferior. La iluminación usa AmbienteAtardecer existente; la cámara no se
reemplaza ni se cambian sus límites o zoom. Los rótulos de trabajo y la
guía del mapa se ocultan durante la secuencia.

Al terminar, el abuelo queda tendido e inmóvil. R reinicia el prólogo:
restaura sus sprites de caminata, controles, iluminación y rótulos, y lo
devuelve a Inicio. No se permite reiniciar mientras se reproduce el susto.
Para recorrer el cerro completo sin este evento, seleccionar CerroPrologo
y desmarcar `evento_susto_habilitado` en el inspector antes de F6.

`cerro_prologo.gd` expone `iniciar_susto() -> bool` para activarlo desde
otro evento, `reiniciar_prologo() -> bool` y la señal `ajayu_perdido`.
La secuencia reutilizable es `cliente/secuencias/susto/evento_susto.tscn`:
recibe el CharacterBody2D con `iniciar(abuelo)` y emite `iniciado` y
`terminado`. No instancia otro abuelo. Los recortes se comparten con la
prueba aislada mediante `hoja_susto.gd`, usando preload de ruta completa.

El claro es un disparador del prólogo, no un candidato conectado al sorteo.
Todavía no se cambia de escena al pueblo ni se inicia la misión del nieto;
la señal deja preparado ese enlace. El aspecto de la Ñanqha, el eco del
ajayu y los textos son adaptaciones visuales/narrativas del juego.

## Recorrido

1. Ladera baja: construcción y vegetación de la versión de Joel, punto de inicio.
2. Ladera media: subida con tres apachetas de piedra, todavía sin interacción ritual.
3. Bifurcación: roquería alta a la izquierda, quebrada media a la derecha.
   Ambas ramas se pueden recorrer en cualquier orden y en ambos sentidos.
4. Paso de la ladera alta: las ramas se unen; tramo expuesto, sin apachetas.
5. Paso del Achachila: ubicación preparada para el guardián, sin bloqueo aún.
6. Meseta: tres pozos con el mismo arte y colisiones, todos accesibles caminando.

Roquería tiene grupos de rocas grandes grises; quebrada tiene rocas pardas,
tierra y un corte lateral del terreno. La subida conserva una franja libre
de obstáculos. Matas, piedras pequeñas y rótulos ayudan a distinguir zonas.

## Edición en Godot

Todos los tiles están guardados en las escenas, no se generan al jugar.
Las celdas son cuadradas de 16x16: no es un TileSet romboidal nativo.
Se reutilizan los PNG existentes sin alterarlos y con filtro Nearest.
Capas principales: Cielo, Pasto, Sendero, Detalles, npcdetalles, DetallesAltos
y Entidades/Rocas. El suelo tiene 4441 celdas; hay 139 rocas en la capa física.

`decoracion_cerro.tscn` contiene la vegetación de la ladera baja.
`hitos_cerro.tscn` contiene pozos, apachetas, nombres de zona y Marker2D
para pastora, comerciante, comunario, niño pastor, Achachila y los tres
puntos de tierra. Estos marcadores son ubicaciones de trabajo, no NPCs
ni objetos recogibles implementados.

Habilitar Hijos editables en las instancias o abrir sus escenas directamente.
Los atlas son `sendero_kallami.tres` y `decoracion_kallami.tres`.
`pozo_escenario.tscn` usa el aro de piedra de TilesetHouse y agua dibujada
con Polygon2D. `apacheta_escenario.tscn` apila piedras de TilesetNature.

## Colisiones y cámara

`BordesTerreno` contiene 276 segmentos fusionados que cierran los bordes
entre suelo y cielo, incluido el corte de la quebrada. No se puede caminar
fuera del terreno. Las rocas, los pozos y las apachetas tienen colisiones.
Las capas de detalles pequeños no tienen física ni navegación.

Límites de Camera2D propios de esta escena, en coordenadas globales:
izquierda -14, arriba -1727, derecha 1010 y abajo 273.
Se conserva el zoom, el movimiento y la velocidad del abuelo (85 u/s).
El script y escena base del abuelo no se modificaron. Durante el susto
se cambian temporalmente las animaciones de esta instancia y se bloquea
su control; R restaura el estado previo.

## Verificación y alcance

Se probaron con input real simulado los tramos de la ladera, la rama de
roquería, la rama de quebrada en ambos sentidos, el paso alto, la meseta y
el desplazamiento entre los tres pozos. También se comprobó que el borde
superior bloquea la salida al cielo y que la cámara alcanza la cima.
Se revisó una captura completa renderizada en Godot.
También se verificó el susto entrando con input simulado, el bloqueo de
WASD, la señal de finalización única, el reinicio con R, la restauración
de animaciones/conexiones y una segunda reproducción completa. Se probó
el modo de recorrido libre y se revisaron capturas de la Ñanqha y del ajayu
en el cerro. La prueba de integración terminó con cero fallos.

Esto completa el escenario físico de prueba, no todas las mecánicas del GDD.
Faltan personajes de misión, diálogos interactivos, recogida de prenda/tierra,
Ñanqha como enemigo con IA,
viento, vela, sistema de caídas, bloqueo ritual del Achachila y selección
de agua. Los bordes bloquean por ahora; no disparan caídas ni quitan ajayu.
Los pozos no revelan cuál es jallu uma. No se tocó el sorteo, el servidor,
el protocolo, el pueblo ni la escena principal. El evento de susto sí está
conectado a ZonaSusto; la transición del prólogo sigue pendiente.

La duración de la partida y el arte final requieren pruebas posteriores
con sus misiones; no se considera validado el presupuesto de tiempo del GDD.
