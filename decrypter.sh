#!/bin/bash

# Age decryption script for funky extensions
# Usage: ./decrypter.sh -p private_key.txt folder_name

# Array of funky extensions to recognize (same as encryption script)
FUNKY_EXTENSIONS=(
    "booom_boom_baby.exeeee"
    "hacker_mode.activated"
    "super_secret.ninja"
    "encrypted_beast.rawrr"
    "digital_vault.locked"
    "cyber_punk.matrix"
    "secret_sauce.spicy"
    "hidden_treasure.gold"
    "crypto_magic.wizard"
    "stealth_mode.ghost"
    "quantum_data.qbit"
    "mystery_box.unknown"
    "vault_locked.secure"
    "cyber_shield.armor"
    "data_fortress.wall"
    "secret_stash.hidden"
    "encrypted_soul.spirit"
    "digital_chaos.random"
    "secure_bunker.fort"
    "crypto_beast.monster"
)

# Check if age is installed
if ! command -v age &> /dev/null; then
    echo "❌ Error: 'age' is not installed. Install it with: sudo pacman -S age"
    exit 1
fi

# Function to show usage
show_usage() {
    echo "❌ Usage: $0 -p <private_key_file> <folder_name>"
    echo "Example: $0 -p key.txt lib"
    echo ""
    echo "Options:"
    echo "  -p <private_key_file>  Path to your private key file"
    echo "  <folder_name>          Folder containing encrypted files"
    exit 1
}

# Parse command line arguments
PRIVATE_KEY=""
FOLDER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -p)
            PRIVATE_KEY="$2"
            shift 2
            ;;
        -*)
            echo "❌ Unknown option: $1"
            show_usage
            ;;
        *)
            if [ -z "$FOLDER" ]; then
                FOLDER="$1"
            else
                echo "❌ Too many arguments"
                show_usage
            fi
            shift
            ;;
    esac
done

# Check if both private key and folder are provided
if [ -z "$PRIVATE_KEY" ] || [ -z "$FOLDER" ]; then
    show_usage
fi

# Check if private key file exists
if [ ! -f "$PRIVATE_KEY" ]; then
    echo "❌ Error: Private key file '$PRIVATE_KEY' does not exist!"
    exit 1
fi

# Check if folder exists
if [ ! -d "$FOLDER" ]; then
    echo "❌ Error: Folder '$FOLDER' does not exist!"
    exit 1
fi

# Function to check if filename has a funky extension
is_funky_extension() {
    local filename="$1"
    for ext in "${FUNKY_EXTENSIONS[@]}"; do
        if [[ "$filename" == *"$ext" ]]; then
            echo "$ext"
            return 0
        fi
    done
    return 1
}

# Function to decrypt a single file
decrypt_file() {
    local encrypted_file="$1"
    local dir_path=$(dirname "$encrypted_file")
    local filename=$(basename "$encrypted_file")
    
    # Get the funky extension
    local funky_ext=$(is_funky_extension "$filename")
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # Remove the funky extension to get original name
    local original_name="${filename%"$funky_ext"}"
    
    # If original name is empty, use "decrypted" as base name
    if [ -z "$original_name" ]; then
        original_name="decrypted"
    fi
    
    # Remove any trailing dots if they exist
    original_name="${original_name%.}"
    
    local decrypted_file="$dir_path/$original_name"
    
    echo "🔓 Decrypting: $encrypted_file"
    echo "   → $decrypted_file"
    
    if age -d -i "$PRIVATE_KEY" -o "$decrypted_file" "$encrypted_file" 2>/dev/null; then
        echo "   ✅ Success!"
        # Optionally remove encrypted file (uncomment next line if you want this)
        # rm "$encrypted_file"
        return 0
    else
        echo "   ❌ Failed to decrypt $encrypted_file"
        return 1
    fi
}

# Counter for statistics
decrypted_count=0
failed_count=0
funky_files_found=0

echo "🚀 Starting decryption of funky files in '$FOLDER'"
echo "🔑 Using private key: $PRIVATE_KEY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Find all files with funky extensions and decrypt them
while IFS= read -r -d '' file; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        if is_funky_extension "$filename" > /dev/null; then
            ((funky_files_found++))
            if decrypt_file "$file"; then
                ((decrypted_count++))
            else
                ((failed_count++))
            fi
            echo ""
        fi
    fi
done < <(find "$FOLDER" -type f -print0)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Decryption Summary:"
echo "   🔍 Funky files found: $funky_files_found"
echo "   ✅ Successfully decrypted: $decrypted_count files"
echo "   ❌ Failed: $failed_count files"
echo ""
if [ $decrypted_count -gt 0 ]; then
    echo "🎉 Decryption completed! Your files are back to their original names (minus the funky extensions)."
else
    echo "🤔 No files were decrypted. Make sure:"
    echo "   - The folder contains files with funky extensions"
    echo "   - The private key is correct"
    echo "   - The files were encrypted with the matching public key"
fi
