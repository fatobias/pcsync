#!/bin/bash

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
                FILENAME="$(echo "$SOURCE" | rev | cut -d '/' -f 1 | rev)"
                FILENAMEPATH="$(echo "$SOURCE" | rev | cut -d '/' -f 2- | rev)"
                echo "--------------------------"
                echo "$SOURCE"
                echo "$FILENAMEPATH"
                echo "$FILENAME"
                echo "--------------------------"

                cd "$FILENAMEPATH"
                zip -r "$DIR/data/${FILENAME}_autosync_prep" "$FILENAME" >&/dev/null
                cd "$DIR"
            fi
        else echo "File on line $i doesn't exist --skipping"
        fi
    done < "$sfile"
}

distribute_files() {
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
        FILENAME="$(echo "$SOURCE" | rev | cut -d '/' -f 1 | rev)"
        FILENAMEPATH="$(echo "$SOURCE" | rev | cut -d '/' -f 2- | rev)"

        if [[ $FILE == 'f' ]]; then
            echo "$FILENAMEPATH"
            if [ ! -d "$FILENAMEPATH" ]; then
                mkdir -p "$FILENAMEPATH"
            fi
            if [[ -e "$SOURCE" ]]; then
                cat "$DIR/data/$FILENAME" > "$SOURCE"
            else
                cp "$DIR/data/$FILENAME" "$FILENAMEPATH/."
            fi
        else
            echo "--------------------------"
            echo "$SOURCE"
            echo "$FILENAMEPATH"
            echo "$FILENAME"
            echo "--------------------------"

            echo "$FILENAMEPATH"
            if [ ! -d "$FILENAMEPATH" ]; then
                mkdir -p "$FILENAMEPATH"
            fi

            echo "$DIR/data/${FILENAME}_autosync_prep.zip"
            echo "$FILENAMEPATH/."
            #echo "failed cp --skipping"; continue
            cp "$DIR/data/${FILENAME}_autosync_prep.zip" "$FILENAMEPATH/." || `echo "failed cp --skipping"; continue`

            length=${#FILENAMEPATH}

            if [ $length -lt 20 ]; then echo "Nice try asshole"; exit 2; fi

            if [ -d "${FILENAMEPATH}/${FILENAME}" ]; then
                if [ -d "${FILENAMEPATH}/${FILENAME}_old" ]; then
                    rm -rf "${FILENAMEPATH}/${FILENAME}_old"
                fi
                mv "${FILENAMEPATH}/${FILENAME}" "${FILENAMEPATH}/${FILENAME}_old"
            fi
            cd "${FILENAMEPATH}"
            unzip "${FILENAMEPATH}/${FILENAME}_autosync_prep"
            cd "${DIR}"
            rm "${FILENAMEPATH}/${FILENAME}_autosync_prep.zip"
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
if [ ! -d "$DIR/data/" ]; then
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
