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
