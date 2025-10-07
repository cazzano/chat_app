#!/bin/bash

# Script to encrypt files using age with a private key file

# Function to display usage
usage() {
    echo "Usage: $0 -k <key_file> <file1> [file2] [file3] ..."
    echo ""
    echo "Options:"
    echo "  -k    Path to the age private key file (e.g., key.txt)"
    echo ""
    echo "Examples:"
    echo "  $0 -k key.txt myfile.txt"
    echo "  $0 -k key.txt file1.txt file2.txt file3.txt"
    echo "  $0 -k key.txt *.txt *.rs *.md"
    echo ""
    echo "This will encrypt each file and create .age encrypted versions"
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

# Check if files to encrypt are provided
if [ -z "$1" ]; then
    echo "Error: No file(s) to encrypt specified!"
    usage
fi

# Get all files to encrypt
FILES=("$@")

# Extract public key from the private key file
PUBLIC_KEY=$(grep "^age1" "$KEY_FILE" | head -n 1)

# If not found in that format, try to extract from comment
if [ -z "$PUBLIC_KEY" ]; then
    PUBLIC_KEY=$(grep "# public key:" "$KEY_FILE" | cut -d: -f2 | tr -d ' ')
fi

# Check if we found a public key
if [ -z "$PUBLIC_KEY" ]; then
    echo "Error: Could not extract public key from '$KEY_FILE'"
    echo "Make sure your key file contains the public key."
    exit 1
fi

# Counters for summary
TOTAL_FILES=0
ENCRYPTED_FILES=0
FAILED_FILES=0

# Encrypt each file
for INPUT_FILE in "${FILES[@]}"; do
    TOTAL_FILES=$((TOTAL_FILES + 1))
    
    # Check if input file exists
    if [ ! -f "$INPUT_FILE" ]; then
        echo "⚠ Warning: File '$INPUT_FILE' not found! Skipping..."
        FAILED_FILES=$((FAILED_FILES + 1))
        continue
    fi
    
    # Output file name
    OUTPUT_FILE="${INPUT_FILE}.age"
    
    # Encrypt the file
    echo "[$TOTAL_FILES] Encrypting '$INPUT_FILE' → '$OUTPUT_FILE'..."
    if age -e -r "$PUBLIC_KEY" -o "$OUTPUT_FILE" "$INPUT_FILE"; then
        echo "  ✓ Success!"
        ENCRYPTED_FILES=$((ENCRYPTED_FILES + 1))
    else
        echo "  ✗ Failed!"
        FAILED_FILES=$((FAILED_FILES + 1))
    fi
    echo ""
done

# Print summary
echo "════════════════════════════════════════"
echo "Encryption Summary:"
echo "  Total files processed: $TOTAL_FILES"
echo "  Successfully encrypted: $ENCRYPTED_FILES"
echo "  Failed: $FAILED_FILES"
echo "════════════════════════════════════════"

# Exit with error if any files failed
if [ $FAILED_FILES -gt 0 ]; then
    exit 1
fi
