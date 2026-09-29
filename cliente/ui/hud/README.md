# HUD del pueblo

Abrir `cliente/niveles/pueblo/pueblo.tscn` y ejecutar con F6.
El HUD usa la imagen `cliente/sprites/ui/hud_andino.png` con regiones independientes,
filtro Nearest y posiciones adaptadas al viewport base de 480x270.

El nodo HUD es un CanvasLayer. Se puede instanciar `hud.tscn` en otros niveles.
Los datos de demostración muestran 3 puntos de ajayu, 23:45, tres objetos y
objetivos pendientes. El texto PRUEBA distingue estos datos de una partida real.
El reloj de demostración es fijo: el HUD muestra el tiempo recibido; no decide
ni descuenta el tiempo de la partida. Desactivar `modo_demostracion` al conectarlo
al estado autorizado de la partida.

## Actualización desde el juego

- `actualizar_ajayu(valor)` limita la visualización entre 0 y 4.
- `actualizar_tiempo(segundos)` formatea minutos y segundos y señala menos de 5 minutos.
- `actualizar_objetivo_ajayu(completado)` y `actualizar_objetivo_lluvia(completado)`.
- `actualizar_vela(encendida)` cambia el indicador, no la iluminación del mapa.
- `actualizar_inventario(objetos)` acepta hasta 6 nombres o diccionarios con
  `id`, `nombre` e `icono` opcional de tipo Texture2D.
- `seleccionar_espacio(indice)` acepta índices de 0 a 5. También se selecciona
  con las teclas 1 a 6 o un clic. Emite `espacio_seleccionado(indice)`;
  no usa ni consume el objeto.
- `mostrar_mensaje(texto, duracion = 2.0)`; duración 0 conserva el mensaje.
- `ocultar_mensaje()`.
- `reservar_panel_narrativo(reservado)` oculta inventario, vela y mensajes
  inferiores mientras se narra; mantiene los indicadores superiores y sus datos.

## Arte pendiente

La prenda y la tierra usan los iconos incluidos en la imagen. La ofrenda usa
un marcador provisional, porque el dibujo original representa una mesa de
madera. Se necesitan iconos separados de las mesas del Ñanqha, de la Pachamama
y del Achachila. Para una vela completamente apagada se necesita también un
icono sin llama: por ahora se oscurece el que está incluido en la imagen.
