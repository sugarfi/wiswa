last=""
last2=""

function wiswa () {
    #if test (count $argv) != 0
    #    set query $argv[1]
    #else
    #    set query (read -p "echo 'query: '")
    #end

    limit=$(shuf -i 1-30 -n 1)
    n=$(shuf -i 1-$limit -n 1)
    id=$(ia search "subject:'$1'" --parameters "page=1&rows=$limit" | shuf -n 1 | jq .identifier | tr -d '"')
    if [ "$id" == "" ]
    then
        return
    fi
    meta=$(ia metadata $id)
    desc=$(echo $meta | jq "([ .. | .description? ] | map(select(.)) | map(sub(\"</?.+?>\"; \"\"; \"g\")) | map(sub(\"[^a-zA-Z ]\"; \"\"; \"g\")))[0]" | tr -d '"')
    if [ "$desc" == "null" ]
    then
        return
    fi
    file=$(echo $meta | jq "(.files | map(select(.name | test(\"\\\\.(jpg|png|wav|mp3|mp4|ogg|gif|bmp)\$\"))) | map(.name))[0]" | tr -d '"')
    # "
    ia download $id $file
    if [ ! -d "$id" ]
    then
        return
    fi
    filename=$(find $id -type f)
    if [[ $filename == *mp3 ]]
    then
        echo Trimming
        cp $filename "$filename"2
        rm $filename
        ffmpeg -i "$filename"2 -vn -acodec copy -ss 00:00:00 -t 00:00:30 $filename
        #sox $filename $filename trim 1 00:20
    fi
    if [[ $filename == *mp4 ]]
    then
        echo Trimming
        cp $filename "$filename"2
        rm $filename
        ffmpeg -i "$filename"2 -ss 00:00:00 -t 00:00:30 -vcodec copy -acodec copy $filename
    fi

    #convert $filename -resize 300x300 $filename
    curl -F file=@$filename $WEBHOOK_URL -q -s > /dev/null
    find . -type d -empty -not -path "./.git/*" | xargs rmdir 2>/dev/null

    old="$IFS"
    IFS="/"
    for item in $filename
    do
        rm -rf $item
    done
    IFS=$old

    words=( $desc )
    words=( $(shuf -e "${words[@]}") )
    for word in "${words[@]}"
    do
        echo $word $last $last2
        if [ "$word" != "$last" ]
        then
            if [ "$word" != "$last2" ]
            then
                last2=$last
                last=$word
                wiswa $word
            fi
        fi
    done
}

echo $GENESIS
wiswa "$GENESIS"
