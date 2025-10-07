#!/bin/bash

# Script to decrypt files using age with a private key file

# Function to display usage
usage() {
    echo "Usage: $0 -k <key_file> <pattern1> [pattern2] [pattern3] ..."
    echo ""
    echo "Options:"
    echo "  -k    Path to the age private key file (e.g., key.txt)"
    echo ""
    echo "Examples:"
    echo "  $0 -k key.txt *.txt.age"
    echo "  $0 -k key.txt *.txt *.go *.rs"
    echo "  $0 -k key.txt file1.txt.age file2.go.age"
    echo ""
    echo "This will decrypt each .age file back to its original form"
    echo "Example: file.txt.age → file.txt"
    exit 1
}

# Parse command line arguments
KEY_FILE=""
while getopts "k:h" opt; do
    case $opt in
        k)
            KEY_FILE="$OPTARG"
            ;;
        h)
            usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
    esac
done

# Shift past the processed options
shift $((OPTIND - 1))

# Check if key file is provided
if [ -z "$KEY_FILE" ]; then
    echo "Error: Key file not specified!"
    usage
fi

# Check if key file exists
if [ ! -f "$KEY_FILE" ]; then
    echo "Error: Key file '$KEY_FILE' not found!"
    exit 1
fi

# Check if files to decrypt are provided
if [ -z "$1" ]; then
    echo "Error: No file(s) to decrypt specified!"
    usage
fi

# Get all patterns and expand them to .age files
FILES=()
for pattern in "$@"; do
    # If pattern doesn't end with .age, add it
    if [[ ! "$pattern" =~ \.age$ ]]; then
        pattern="${pattern}.age"
    fi
    
    # Expand the pattern
    for file in $pattern; do
        if [ -f "$file" ]; then
            FILES+=("$file")
        fi
    done
done

# Check if we found any files
if [ ${#FILES[@]} -eq 0 ]; then
    echo "Error: No .age files found matching the patterns!"
    exit 1
fi

# Counters for summary
TOTAL_FILES=0
DECRYPTED_FILES=0
FAILED_FILES=0

# Decrypt each file
for ENCRYPTED_FILE in "${FILES[@]}"; do
    TOTAL_FILES=$((TOTAL_FILES + 1))
    
    # Remove .age extension to get original filename
    OUTPUT_FILE="${ENCRYPTED_FILE%.age}"
    
    # Check if output file already exists
    if [ -f "$OUTPUT_FILE" ]; then
        echo "[$TOTAL_FILES] ⚠ Warning: '$OUTPUT_FILE' already exists!"
        read -p "  Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "  Skipped."
            FAILED_FILES=$((FAILED_FILES + 1))
            echo ""
            continue
        fi
    fi
    
    # Decrypt the file
    echo "[$TOTAL_FILES] Decrypting '$ENCRYPTED_FILE' → '$OUTPUT_FILE'..."
    if age -d -i "$KEY_FILE" -o "$OUTPUT_FILE" "$ENCRYPTED_FILE" 2>/dev/null; then
        echo "  ✓ Success!"
        DECRYPTED_FILES=$((DECRYPTED_FILES + 1))
    else
        echo "  ✗ Failed! (Wrong key or corrupted file)"
        FAILED_FILES=$((FAILED_FILES + 1))
    fi
    echo ""
done

# Print summary
echo "════════════════════════════════════════"
echo "Decryption Summary:"
echo "  Total files processed: $TOTAL_FILES"
echo "  Successfully decrypted: $DECRYPTED_FILES"
echo "  Failed/Skipped: $FAILED_FILES"
echo "════════════════════════════════════════"

# Exit with error if any files failed
if [ $FAILED_FILES -gt 0 ]; then
    exit 1
fi
