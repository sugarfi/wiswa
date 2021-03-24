function wiswa () {
    query=$1
    #if test (count $argv) != 0
    #    set query $argv[1]
    #else
    #    set query (read -p "echo 'query: '")
    #end

    id=$(ia search "subject:'$query'" --parameters "page=1&rows=1" | jq .identifier | tr -d '"')
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
    file=$(echo $meta | jq "(.files | map(select(.name | test(\"\\\\.(jpg|png)\$\"))) | map(.name))[0]" | tr -d '"')
    ia download $id $file
    filename=(find $id -type f)

    #convert $filename -resize 300x300 $filename
    curl -F file=@$filename $WEBHOOK_URL -q

    old="$IFS"
    IFS="/"
    for item in $filename
    do
        rm -rf $item
    done
    IFS=$old


    last=""
    for word in $desc
    do
        echo $word
        if [ "$word" != "$last" ]
        then
            wiswa $word
            last=$word
        fi
    done
}

wiswa $argv
