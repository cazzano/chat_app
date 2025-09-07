#!/bin/bash

# Age decryption script for funky encrypted files
# Usage: ./decrypter.sh -p private_key.txt folder_name

# Array of funky extensions to recognize
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

# Function to check if file has a funky extension
is_funky_extension() {
    local filename="$1"
    for ext in "${FUNKY_EXTENSIONS[@]}"; do
        if [[ "$filename" == "$ext" ]]; then
            return 0  # True, it's a funky extension
        fi
    done
    return 1  # False, not a funky extension
}

# Function to show usage
show_usage() {
    echo "Usage: $0 -p <private_key_file> <folder_name>"
    echo "Example: $0 -p key.txt lib"
    echo ""
    echo "Options:"
    echo "  -p <file>    Private key file for decryption"
    echo "  <folder>     Folder containing encrypted files"
}

# Check if age is installed
if ! command -v age &> /dev/null; then
    echo "❌ Error: 'age' is not installed. Install it with: sudo pacman -S age"
    exit 1
fi

# Parse command line arguments
PRIVATE_KEY=""
FOLDER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -p)
            PRIVATE_KEY="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        -*)
            echo "❌ Error: Unknown option $1"
            show_usage
            exit 1
            ;;
        *)
            if [ -z "$FOLDER" ]; then
                FOLDER="$1"
            else
                echo "❌ Error: Too many arguments"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if required arguments are provided
if [ -z "$PRIVATE_KEY" ] || [ -z "$FOLDER" ]; then
    echo "❌ Error: Missing required arguments"
    show_usage
    exit 1
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

# Function to decrypt a single file
decrypt_file() {
    local encrypted_file="$1"
    local dir_path=$(dirname "$encrypted_file")
    local filename=$(basename "$encrypted_file")
    
    echo "🔓 Decrypting: $encrypted_file"
    
    # Just remove the funky extension - no intelligence, just chop it off
    local base_name=""
    if [[ "$filename" == *"."* ]]; then
        # Remove everything after the last dot
        base_name=$(echo "$filename" | sed 's/\.[^.]*$//')
    else
        base_name="$filename"
    fi
    
    # Final decrypted file path - just the base name, no added extensions
    local decrypted_file="$dir_path/$base_name"
    
    if age -d -i "$PRIVATE_KEY" "$encrypted_file" > "$decrypted_file" 2>/dev/null; then
        echo "   → $decrypted_file"
        echo "   ✅ Success!"
        return 0
    else
        echo "   ❌ Failed to decrypt $encrypted_file"
        rm -f "$decrypted_file"  # Clean up failed attempt
        return 1
    fi
}

# Counter for statistics
decrypted_count=0
failed_count=0

echo "🚀 Starting decryption of funky encrypted files in '$FOLDER'"
echo "🔑 Using private key: $PRIVATE_KEY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Find all files with funky extensions and decrypt them
while IFS= read -r -d '' file; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        if is_funky_extension "$filename"; then
            if decrypt_file "$file"; then
                ((decrypted_count++))
            else
                ((failed_count++))
            fi
            echo ""
        fi
    fi
done < <(find "$FOLDER" -type f -print0)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Decryption Summary:"
echo "   ✅ Successfully decrypted: $decrypted_count files"
echo "   ❌ Failed: $failed_count files"
echo "   📁 Funky extensions removed, files restored in original directories"
echo ""
echo "🎉 Decryption complete!"
echo "💡 crypto_beast.monster → crypto_beast (no extra extensions added)"
