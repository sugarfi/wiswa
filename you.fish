set last ""

function wiswa
    if test (count $argv) != 0
        set query $argv[1]
    else
        set query (read -p "echo 'query: '")
    end

    set id (ia search "subject:'$query'" --parameters "page=1&rows=1" | jq .identifier | tr -d '"')
    if test "$id" = ""
        return
    end
    set meta (ia metadata $id)
    set desc (echo $meta | jq "([ .. | .description? ] | map(select(.)) | map(sub(\"</?.+?>\"; \"\"; \"g\")) | map(sub(\"[^a-zA-Z ]\"; \"\"; \"g\")))[0]" | tr -d '"')
    if test "$desc" = null
        return
    end
    set file (echo $meta | jq "(.files | map(select(.name | test(\"\\\\.(jpg|png)\$\"))) | map(.name))[0]" | tr -d '"')
    ia download $id $file
    set real_filename (find $id -type f)
    set filename (string split '/' $real_filename)[-1]

    mv $real_filename $filename
    convert $filename -resize 300x300 $filename
    curl -F file=@$filename $WEBHOOK_URL -q
    rm $filename

    if string match -r ".+?/.+?" $real_filename
        rm -rf (string split '/' $real_filename)[1]
    end

    for word in (string split ' ' $desc)
        echo $word
        if test "$word" != "$last"
            wiswa $word
            set last $word
        end
    end
end

wiswa $argv
