# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="fullzero"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  ng
  npm
  node-bin
  pip
  #pyenv
  #autoenv
  vi-mode
  zsh-autosuggestions
)

# autovenv python3-venv
python_venv() {
  MYVENV=./venv
  # when you cd into a folder that contains $MYVENV
  [[ -d $MYVENV ]] && source $MYVENV/bin/activate > /dev/null 2>&1
  # when you cd into a folder that doesn't
  [[ ! -d $MYVENV ]] && deactivate > /dev/null 2>&1
}
autoload -U add-zsh-hook
add-zsh-hook chpwd python_venv

python_venv
# / autoenv

#AUTOENV_ENABLE_LEAVE=yes
#source '/usr/lib/node_modules/@hyperupcall/autoenv/activate.sh'

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# Installation directory of Android SDK package.
# Example: C:\AndroidSDK or /usr/local/android-sdk/
ANDROID_HOME=~/Android/Sdk

# Location of SDK related data/user files.
# Example: C:\Users\<USERNAME>\.android\ or ~/.android/
ANDROID_USER_HOME=~/.android/

# Installation directory of Android NDK package. (WITHOUT ANY SPACE)
# Example: C:\AndroidNDK or /usr/local/android-ndk/
#ANDROID_NDK_ROOT=/usr/local/android-ndk/

# Location of emulator-specificdata files.
# Example: C:\Users\<USERNAME>\.android\ or ~/.android/
ANDROID_EMULATOR_HOME=$ANDROID_USER_HOME

# Location of AVD-specificdata files.
# Example: C:\Users\<USERNAME>\.android\avd\ or ~/.android/avd/
ANDROID_AVD_HOME=$ANDROID_USER_HOME/avd/

# Installation directory of JDK (aka Java SDK) package.
# Note: This is used to run Android Studio(and other Java-based applications).
# Actually when you run Android Studio, it checks for JDK_HOME then JAVA_HOME environment variables to use.
JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64/
JDK_HOME=$JAVA_HOME

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lazydotfiles='lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lf="cd \"\$(command lf -print-last-dir \"$@\")\""
alias cpr="cp -r"
alias ls="exa"
alias l="exa --git -F --color --icons --hyperlink --no-quotes"
alias ll="l -l"
alias lg="lazygit"
alias cat="bat --style=auto -pp --wrap=never"
alias curl="curl --location"
alias curl="curl --location"
alias br="browsh"
alias music="yamusic"
alias data="cd /mnt/data"
alias y2dl="yt-dlp --proxy 'http://user303744:r7vw24@89.40.215.66:3263'"
alias P="cd ~/Projects"
#alias cal="cal -M"
#alias ncal="cal -M"
#alias ncal="cal -M"
alias nv="nvim ."

# local binaries
export PATH="/home/fullzero/.local/bin:$PATH"

# bun completions
[ -s "/home/fullzero/.bun/_bun" ] && source "/home/fullzero/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export GOPATH=$HOME/.go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

export TERM=xterm-256color
export PATH="/opt/zig:$PATH"

gen() {
  local cmd=$1
  shift
  schematics ~/Projects/demo/schematics:$cmd --no-dry-run "$@"
}

sandbox() {
    local ACTION=$1
    local PROJECT_ROOT=$(pwd)
    local PROJECT_NAME=$(basename "$PROJECT_ROOT")
    local BASE_TMP="/tmp/overlay_sandboxes/$PROJECT_NAME"
    local UPPER="$BASE_TMP/upper"
    local WORK="$BASE_TMP/work"
    local LOWER_BIND="$BASE_TMP/lower_bind"

    case "$ACTION" in
        on)
            if mount | grep -q "on $PROJECT_ROOT type overlay"; then
                echo "⚠️  Песочница уже активна."
                return
            fi

            # 1. Просто создаем папки. Они УЖЕ в RAM, так как /tmp это tmpfs
            mkdir -p "$UPPER" "$WORK" "$LOWER_BIND"
            
            # 2. Делаем bind-mount для обхода рекурсии (ошибка "bad superblock")
            sudo mount --bind "$PROJECT_ROOT" "$LOWER_BIND"
            # Делаем его Read-Only для безопасности
            sudo mount -o remount,ro,bind "$LOWER_BIND"

            # 3. Монтируем Overlay
            sudo mount -t overlay "ovl_$PROJECT_NAME" \
                -o lowerdir="$LOWER_BIND",upperdir="$UPPER",workdir="$WORK" \
                "$PROJECT_ROOT"
            
            export SANDBOX_ACTIVE=1
            cd .
            echo "🚀 Песочница включена."
            ;;
        
        off)
            if ! mount | grep -q "on $PROJECT_ROOT type overlay"; then
                echo "❌ Здесь нет активной песочницы."
                return
            fi

            # Используем -l, чтобы не ругался на открытый nvim
            sudo umount -l "$PROJECT_ROOT"
            sudo umount -l "$LOWER_BIND"
            
            # Пытаемся очистить мусор. 
            sudo rm -rf "$BASE_TMP" 2>/dev/null
            
            unset SANDBOX_ACTIVE
            cd .
            echo "✨ Песочница отключена."
            ;;
        *)
            echo "Usage: sandbox [on|off]"
            ;;
    esac
}

# Функция для проверки статуса песочницы
function sandbox_status() {
  # Проверяем переменную или наличие mount в текущей папке
  if mount | grep -q "on $PWD type overlay"; then
    echo "%F{yellow}⏳%f"
  fi
}



# Load Angular CLI autocompletion.
source <(ng completion script)
