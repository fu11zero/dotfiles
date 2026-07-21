#!/usr/bin/env bash

cameras=$(~/.local/bin/camera)

# Вызываем меню выбора (здесь используется wofi, адаптируйте под hyprlauncher)
# selected=$(echo "$cameras" | hyprlauncher -o "UI:window_size = 100 600" --dmenu)
selected=$(echo "$cameras" | wofi -o "UI:window_size = 100 600" --dmenu)
echo $selected

if [ -n "$selected" ]; then
    # Устанавливаем устройство по умолчанию
    ~/.local/bin/camera "$selected"
fi
