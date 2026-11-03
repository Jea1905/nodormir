# nodormir

Función de fish que impide que Linux se suspenda mientras un proceso trabaja,
aunque se bloquee la sesión o se apaguen las pantallas.

Pensada para quien tiene su distro configurada para suspenderse cuando no se usa,
pero de vez en cuando necesita dejar algo trabajando (descargas, máquinas virtuales,
Docker...) sin estar pendiente de la suspensión.

**Requisitos:** Linux con systemd y la shell fish.

## Uso

- `nodormir comando` → no se suspende mientras dure ese comando
  (ej: `nodormir sudo pacman -Syu`).
- `nodormir` → no se suspende hasta pulsar Ctrl+C
  (para descargas, máquinas virtuales, Docker...).

Si no se usa, el sistema se suspende con normalidad.

## Instalación automática

Con curl:

```fish
mkdir -p ~/.config/fish/functions
curl -fsSL https://raw.githubusercontent.com/alexis123javier-glitch/nodormir/main/functions/nodormir.fish -o ~/.config/fish/functions/nodormir.fish
```

Con Fisher:

```fish
fisher install alexis123javier-glitch/nodormir
```

Abre una terminal nueva y ya puedes usar `nodormir`.

## Instalación manual

Pega esto en una terminal fish:

```fish
function nodormir --description 'Ejecuta un comando sin que el portátil se suspenda'
    if test (count $argv) -eq 0
        echo "Suspensión bloqueada. Pulsa Ctrl+C para volver a permitirla."
        set argv sleep infinity
    end
    systemd-inhibit --what=sleep:idle:handle-lid-switch --why="$argv" $argv
end
funcsave nodormir
```

## Cómo funciona

- `systemd-inhibit`: avisa al sistema de que NO se suspenda mientras el comando esté funcionando.
- `--what=sleep:idle:handle-lid-switch`: bloquea la suspensión normal, la suspensión
  por inactividad y la suspensión al cerrar la tapa.
- `$argv`: el comando que se escribe detrás de `nodormir`.
- Si no se escribe nada (`count $argv` = 0), usa `sleep infinity` para esperar hasta pulsar Ctrl+C.
- `funcsave`: guarda la función de forma permanente en `~/.config/fish/functions/nodormir.fish`.

Ver la función tal como está guardada:

```fish
functions nodormir
```

## Comprobar que ha funcionado

Ver qué está bloqueando la suspensión en este momento:

```fish
systemd-inhibit --list
```

Comprobar que el sistema no se ha suspendido en los últimos 10 minutos:

```fish
journalctl -b --since "10 min ago" | grep -i -E "suspend|sleep"
```

Si no aparece ninguna suspensión, ha funcionado. Las líneas de powerdevil del tipo
"Sleeping for 100 milliseconds" no cuentan: son del sistema detectando los monitores.
