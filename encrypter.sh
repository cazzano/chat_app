#!/bin/bash

# Age encryption script with random funky extensions
# Usage: ./script.sh folder_name

PUBLIC_KEY="age1az9dck72fe7szc69jfe5dq94t24hpkszjlgrv6lkh3t5ankxfq3sgyv3ds"

# Check if age is installed
if ! command -v age &> /dev/null; then
    echo "❌ Error: 'age' is not installed. Install it with: sudo pacman -S age"
    exit 1
fi

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

# Array of random funky extensions
EXTENSIONS=(
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

# Function to get random extension
get_random_extension() {
    local rand_index=$((RANDOM % ${#EXTENSIONS[@]}))
    echo "${EXTENSIONS[$rand_index]}"
}

# Function to encrypt a single file
encrypt_file() {
    local file_path="$1"
    local dir_path=$(dirname "$file_path")
    local filename=$(basename "$file_path")
    local random_ext=$(get_random_extension)
    local encrypted_file="$dir_path/$random_ext"
    
    echo "🔒 Encrypting: $file_path"
    echo "   → $encrypted_file"
    
    if age -r "$PUBLIC_KEY" -o "$encrypted_file" "$file_path"; then
        echo "   ✅ Success!"
        # Optionally remove original file (uncomment next line if you want this)
        # rm "$file_path"
    else
        echo "   ❌ Failed to encrypt $file_path"
        return 1
    fi
}

# Counter for statistics
encrypted_count=0
failed_count=0

echo "🚀 Starting encryption of all files in '$FOLDER'"
echo "📁 Using public key: $PUBLIC_KEY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Find all files (not directories) and encrypt them
while IFS= read -r -d '' file; do
    if [ -f "$file" ]; then
        if encrypt_file "$file"; then
            ((encrypted_count++))
        else
            ((failed_count++))
        fi
        echo ""
    fi
done < <(find "$FOLDER" -type f -print0)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Encryption Summary:"
echo "   ✅ Successfully encrypted: $encrypted_count files"
echo "   ❌ Failed: $failed_count files"
echo "   📁 All encrypted files remain in their original directories"
echo ""
echo "🔐 All files encrypted with funky random extensions!"
echo "💡 To decrypt a file: age -d -i your_private_key.txt encrypted_file > original_file"
