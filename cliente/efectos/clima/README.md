# Efectos climáticos del desenlace

Los PNG y WAV de `assets/` provienen de Ninja Adventure Asset Pack
(Pixel-boy y AAA), publicado bajo CC0 1.0. Solo se incorporan los recursos
usados por este efecto; los tilesets del paquete ya existen en el proyecto.

- `Rain.png` y `RainOnFloor.png`: lluvia y salpicaduras.
- `Clouds.png`: nubes de la viñeta exterior.
- `Snow.png`: partículas de granizo y escarcha, con velocidades diferentes.
- `Rain.wav`, `Storm.wav` y `Wind2.wav`: ambiente del resultado elegido.

El código de `clima_final.gd` reproduce estos recursos dentro de un área
recortada. En el ritual cubre la viñeta exterior y, al terminar, el pueblo.
