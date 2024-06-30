#!/usr/bin/bash

#Hash
hash_function='sha256sum'

#Encoding
#Possible values hex and base64
encoding="hex"

## Utils
#cut
this_cut() {
    cut -d " " -f 1 -z
}

#xxd
this_xxd() {
    xxd -r -p
}

#base64
this_base64() {
    base64 -w 0
}

while getopts 'he:' OPTION; do
    case $OPTION in
        e)
            if [[ "$OPTARG" =~ (hex|base64) ]]; then
                encoding=$OPTARG
            fi
        ;;
        h)
            echo "help"
        ;;
    esac
done

for file in `find . -maxdepth 1 -type f` ; do
    if [[ "$encoding" == "hex" ]]; then
        $hash_function $file | this_cut && echo "  $file"
    fi
    if [[ "$encoding" == "base64" ]]; then
        $hash_function $file | this_cut | this_xxd | this_base64 && echo "  $file"
    fi
done
