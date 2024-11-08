#!/bin/bash

DICT_DIR="$HOME/.config/nvim/dict"

US_DICT_FILE="american_english.txt"

US_URL="https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt"

if [[ ! -d "$DICT_DIR" ]]; then
    echo "Creating directory $DICT_DIR..."
    mkdir -p "$DICT_DIR"
fi

echo "Downloading American English dictionary..."
curl -fLo "$DICT_DIR/$US_DICT_FILE" "$US_URL"
if [[ -f "$DICT_DIR/$US_DICT_FILE" ]]; then
    echo "American English dictionary downloaded successfully to $DICT_DIR."
else
    echo "Failed to download American English dictionary."
    exit 1
fi

echo "All dictionaries downloaded to $DICT_DIR."
