#!/bin/bash

# Функция для установки tmux на Ubuntu
install_tmux_ubuntu() {
    echo "tmux не установлен. Устанавливаем tmux на Ubuntu..."
    sudo apt-get update
    sudo apt-get install -y tmux
}

# Функция для установки tmux на macOS
install_tmux_mac() {
    echo "tmux не установлен. Устанавливаем tmux на macOS..."
    brew install tmux
}

# Проверка операционной системы и установка tmux, если он не установлен
if ! command -v tmux &> /dev/null
then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            if [[ "$ID" == "ubuntu" ]]; then
                install_tmux_ubuntu
            else
                echo "Этот скрипт поддерживает только установку tmux на Ubuntu."
                exit 1
            fi
        else
            echo "Не удалось определить дистрибутив Linux."
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &> /dev/null
        then
            echo "Homebrew не установлен. Установите Homebrew и повторите попытку."
            exit 1
        fi
        install_tmux_mac
    else
        echo "Этот скрипт поддерживает только Ubuntu и macOS."
        exit 1
    fi
fi

# Порты для инстансов
PORTS=(5001 5002 5003 5004)

# Общие параметры для запуска
COMMON_PARAMS="--mode api -v --host 0.0.0.0 --upscaler waifu2x --upscale-ratio 2 --uppercase --font-path fonts/anime_ace_3.ttf --det-gamma-correct --det-invert --det-auto-rotate --no-hyphenation --mask-dilation-offset 3 --unclip-ratio 4 --revert-upscaling --manga2eng"

# Имя tmux сессии
SESSION_NAME="manga_translator"

# Создание новой tmux сессии
tmux new-session -d -s $SESSION_NAME

# Запуск инстансов в отдельных окнах tmux
for PORT in "${PORTS[@]}"; do
  tmux new-window -t $SESSION_NAME -n "Port $PORT" "echo 'Запуск инстанса на порту $PORT'; python3 -m manga_translator $COMMON_PARAMS --port $PORT; exec bash"
done

# Установка раскладки окон
tmux select-layout -t $SESSION_NAME tiled

echo "Все инстансы запущены в tmux сессии '$SESSION_NAME'. Используйте 'tmux attach -t $SESSION_NAME' для подключения."