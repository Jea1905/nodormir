function nodormir --description 'Ejecuta un comando sin que el portátil se suspenda'
    if test (count $argv) -eq 0
        echo "Suspensión bloqueada. Pulsa Ctrl+C para volver a permitirla."
        set argv sleep infinity
    end
    systemd-inhibit --what=sleep:idle:handle-lid-switch --why="$argv" -- $argv
end
