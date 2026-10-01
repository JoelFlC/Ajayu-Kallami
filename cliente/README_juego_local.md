# Recorrido local jugable (sin servidor)

Abrir `cliente/juego_local.tscn` en Godot y pulsar F6. Con WASD se camina;
con E se interactúa. El flujo usa el sorteo existente **solo en esta prueba
local**: el lugar del susto, la tierra correcta y el pozo con jallu uma
coinciden en la misma partida. Este recorrido es para un solo jugador;
`main.tscn` conserva pruebas técnicas anteriores, pero no se usa aquí.

1. Caminar con el abuelo desde la base del cerro al lugar del susto indicado
   en pantalla. Es uno de los tres candidatos: roquería alta, quebrada media
   o paso alto. Tras la caída y la separación del ajayu, esperar 2,5 segundos.
   Si querés continuar sin recorrer el prólogo, pulsá Enter antes de activar
   el susto: pasarás directamente al pueblo. Esta opción solo aparece en
   `juego_local.tscn`; no altera la prueba aislada del cerro.
2. Al llegar al pueblo, apareces dentro de la casa del abuelo. Acércate a él
   y a la abuela y sigue la introducción con E o Enter. Sal de la casa con E
   junto a la puerta, habla con el yatiri (figura provisional en la zona
   central) y vuelve a entrar en la casa para tomar una prenda junto al
   abuelo con E. Al regresar del cerro, apareces fuera de la casa; el abuelo
   continúa dentro.
3. Ir al letrero «Camino al cerro» y pulsar E. En el cerro, E permite oír
   testimonios de pastora, comunario y niño pastor; también recoge tierra
   en el lugar correcto. El niño pastor es el testigo fiable del sorteo.
   El perro acompaña al personaje en el pueblo y el cerro. Si te detienes,
   puede sentarse, echarse, dormir, ladrar, estirarse, rascarse o lamerse.
   Si queda lejos, corre para alcanzarte. Tiene una colisión pequeña a la altura de las patas: rodea los obstáculos
   con colisión del mapa y no bloquea al jugador. Los adornos sin colisión
   siguen siendo atravesables.
4. Subir a los tres pozos. E permite examinar color, sonido, aire, vegetación
   y olor. En la ficha, R abre el menú para anotar descriptores: 1-5 elige
   un rasgo, flechas izquierda/derecha cambian la opción y Enter guarda.
   B abre la bitácora; allí 1-3 elige un pozo y Y consulta la lectura del
   yatiri. Las lecturas pueden ser claras, dudosas o contradictorias según
   lo que se haya anotado. E o Esc cierra los paneles. Al examinar otra vez
   un pozo, C llena el cántaro con esa agua. Las notas se conservan al
   regresar del pueblo al cerro durante la misma partida.
5. Regresar a la base del cerro y pulsar E para volver al pueblo. El agua
   elegida no se confirma todavía. Si querés revisarla antes del cierre,
   podés volver al cerro por el camino de salida; se conservan tierra y
   notas de la bitácora.
6. Pulsar E ante el yatiri para entrar en la casa e iniciar el ritual.
   Primer acto: E o Enter coloca la prenda. Segundo acto: armá la miniatura
   sin elegir un topónimo de una lista; 1-3 selecciona terreno, piedras o
   vegetación, flechas izquierda/derecha cambian cada pieza y Enter la
   confirma cuando las tres están elegidas. Tercer acto: E lava la tierra
   con agua del cántaro y E la aplica al abuelo. Otra E continúa el cambio
   ritual con el perro y muestra el resultado. E cierra la escena.

El yatiri, los testigos y los puntos de tierra son figuras provisionales
dibujadas por código. Harán falta sprites definitivos para estos NPCs,
especialmente el yatiri. Los indicios sensoriales son una creación del
equipo, no descripciones del testimonio oral. El menú y las lecturas del
yatiri ya funcionan para los pozos. El llamado final tiene tres actos
jugables en un interior provisional: prenda, miniatura y lavado/aplicación
de la tierra. La miniatura y el pozo se evalúan por separado. El desenlace
muestra una viñeta exterior y lluvia, granizo o helada según el pozo elegido,
con sonido ambiental del paquete CC0 Ninja Adventure. El clima sigue visible
al regresar al pueblo, por debajo del HUD. Todavía faltan consecuencias
jugables para granizo y helada y una animación propia del abuelo. El perro ya usa
las hojas de sprites aportadas por el usuario (cuadros de 100×100) y se
sienta al concluir el llamado; su participación ritual aún no tiene sonido
ni secuencia animada definitiva. Faltan el tutorial obligatorio del GDD,
las señas de lugar de caída para deducir cada pieza sin depender solo de
testimonios, el bloqueo del Achachila y el guardado entre sesiones.
El reloj del HUD se muestra fijo; no hay cuenta regresiva.

La prueba automatizada de los tres posibles pozos está en
`tests/agua_indicios_verificar.gd` y se ejecuta con Godot usando
`--headless --path . --script res://tests/agua_indicios_verificar.gd`.
El ritual se comprueba con
`--headless --path . --script res://tests/ritual_final_verificar.gd`.
Las animaciones, las acciones en reposo y la ruta del perro ante una pared se comprueban con
`--headless --path . --script res://tests/perro_verificar.gd`.

Para probar solo el susto fijo y poder repetirlo con R, usar F6 en
`cliente/niveles/cerro/cerro_prologo.tscn`. Para probar solo los diálogos
existentes del pueblo, usar F6 en `cliente/niveles/pueblo/pueblo.tscn`.
