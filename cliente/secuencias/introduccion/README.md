# Prólogo jugable

Para probar el recorrido con entrada y salida de la casa, abrir
`cliente/juego_local.tscn` y ejecutar con F6. Abrir
`cliente/niveles/pueblo/pueblo.tscn` directamente prueba solo los diálogos:
la puerta interactiva pertenece a la misión del recorrido local.
Moverse con WASD: el movimiento nunca se bloquea por la narración.
Se empieza dentro de su casa. Acercarse al abuelo (recostado en una cama,
a la izquierda de la abuela)
y pulsar E. Después de escucharlo, acercarse a la abuela y pulsar E.
El objetivo superior indica a quién hablar y cuándo se está a distancia.
Después de conversar, E junto a la puerta lleva al exterior del pueblo;
la misma tecla junto a la puerta de la casa permite volver a entrar.

Los textos aparecen en un panel inferior con escritura progresiva.
E o Enter completa el texto; la siguiente pulsación avanza la conversación.
Esc cierra sin darla por completada: se puede volver a hablar con el NPC.
La narración inicial se cierra sola cinco segundos después de mostrarse entera.
Mientras hay texto, solo se ocultan los elementos inferiores del HUD para
evitar superposición; no se cambian sus datos ni se pausa el juego.

## Base documental y adaptación

Referencia aportada por el usuario: «Ritos y tipos de agua en el cerro Kallami»,
narrado por Ernesto Marqués Chávez, Pucarani, Ikiaka, julio de 2006,
Archivo Oral de la Carrera de Literatura, UMSA.

El susto, la Ñanqha, la consulta al yatiri, la prenda y la tierra del lugar
se apoyan en el relato. Abuelo, abuela, nieto y diálogos son una adaptación
del juego, no citas. El encargo del agua de lluvia es distinto del ajayu.
No se revela el lugar sorteado ni se asignan recompensas o inventario real.

## Alcance y arte pendiente

Esta escena aislada sigue siendo una prueba de diálogos. El flujo local en
`cliente/juego_local.tscn` conecta un yatiri provisional, prenda, tierra y
pozos con indicios sensoriales y bitácora, y un llamado final en tres actos
con arte provisional; todavía faltan arte definitivo y efectos de cierre.
El juego se desarrolla para un solo jugador. Al abrir
solo `pueblo.tscn`, el HUD conserva datos de demostración.

El abuelo usa la hoja de susto/caída ya existente y aparece recostado en una
cama dentro de `cliente/niveles/pueblo/casa_abuelo.tscn`; la abuela usa su
sprite transparente. La cama usa `tileset_bed.png` y los muebles cercanos
usan `tileset_camp.png`; el piso terroso conserva el tileset del pueblo.
Se mantienen las colisiones de cama y muebles.
No hace falta una ilustración a pantalla completa para este prólogo.
