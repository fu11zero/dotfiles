#!/usr/bin/env bash

# Получаем список аудио-выходов (Sinks)
# Формат: "ID: Название устройства"
devices=$(wpctl status | grep -E -A 30 "^Audio$" | grep -B 30 " └─ Streams:" | grep -A 5 "Sinks:" | grep -B 5 " ├─ Sources:" | grep -Po '(?<=|)[ *]\d+\..+(?=\[.*])')

# Вызываем меню выбора (здесь используется wofi, адаптируйте под hyprlauncher)
selected=$(echo "$devices" | hyprlauncher -o "UI:window_size = 100 600" --dmenu)
echo $selected

if [ -n "$selected" ]; then
    # Извлекаем ID из выбранной строки
    node_id=$(echo "$selected" | cut -d'.' -f1)
    # Устанавливаем устройство по умолчанию
    wpctl set-default "$node_id"
fi
