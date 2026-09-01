#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GITLAB_HOST=gitlab.unitcode.ru
PROJECTS_DIR="$HOME/Projects/unitcode"
CACHE_FILE="$HOME/.cache/hypr-gitlab-projects-${GITLAB_HOST}.json"
LOCK_FILE="$CACHE_FILE.lock"
CACHE_TTL=$((1 * 3600)) # проекты меняются редко — держим кэш до 6 часов

ICON_CACHE_DIR="$HOME/.cache/hypr-gitlab-icons"

# Статичные иконки — заранее растеризованные в PNG (icons/*.png), а не .svg
# из темы Adwaita напрямую. wofi не кэширует и не переиспользует decode между
# строками меню: если отдать .svg, librsvg рендерит его заново на КАЖДОЙ из
# ~500 строк — это и есть основная причина заметной задержки открытия меню
# (проверено: даже после уменьшения размера аватарок задержка почти не менялась,
# пока не убрали рендер SVG на лету). Обычный PNG декодируется на порядок быстрее.
ICON_GROUP="$SCRIPT_DIR/icons/group.png"       # группа проектов, нет лого
ICON_CLONED="$SCRIPT_DIR/icons/cloned.png"     # уже склонирован, нет своей иконки
ICON_REMOTE="$SCRIPT_DIR/icons/remote.png"     # ещё нет локально, нет своей иконки

# Заготовки для типовых ролей — своей иконки в GitLab у проекта чаще всего
# нет, а по имени backend/frontend почти всегда понятно, что внутри.
ICON_FRONTEND="$SCRIPT_DIR/icons/frontend-template.png"
ICON_BACKEND="$SCRIPT_DIR/icons/backend-template.png"

fetch_projects() {
    local page=1 out
    while :; do
        out=$(GITLAB_HOST="$GITLAB_HOST" glab repo list --member -F json --per-page 100 --page "$page" 2>/dev/null) || break
        [ -z "$out" ] || [ "$out" = "[]" ] && break
        echo "$out"
        page=$((page + 1))
    done
}

cache_is_fresh() {
    [ -f "$CACHE_FILE" ] || return 1
    local age
    age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
    [ "$age" -lt "$CACHE_TTL" ]
}

# Детерминированный локальный путь для аватарки по её avatar_url из GitLab
# (используется как ключ кэша, а не реально скачивается по этому адресу —
# см. почему ниже). Чистая функция без обращения к сети/диску.
icon_cache_path() {
    local avatar_url="$1" no_query ext hash
    no_query="${avatar_url%%\?*}"
    ext="${no_query##*.}"
    [[ "$ext" =~ ^[A-Za-z0-9]{1,5}$ ]] || ext="img"
    hash=$(printf '%s' "$avatar_url" | sha1sum | cut -c1-16)
    printf '%s/%s.%s' "$ICON_CACHE_DIR" "$hash" "$ext"
}

# Реальные аватарки из GitLab бывают огромными (видели логотип группы
# 4168x1874), а в меню показываются на ~32px (wofi image_size). Без уменьшения
# wofi decode'ит полноразмерную картинку на КАЖДОЙ строке, где она встречается
# (а логотип группы может использоваться на десятках дочерних проектов) — это
# и есть причина заметной задержки при открытии. Ужимаем один раз при
# скачивании, а не при каждом открытии меню.
resize_icon_in_place() {
    local f="$1"
    command -v convert >/dev/null 2>&1 || return 0
    convert "$f" -resize '128x128>' -strip "$f.resized" 2>/dev/null \
        && mv "$f.resized" "$f" || rm -f "$f.resized"
}

# avatar_url из API отдаёт прямую ссылку на /uploads/-/system/..., но этот
# путь на self-hosted инстансе требует браузерной сессии — с PRIVATE-TOKEN
# отдаёт 401 (проверено). Зато GET /api/v4/<projects|groups>/:id/avatar
# отдаёт те же байты и токен принимает нормально, поэтому качаем через него,
# а avatar_url используем только для имени файла в кэше (icon_cache_path).
fetch_icon() {
    local avatar_url="$1" fetch_url="$2" dest
    [ -n "${GITLAB_TOKEN:-}" ] || return 1
    dest=$(icon_cache_path "$avatar_url")
    [ -s "$dest" ] && return 0
    curl -sSfL --max-time 5 -H "PRIVATE-TOKEN: $GITLAB_TOKEN" -o "$dest.tmp" "$fetch_url" 2>/dev/null \
        && [ -s "$dest.tmp" ] && mv "$dest.tmp" "$dest" || { rm -f "$dest.tmp"; return 1; }
    resize_icon_in_place "$dest"
}

