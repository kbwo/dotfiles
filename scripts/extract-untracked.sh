#!/bin/bash

# Check if two arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <source_git_root> <destination_directory>"
    echo "  source_git_root: Directory where 'git ls-files' will be executed"
    echo "  destination_directory: Directory where files will be copied to"
    exit 1
fi

SOURCE_DIR="$1"
DEST_DIR="$2"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist"
    exit 1
fi

# Check if source directory is a git repository
if [ ! -d "$SOURCE_DIR/.git" ]; then
    echo "Error: '$SOURCE_DIR' is not a git repository"
    exit 1
fi

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Change to source directory
cd "$SOURCE_DIR" || exit 1

# Get list of untracked directories
UNTRACKED_DIRS=$(git ls-files --others --directory)

# Get list of all untracked files
UNTRACKED_FILES=$(git ls-files --others)

# Copy untracked directories
if [ -n "$UNTRACKED_DIRS" ]; then
    echo "Copying untracked directories..."
    while IFS= read -r dir; do
        if [ -n "$dir" ]; then
            # Remove trailing slash if present
            dir="${dir%/}"
            echo "  Copying directory: $dir"
            mkdir -p "$DEST_DIR/$(dirname "$dir")"
            cp -r "$dir" "$DEST_DIR/$(dirname "$dir")/"
        fi
    done <<< "$UNTRACKED_DIRS"
fi

# Copy untracked files (excluding those in untracked directories)
if [ -n "$UNTRACKED_FILES" ]; then
    echo "Copying untracked files..."
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            # Check if the file is inside any untracked directory
            is_in_dir=false
            if [ -n "$UNTRACKED_DIRS" ]; then
                while IFS= read -r dir; do
                    if [ -n "$dir" ]; then
                        # Remove trailing slash if present
                        dir="${dir%/}"
                        # Check if file starts with directory path
                        if [[ "$file" == "$dir/"* ]]; then
                            is_in_dir=true
                            break
                        fi
                    fi
                done <<< "$UNTRACKED_DIRS"
            fi
            
            # Copy file only if it's not in an untracked directory
            if [ "$is_in_dir" = false ]; then
                echo "  Copying file: $file"
                # Create parent directory if needed
                mkdir -p "$DEST_DIR/$(dirname "$file")"
                cp "$file" "$DEST_DIR/$file"
            fi
        fi
    done <<< "$UNTRACKED_FILES"
fi

echo "Done! Untracked files and directories have been copied to '$DEST_DIR'"

echo "Enabling serena MCP..."

claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd)

echo "Serena MCP added"