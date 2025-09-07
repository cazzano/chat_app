#!/bin/bash

# Intelligence script to rename decrypted files based on their first line content
# Usage: ./intelligence.sh folder_name

# Array of funky extensions (files that were decrypted from these should be processed)
FUNKY_BASE_NAMES=(
    "booom_boom_baby"
    "hacker_mode"
    "super_secret"
    "encrypted_beast"
    "digital_vault"
    "cyber_punk"
    "secret_sauce"
    "hidden_treasure"
    "crypto_magic"
    "stealth_mode"
    "quantum_data"
    "mystery_box"
    "vault_locked"
    "cyber_shield"
    "data_fortress"
    "secret_stash"
    "encrypted_soul"
    "digital_chaos"
    "secure_bunker"
    "crypto_beast"
)

# Function to check if file is a decrypted funky file (no extension, matches funky base names)
is_decrypted_funky_file() {
    local filename="$1"
    
    # Check if file has no extension (no dot in filename)
    if [[ "$filename" == *.* ]]; then
        return 1  # Has extension, not what we want
    fi
    
    # Check if it matches any of our funky base names
    for base_name in "${FUNKY_BASE_NAMES[@]}"; do
        if [[ "$filename" == "$base_name" ]]; then
            return 0  # True, it's a decrypted funky file
        fi
    done
    return 1  # False, not a decrypted funky file
}

# Function to extract filename from first line comment
extract_filename_from_comment() {
    local first_line="$1"
    local filename=""
    
    # Remove leading/trailing whitespace and comment markers
    filename=$(echo "$first_line" | sed 's/^[[:space:]]*\/\/[[:space:]]*//' | sed 's/[[:space:]]*$//')
    
    # If filename is empty or just whitespace, return empty
    if [[ -z "$filename" || "$filename" =~ ^[[:space:]]*$ ]]; then
        return 1
    fi
    
    echo "$filename"
    return 0
}

# Function to determine file extension based on content
get_file_extension() {
    local file_path="$1"
    local first_line="$2"
    
    # Check for specific patterns in the first few lines
    local first_few_lines=$(head -5 "$file_path")
    
    if [[ "$first_few_lines" == *"import 'package:flutter"* ]] || [[ "$first_few_lines" == *"class "* ]] || [[ "$first_few_lines" == *"void main()"* ]]; then
        echo ".dart"
    elif [[ "$first_few_lines" == *"<html"* ]] || [[ "$first_few_lines" == *"<!DOCTYPE"* ]]; then
        echo ".html"
    elif [[ "$first_few_lines" == *"{"* ]] && [[ "$first_few_lines" == *"\""* ]]; then
        echo ".json"
    elif [[ "$first_few_lines" == *"function"* ]] || [[ "$first_few_lines" == *"const "* ]] || [[ "$first_few_lines" == *"var "* ]]; then
        echo ".js"
    elif [[ "$first_few_lines" == *"body"* ]] || [[ "$first_few_lines" == *"color:"* ]] || [[ "$first_few_lines" == *"margin:"* ]]; then
        echo ".css"
    else
        # Default to .dart since this seems to be a Flutter project
        echo ".dart"
    fi
}

# Function to rename a single file
rename_file() {
    local file_path="$1"
    local dir_path=$(dirname "$file_path")
    local current_filename=$(basename "$file_path")
    
    echo "🔍 Analyzing: $file_path"
    
    # Read the first line
    local first_line=$(head -1 "$file_path")
    
    # Check if first line is a comment with filename
    if [[ "$first_line" == //* ]]; then
        local extracted_name=$(extract_filename_from_comment "$first_line")
        
        if [[ $? -eq 0 && -n "$extracted_name" ]]; then
            # Get appropriate file extension
            local extension=$(get_file_extension "$file_path" "$first_line")
            local new_filename="${extracted_name}${extension}"
            local new_file_path="$dir_path/$new_filename"
            
            # Check if target file already exists
            if [ -f "$new_file_path" ]; then
                echo "   ⚠️  Warning: $new_filename already exists, skipping..."
                return 1
            fi
            
            # Rename the file
            if mv "$file_path" "$new_file_path"; then
                echo "   ✅ Renamed: $current_filename → $new_filename"
                return 0
            else
                echo "   ❌ Failed to rename: $current_filename"
                return 1
            fi
        else
            echo "   ⚠️  No valid filename found in comment: $first_line"
            return 1
        fi
    else
        echo "   ⚠️  First line is not a comment with filename: $first_line"
        return 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <folder_name>"
    echo "Example: $0 lib"
    echo ""
    echo "This script renames decrypted files based on their first line comments."
    echo "Example: A file with '// main' as first line becomes 'main.dart'"
}

# Check if folder argument is provided
if [ $# -eq 0 ]; then
    echo "❌ Usage: $0 <folder_name>"
    echo "Example: $0 lib"
    exit 1
fi

FOLDER="$1"

# Check if folder exists
if [ ! -d "$FOLDER" ]; then
    echo "❌ Error: Folder '$FOLDER' does not exist!"
    exit 1
fi

# Counter for statistics
renamed_count=0
skipped_count=0
failed_count=0

echo "🧠 Starting intelligent renaming of decrypted files in '$FOLDER'"
echo "🔍 Looking for files with funky base names (no extensions)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Find all decrypted funky files and rename them
while IFS= read -r -d '' file; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        if is_decrypted_funky_file "$filename"; then
            if rename_file "$file"; then
                ((renamed_count++))
            else
                ((failed_count++))
            fi
            echo ""
        fi
    fi
done < <(find "$FOLDER" -type f -print0)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Intelligence Summary:"
echo "   ✅ Successfully renamed: $renamed_count files"
echo "   ❌ Failed/Skipped: $failed_count files"
echo ""
echo "🎉 Intelligence complete!"
echo "💡 Files renamed based on their first line comments (// filename → filename.dart)"
