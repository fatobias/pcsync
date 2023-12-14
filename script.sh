#!/bin/bash

# get a simple list of modified files
# git status --porcelain | grep '^.*\ ' | cut -c 4-

add_files()
{
    echo "bruha1"
    local sfile="$1"
    echo "bruha2"
    if [ ! -e "$sfile" ]; then
        echo "bruha3"
        echo "Files to sinc not found"
        return
    fi
    echo "bruha4"

    I=1
    while IFS= read -r line; do
        FILE=$(echo "$line" | cut -d ';' -f 1)
        SOURCE=$(echo "$line" | cut -d ';' -f 2)
        if [ -e "SOURCE" ]; then
            if [ $FILE == 'f' ]; then
                echo "in file"
                add_files "${SOURCE}"
            else
                echo "in zip"
                #echo "$(echo "$SOURCE" | rev | cut -d '/' -f 1 | rev)"
                #echo "$SOURCE"
                zip -r "$(echo "$SOURCE" | rev | cut -d '/' -f 1 | rev)" "$SOURCE"
                #add_files "${SOURCE}.zip"
            fi
        else echo "File on line $I doesn't exist \n --skipping"; fi
    done < "$sfile"
}

# adding new and modified files
git_add() {
    echo $DIR
    local files=("$@")
    for file in "${files[@]}"; do
        echo "$file"
        git add "$file"
    done
}


#DIR="/home/borec/fun/sync_test/pcsync"
#cd $DIR;
#mapfile -t modified_files < <(git status --porcelain | grep '^.* ' | cut -c 4-)

echo "bruh"
add_files "movement"
echo "bruh"

echo "push to main [y/n] "
read -r PROCEED

if [ ! $PROCEED == "y" ]; then echo "exiting"; exit 2; else echo "good luck then"; fi

DATE=`date`
git commit -m "$DATE"
git push
