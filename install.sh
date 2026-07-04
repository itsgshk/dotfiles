#!/usr/bin/env bash
#
# install.sh — установка Hyprland-дотфайлов на чистый Arch Linux
# Репозиторий: hypr, kitty, rofi, waybar (симлинками) + пакеты + greetd автологин
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO_DIR/config"
TARGET_CONFIG="$HOME/.config"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/.config-backup-$TIMESTAMP"

c_green()  { printf '\033[1;32m%s\033[0m\n' "$1"; }
c_yellow() { printf '\033[1;33m%s\033[0m\n' "$1"; }
c_red()    { printf '\033[1;31m%s\033[0m\n' "$1"; }

step() { echo; c_green "==> $1"; }

# ---------------------------------------------------------
# 0. Проверки
# ---------------------------------------------------------
if [[ "$EUID" -eq 0 ]]; then
    c_red "Не запускай скрипт от root. Запусти от обычного пользователя (sudo спросит пароль сам, когда нужно)."
    exit 1
fi

if ! command -v pacman &>/dev/null; then
    c_red "pacman не найден. Этот скрипт только для Arch Linux."
    exit 1
fi

step "Обновляю базу пакетов"
sudo pacman -Syu --noconfirm

# ---------------------------------------------------------
# 1. Установка yay, если его нет
# ---------------------------------------------------------
if ! command -v yay &>/dev/null; then
    step "yay не найден, собираю из AUR"
    sudo pacman -S --needed --noconfirm git base-devel
    tmpdir="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (cd "$tmpdir/yay" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
else
    c_yellow "yay уже установлен, пропускаю"
fi

# ---------------------------------------------------------
# 2. Установка пакетов из packages.txt
# ---------------------------------------------------------
step "Устанавливаю пакеты из packages.txt"
mapfile -t PKGS < <(grep -vE '^\s*(#|$)' "$REPO_DIR/packages.txt")
yay -S --needed --noconfirm "${PKGS[@]}"

# ---------------------------------------------------------
# 3. Бэкап существующих конфигов и симлинки
# ---------------------------------------------------------
step "Линкую конфиги (бэкап старых -> $BACKUP_DIR)"
mkdir -p "$TARGET_CONFIG"

link_config() {
    local name="$1"
    local src="$CONFIG_SRC/$name"
    local dst="$TARGET_CONFIG/$name"

    if [[ -e "$dst" && ! -L "$dst" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/$name"
        c_yellow "  backup: $dst -> $BACKUP_DIR/$name"
    elif [[ -L "$dst" ]]; then
        rm -f "$dst"
    fi

    ln -sfn "$src" "$dst"
    c_green "  linked: $dst -> $src"
}

for module in hypr kitty rofi waybar; do
    link_config "$module"
done

# ---------------------------------------------------------
# 4. Сервисы: NetworkManager, Bluetooth
# ---------------------------------------------------------
step "Включаю системные сервисы"
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service

# ---------------------------------------------------------
# 5. greetd + tuigreet — автологин в Hyprland
# ---------------------------------------------------------
step "Настраиваю greetd (tuigreet) с автозапуском Hyprland"
sudo tee /etc/greetd/config.toml >/dev/null <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --remember-user-session --cmd Hyprland"
user = "greeter"

[initial_session]
command = "Hyprland"
user = "$USER"
EOF

sudo systemctl enable greetd.service

# ---------------------------------------------------------
# 6. Финальные заметки
# ---------------------------------------------------------
step "Установка завершена"
cat <<EOF

Что сделано:
  - Пакеты из packages.txt установлены
  - ~/.config/{hypr,kitty,rofi,waybar} -> симлинки на $CONFIG_SRC
  - Старые конфиги (если были) лежат в: $BACKUP_DIR
  - NetworkManager и Bluetooth включены
  - greetd настроен на автозапуск Hyprland при загрузке

ВАЖНО, проверь руками после первого входа:
  1. monitors.conf сейчас настроен под ноутбучный eDP-1.
     Зайди в Hyprland, открой kitty, выполни:
         hyprctl monitors
     и поправь ~/.config/hypr/monitors.conf под своё реальное имя монитора
     (например DP-1 или HDMI-A-1) и разрешение.

  2. Если стоит NVIDIA — после первой загрузки с новым ядром выполни:
         sudo mkinitcpio -P
     чтобы модули nvidia попали в initramfs.

  3. zsh не назначен login-шеллом автоматически. Если хочешь:
         chsh -s /usr/bin/zsh

Перезагрузись: sudo reboot
EOF
