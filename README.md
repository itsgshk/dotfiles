# dotfiles

Мои конфиги для Arch Linux + Hyprland: `hypr`, `kitty`, `rofi` (adi1090x launchers), `waybar`.
`install.sh` ставит пакеты, линкует конфиги симлинками и настраивает автологин в Hyprland через greetd.

## Что внутри

```
dotfiles/
├── install.sh          # главный скрипт установки
├── packages.txt        # список пакетов для yay -S
├── README.md
└── config/
    ├── hypr/
    ├── kitty/
    ├── rofi/
    └── waybar/
```

## Установка с чистого Arch (после базовой установки системы с флешки)

Предполагается, что база Arch уже установлена стандартным способом
(archinstall или ручной `pacstrap` + `arch-chroot`), система загружается,
есть пользователь (не root) с sudo, и есть интернет.

```bash
sudo pacman -S --needed git
git clone https://github.com/itsgshk/dotfiles.git
cd dotfiles
./install.sh
```

Скрипт сам:
1. Обновит систему (`pacman -Syu`)
2. Поставит `yay`, если его нет
3. Установит все пакеты из `packages.txt`
4. Забэкапит существующие `~/.config/{hypr,kitty,rofi,waybar}` (если есть) в `~/.config-backup-<дата>`
5. Создаст симлинки `~/.config/X -> ~/dotfiles/config/X`
6. Включит NetworkManager и Bluetooth
7. Настроит `greetd` + `tuigreet` с автозапуском Hyprland при загрузке

## После установки — обязательно проверить

- **Монитор.** `monitors.conf` сейчас под ноутбучный `eDP-1`. После первого входа
  выполни `hyprctl monitors` и пропиши правильное имя/разрешение в
  `~/.config/hypr/monitors.conf`.
- **NVIDIA.** Если ядро обновилось — `sudo mkinitcpio -P`, чтобы модуль подхватился
  в initramfs.
- **zsh** не назначается login-шеллом автоматически: `chsh -s /usr/bin/zsh`.

## Обновление конфигов

Конфиги — симлинки на репозиторий, поэтому редактируешь прямо в
`~/dotfiles/config/...` и коммитишь:

```bash
cd ~/dotfiles
git add -A
git commit -m "update hypr keybindings"
git push
```

## Повторный запуск install.sh

Скрипт идемпотентен: пакеты не переустанавливаются лишний раз (`--needed`),
существующие симлинки просто пересоздаются, обычные файлы/папки бэкапятся
перед заменой.
