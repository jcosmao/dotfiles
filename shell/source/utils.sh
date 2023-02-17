function display_256_colors ()
{
    for i in `seq 1 256`
    do
        tput setaf $i
        echo -n "$i "
    done
}

function json ()
{
    jq=$(which jq)
    if [[ -n $jq ]]; then
        $jq .
    else
        python -mjson.tool
    fi
}

function json2yaml ()
{
    python -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)'
}

function uuid ()
{
    grep -Po '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
}

# useful to parse docker json logs for ex:  docker logs bla | jqlines
function jqlines
{
    jq -Rr '. as $line | (fromjson?) // $line'
}

# same as jqlines, but interpret \n \t to display properly json value like long stacktrace
function jqlines_format
{
    jq -CRr '. as $line | (fromjson?) // $line' | sed -e 's/\\n/\n/g' -e 's/\\t/    /g'
}

function jqmap2csv
{
    jq -r '(.[0] | keys_unsorted) as $keys | ([$keys] + map([.[ $keys[] ]])) [] | @csv'
}

# csv to table display
function pretty_csv {
    column -t -s, -n "$@" | less -F -S -X -K
}

function open
{
    nohup xdg-open $* </dev/null >/tmp/open.log 2>&1 &
}

function ssl_info
{
    [[ -z $1 ]] && echo "need domain" && return

    echo -e "== brief info =="
    echo | openssl s_client -connect $1 -brief

    echo -e "\n== Chain Info =="
    echo | openssl s_client -showcerts -connect $1 2>&1 | \
        sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p;/-END CERTIFICATE-/a\\x0' | \
        sed -e '$ d' | xargs -0rl -I% sh -c "echo '%' | openssl x509 -subject -issuer  -fingerprint -sha1 -dates -noout"
}

function ssl_get
{
    [[ -z $1 ]] && echo "need domain" && return

    echo | \
        openssl s_client -showcerts -connect $1 </dev/null | \
        openssl x509 -text
}
