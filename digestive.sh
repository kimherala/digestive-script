#!/usr/bin/bash

# Hash
# Default hash function
HASH_FUNCTION='sha256sum'
# Ragex string
HASH_FUNCTIONS_ALLOWED='(^md5sum$|^sha256sum$|^sha512sum$|^b3sum$)'

# Encoding
# Possible values hex, base64 and octal
ENCODING='hex'
# Ragex string
ENCODINGS_ALLOWED='(^hex$|^base64$|^octal$)'

# Find
# Searches the current working directory if the value is 1
FIND_MAX_DEPTH=1

## Utils
# cut
# 
# flag -d
# Use DELIM instead of TAB for field delimiter
#
# flag -f
# Select only these fields; 
# also print any line that contains no delimiter character, 
# unless the -s option is specified
#
# flag -z
# Line delimiter is NUL, not newline
function this_cut() {
    cut -d " " -f 1 -z
}

# xxd
# 
# flag -p
# Output in PostScript continuous hex dump style
# Also known as plain hex dump style
#
# flag -r
# Reverse operation: convert (or patch) hex dump into binary
function this_xxd() {
    xxd -r -p
}

# base64
# 
# flag -w 
# Wrap encoded lines after COLS character (default 76)
# Use 0 to disable line wrapping
function this_base64() {
    base64 -w 0
}

# od
#
# flag -t o1
# Format specification, -t o1 selects octal bytes formating
# 
# flag -An
# Output format for file offsets, -An == none
function this_od() {
    od -t o1 -An
}

# sed
# flag -z
# Seperate lines by NUL character
# 
# This is used for removing the trailing new line from od
function this_sed() {
    sed -z '$ s/\n$//'
}

function error_handler() {
    local error_text=$1
    
    echo "$error_text"
    exit 1
}

# Loop over flags given at startup
while getopts 'hf:e:d:' OPTION
do
    case $OPTION in
        e)
            if [[ "$OPTARG" =~ $ENCODINGS_ALLOWED ]]
            then
                ENCODING=$OPTARG
            else
                error_handler 'Invalid encoding given!'
            fi
        ;;
        f)
            if [[ "$OPTARG" =~ $HASH_FUNCTIONS_ALLOWED ]]
            then
                HASH_FUNCTION=$OPTARG
            else
                error_handler 'Invalid hash function given!'
            fi
        ;;
        d)
            if [[ "$OPTARG" -gt 1 ]]
            then
                FIND_MAX_DEPTH=$OPTARG
            fi
        ;;
        h)
            echo 'help'
        ;;
    esac
done

# Loop over files in current working directory
IFS=$'\n'
for file in $(find . -maxdepth $FIND_MAX_DEPTH -type f)
do
    case "$ENCODING" in
        "hex")
            $HASH_FUNCTION $file | this_cut && echo "  $file"
        ;;
        "base64")
            $HASH_FUNCTION $file | this_cut | this_xxd | this_base64 && echo "  $file"
        ;;
        "octal")
            $HASH_FUNCTION $file | this_cut | this_xxd | this_od | this_sed  && echo "  $file"
        ;;
    esac
done

