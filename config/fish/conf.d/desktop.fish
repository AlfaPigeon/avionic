# Linked only when installed with `--shell fish`. Small, safe defaults.
set -g fish_greeting
set -gx EDITOR (command -v nvim; or command -v vim; or echo nano)
set -gx TERMINAL kitty
