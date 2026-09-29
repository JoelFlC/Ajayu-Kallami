# Prólogo jugable

Abrir `cliente/niveles/pueblo/pueblo.tscn` y ejecutar con F6.
Moverse con WASD: el movimiento nunca se bloquea por la narración.
Acercarse al abuelo (recostado en una cama, a la izquierda de la abuela)
y pulsar E. Después de escucharlo, acercarse a la abuela y pulsar E.
El objetivo superior indica a quién hablar y cuándo se está a distancia.

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

Son interacciones locales de prototipo. El yatiri, recoger la prenda y la
tierra, la misión completa y la sincronización de diálogos por red quedan
pendientes. El HUD conserva datos de demostración, señalados con PRUEBA.

La familia usa figuras provisionales dibujadas por código, con colisiones.
Necesitaremos sprites transparentes del abuelo enfermo recostado en cama
y de la abuela de pie, con estilo pixel art compatible con el pueblo.
No hace falta una ilustración a pantalla completa para este prólogo.
