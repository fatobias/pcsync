#!/bin/bash

# get a simple list of modified files
# git status --porcelain | grep '^.*\ ' | cut -c 4-


DATADIR="/home/borec/fun/pcsync/data"

add_files()
{
    local sfile="$1"
    if [ ! -e "$sfile" ]; then
        echo "list of files to sinc not found"
        exit 2
    fi

    i=0
    while IFS= read -r line; do
        i=$((i+1))

        FILE=$(echo "$line" | cut -d ';' -f 1)
        SOURCE=$(echo "$line" | cut -d ';' -f 2)

        if [ -e "$SOURCE" ]; then
            if [[ $FILE == 'f' ]]; then
                if [[ -e "$DIR/data/$FILE" ]]; then
                    cat "$SOURCE" > "$DIR/data/$FILE"
                else
                    cp "$SOURCE" "./data/."
                fi
            else
                #if [[ $REWRITE_DIR == 0 ]]; then
                    #echo "You are about to rewrite a directory stored in $(pwd)/data"
                    #echo "are you sure? (A sets it for all) [y/n/A] "
                    #read -rp REWRITE
                    #if [[ $REWRITE == 'A' ]]; then
                    #    REWRITE_DIR=1
                    #elif [[ ! $REWRITE == 'y' ]]; then
                    #    continue
                    #fi
                #fi
                FILENAME="$(echo "$SOURCE" | rev | cut -d '/' -f 1 | rev)"
                FILENAMEPATH="$(echo "$SOURCE" | rev | cut -d '/' -f 2- | rev)"
                echo "$FILENAME"
                echo 
                echo "--------------------------"

                echo "$SOURCE"
                echo "$FILENAMEPATH"
                echo "$FILENAME"
                echo "--------------------------"
                echo 

                cd "$FILENAMEPATH"
                zip -r "$DIR/data/${FILENAME}_autosync_prep" "$FILENAME" >&/dev/null
                cd "$DIR"
            fi
        else echo "File on line $i doesn't exist --skipping"
        fi
    done < "$sfile"
}

distribute_files() {
    while IFS= read -r line; do
    local sfile="$1"
    if [ ! -e "$sfile" ]; then
        echo "list of files to sinc not found"
        exit 2
    fi

    i=0
    while IFS= read -r line; do
        i=$((i+1))

        FILE=$(echo "$line" | cut -d ';' -f 1)
        SOURCE=$(echo "$line" | cut -d ';' -f 2)

        if [ -e "$SOURCE" ]; then
            FILENAME="$(echo "$SOURCE" | rev | cut -d '/' -f 1 | rev)"
            FILENAMEPATH="$(echo "$SOURCE" | rev | cut -d '/' -f 2- | rev)"
            if [[ $FILE == 'f' ]]; then
                if [[ ! -e "$FILENAMEPATH" ]]; then
                    mkdir -p "$FILENAMEPATH"
                fi
                if [[ -e "$SOURCE" ]]; then
                    cat "$DIR/data/$FILE" > "$SOURCE"
                else
                    cp "./data/$FILENAME" "$FILENAMEPATH/."
                fi
            else
                #if [[ $REWRITE_DIR == 0 ]]; then
                    #echo "You are about to rewrite a directory stored in $(pwd)/data"
                    #echo "are you sure? (A sets it for all) [y/n/A] "
                    #read -rp REWRITE
                    #if [[ $REWRITE == 'A' ]]; then
                    #    REWRITE_DIR=1
                    #elif [[ ! $REWRITE == 'y' ]]; then
                    #    continue
                    #fi
                #fi
                echo "$FILENAME"
                echo 
                echo "--------------------------"

                echo "$SOURCE"
                echo "$FILENAMEPATH"
                echo "$FILENAME"
                echo "--------------------------"
                echo 

                #cd "$FILENAMEPATH"
                if [[ ! -e "$FILENAMEPATH" ]]; then
                    mkdir -p "$FILENAMEPATH"
                fi

                cp "$DIR/data/${FILENAME}_autosync_prec.zip" "$FILENAMEPATH/."
                #zip -r "$DIR/data/${FILENAME}_autosync_prep" "$FILENAME" >&/dev/null
                #cd "$DIR"
            fi
        else echo "File on line $i doesn't exist --skipping"
        fi
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

DIR="/home/borec/fun/pcsync"
#cd $DIR;
if [ ! -e "$DIR/data/" ]; then
    mkdir "data"
fi

if [ "$1" == "push" ]; then
    add_files "addresses"

    git add "addresses"

    #mapfile -t modified_files < <(git status --porcelain | grep '^.* ' | cut -c 4-)

    echo "push to main [y/n] "
    read -r PROCEED

    if [ ! $PROCEED == "y" ]; then
        echo "exiting"
        exit 2
    fi
    echo "good luck then"
    git add data/
    DATE=`date`
    git commit -m "$DATE"
    git push

elif [ "$1" == "pull" ]; then
    git pull
    distribute_files "addresses"
fi

