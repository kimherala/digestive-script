#!/usr/bin/bash

# Hash
# Default hash function
hash_function='sha256sum'
# Ragex string
hash_functions_allowed='(^md5sum$|^sha256sum$|^sha512sum$|^b3sum$)'

# Encoding
# Possible values hex and base64
encoding='hex'
# Ragex string
encodings_allowed='(^hex$|^base64$)'

# Find
# Searches the current working directory if the value is 1
find_max_depth=1

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

function error_handler()
{
    local error_text=$1
    
    echo "$error_text"
    exit 1
}

# Loop over flags given at startup
while getopts 'hf:e:d:' OPTION
do
    case $OPTION in
        e)
            if [[ "$OPTARG" =~ $encodings_allowed ]]
            then
                encoding=$OPTARG
            else
                error_handler 'Invalid encoding given!'
            fi
        ;;
        f)
            if [[ "$OPTARG" =~ $hash_functions_allowed ]]
            then
                hash_function=$OPTARG
            else
                error_handler 'Invalid hash function given!'
            fi
        ;;
        d)
            if [[ "$OPTARG" -gt 1 ]]
            then
                find_max_depth=$OPTARG
            fi
        ;;
        h)
            echo 'help'
        ;;
    esac
done

# Loop over files in current working directory
IFS=$'\n'
for file in $(find . -maxdepth $find_max_depth -type f)
do
    case $encoding in
        "hex")
            $hash_function $file | this_cut && echo "  $file"
        ;;
        "base64")
            $hash_function $file | this_cut | this_xxd | this_base64 && echo "  $file"
        ;;
    esac
done