# Скачивает недостающие аватарки проектов и групп (уже скачанные — пропускает,
# так что после первого прогона стоит копейки). Вызывается и синхронно
# (первый запуск), и в фоне (обновление устаревшего кэша).
prefetch_icons() {
    [ -n "${GITLAB_TOKEN:-}" ] || return 0
    mkdir -p "$ICON_CACHE_DIR"
    local rows
    rows=$(jq -r '
        ( [.[] | select((.avatar_url // "") != "") | {kind:"projects", id, avatar_url}]
        + [.[] | .namespace | select((.avatar_url // "") != "") | {kind:"groups", id, avatar_url}] )
        | unique_by([.kind, .id])
        | .[] | [.kind, (.id|tostring), .avatar_url] | @tsv
    ' "$CACHE_FILE")
    # <<< вместо пайпа: цикл выполняется в текущем шелле, а не в подшелле,
    # иначе итоговый wait не дождётся фоновых fetch_icon из подшелла.
    while IFS=$'\t' read -r kind id avatar_url; do
        fetch_icon "$avatar_url" "https://${GITLAB_HOST}/api/v4/${kind}/${id}/avatar" &
        # не долбим GitLab пачкой запросов разом
        while [ "$(jobs -rp | wc -l)" -ge 4 ]; do wait -n; done
    done <<< "$rows"
    wait
}

# Пишет свежий список в CACHE_FILE и докачивает новые аватарки. Используется
# и синхронно (когда кэша ещё нет вообще), и в фоне (когда кэш устарел).
refresh_cache() {
    mkdir -p "$(dirname "$CACHE_FILE")"
    local tmp
    tmp=$(mktemp)
    if fetch_projects | jq -s 'add // []' >"$tmp" && [ -s "$tmp" ] && [ "$(cat "$tmp")" != "null" ]; then
        mv "$tmp" "$CACHE_FILE"
        prefetch_icons
    else
        rm -f "$tmp"
    fi
}

if [ ! -f "$CACHE_FILE" ]; then
    # Самый первый запуск: кэша ещё нет, ждать неизбежно.
    refresh_cache
elif ! cache_is_fresh; then
    # Кэш устарел, но есть чем открыться прямо сейчас — используем его,
    # а обновление на будущее тихо запускаем в фоне (flock не даёт запустить
    # обновление параллельно, если предыдущее ещё не закончилось).
    ( flock -n 9 && refresh_cache ) 9>"$LOCK_FILE" &
    disown 2>/dev/null || true
fi

[ -f "$CACHE_FILE" ] || { notify-send "GitLab picker" "Не удалось получить список проектов ($GITLAB_HOST)"; exit 1; }

# path \t собственная аватарка проекта \t аватарка его группы — одним jq-проходом,
# чтобы не дёргать jq по разу на проект.
projects_tsv=$(jq -r '
    [.[] | [.path_with_namespace, (.avatar_url // ""), (.namespace.avatar_url // "")]]
    | unique_by(.[0]) | sort_by(.[0]) | .[] | @tsv
' "$CACHE_FILE")

projects=$(cut -f1 <<< "$projects_tsv")

# Группа = путь-предок, под которым лежит 2+ проекта напрямую
# (apc/monitoring/backend, apc/monitoring/frontend -> группа apc/monitoring).
# Выбор группы открывает разом все проекты внутри неё. group_avatar берётся
# из аватарки namespace любого дочернего проекта — она одна и та же у всех.
declare -A own_avatar=() group_avatar=() group_count=()
while IFS=$'\t' read -r path oav nav; do
    own_avatar["$path"]="$oav"
    if [[ "$path" == */* ]]; then
        parent="${path%/*}"
        group_count["$parent"]=$(( ${group_count["$parent"]:-0} + 1 ))
        group_avatar["$parent"]="$nav"
    fi
done <<< "$projects_tsv"

# Готовая (докачанная) картинка по avatar_url, если она реально есть на диске.
downloaded_icon() {
    local avatar_url="$1" cached
    [ -n "$avatar_url" ] || return 1
    cached=$(icon_cache_path "$avatar_url")
    [ -s "$cached" ] || return 1
    printf '%s' "$cached"
}

role_template_icon() {
    local last="${1##*/}"
    case "$last" in
        frontend|front|fe|web|ui|client) printf '%s' "$ICON_FRONTEND" ;;
        backend|back|be|api|server) printf '%s' "$ICON_BACKEND" ;;
        *) return 1 ;;
    esac
}

# Иконка проекта: своя аватарка -> шаблон по роли в имени -> логотип группы
# (общий для всех проектов компании) -> обычная папка по статусу клонирования.
project_icon() {
    local path="$1" local_dir="$2" parent icon
    icon=$(downloaded_icon "${own_avatar[$path]:-}") && { printf '%s' "$icon"; return; }
    role_template_icon "$path" && return
    parent="${path%/*}"
    icon=$(downloaded_icon "${group_avatar[$parent]:-}") && { printf '%s' "$icon"; return; }
    if [ -d "$local_dir" ]; then printf '%s' "$ICON_CLONED"; else printf '%s' "$ICON_REMOTE"; fi
}

group_icon() {
    local g="$1" icon
    icon=$(downloaded_icon "${group_avatar[$g]:-}") && { printf '%s' "$icon"; return; }
    printf '%s' "$ICON_GROUP"
}

# Дешёвая (без сети) подсказка стека для уже склонированных проектов — просто
# смотрим на маркер-файл в корне репозитория.
local_stack_badge() {
    local dir="$1"
    [ -f "$dir/go.mod" ] && { printf 'go'; return; }
    [ -f "$dir/Cargo.toml" ] && { printf 'rust'; return; }
    [ -f "$dir/package.json" ] && { printf 'node'; return; }
    [ -f "$dir/composer.json" ] && { printf 'php'; return; }
    { [ -f "$dir/pyproject.toml" ] || [ -f "$dir/requirements.txt" ]; } && { printf 'python'; return; }
    { [ -f "$dir/pom.xml" ] || [ -f "$dir/build.gradle" ] || [ -f "$dir/build.gradle.kts" ]; } && { printf 'java'; return; }
    return 1
}

# Формат строки для wofi --allow-images: "img:<путь-к-иконке>:text:<подпись>".
# Проверено вживую (скриншотами): --sort-order alphabetical сортирует именно
# по <подпись>, путь к иконке на порядок не влияет.
build_menu() {
    {
        for g in "${!group_count[@]}"; do
            [ "${group_count[$g]}" -ge 2 ] || continue
            printf 'img:%s:text:%s ▸ (%d проектов)\n' "$(group_icon "$g")" "$g" "${group_count[$g]}"
        done

        while IFS= read -r path; do
            rel="${path#unitcode/}"
            local_dir="$PROJECTS_DIR/$rel"
            icon=$(project_icon "$path" "$local_dir")
            if [ -d "$local_dir" ]; then
                badge=$(local_stack_badge "$local_dir") && label="$path [$badge]" || label="$path"
            else
                label="$path "
            fi
            printf 'img:%s:text:%s\n' "$icon" "$label"
        done <<< "$projects"
    } | sort -t: -k4
}

# Открывает проект в отдельном окне ghostty: если уже склонирован — сразу nvim;
# если нет — клонирует прямо в окне (виден прогресс/ошибка), затем nvim.
open_project() {
    local project="$1" rel local_dir clone_url cmd
    rel="${project#unitcode/}"
    local_dir="$PROJECTS_DIR/$rel"
    mkdir -p "$(dirname "$local_dir")"

    if [ -d "$local_dir" ]; then
        ghostty --working-directory="$local_dir" -e nvim . &
        return
    fi

    clone_url="git@${GITLAB_HOST}:${project}.git"
    cmd=$(printf 'git clone %q %q && cd %q && exec nvim . || { echo; echo "Клонирование не удалось."; exec zsh; }' \
        "$clone_url" "$local_dir" "$local_dir")
    ghostty --working-directory="$(dirname "$local_dir")" -e zsh -c "$cmd" &
}

chosen=$(build_menu | wofi --dmenu -i --matching fuzzy --sort-order alphabetical \
    --allow-images --parse-search -D dmenu-parse_action=true \
    --width 30% --height 60% \
    -p "GitLab: $GITLAB_HOST") || true
# wofi возвращает ненулевой код при отмене (Esc / ничего не выбрано) — под
# set -e это без "|| true" валило бы скрипт до проверки ниже.
[ -n "$chosen" ] || exit 0

selected="${chosen%% *}"

if printf '%s\n' "$projects" | grep -qxF "$selected"; then
    open_project "$selected"
else
    mapfile -t children < <(printf '%s\n' "$projects" | awk -F/ -v g="$selected" '{ p=$0; sub(/\/[^\/]+$/, "", p); if (p == g) print }')
    if [ "${#children[@]}" -eq 0 ]; then
        notify-send "GitLab picker" "Группа не найдена: $selected"
        exit 1
    fi
    for child in "${children[@]}"; do
        open_project "$child"
    done
fi
