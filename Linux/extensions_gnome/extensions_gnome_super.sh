#/bin/bash
source ../variables.sh

Main_extensions() {
    download_extension() {
        request_url="https://extensions.gnome.org/extension-info/?pk=$1&shell_version=$(gnome-shell --version | cut --delimiter=' ' --fields=3 | cut --delimiter='.' --fields=1,2)"
        http_response="$(curl -s -o /dev/null -I -w "%{http_code}" "$request_url")"
        if [ "$http_response" = 404 ]; then
            continue
        fi
        ext_info="$(curl -s "$request_url")"
        direct_dload_url="$(echo "$ext_info" | jq -r '.download_url')"
        download_url="https://extensions.gnome.org"$direct_dload_url
        filename="$(basename "$download_url")"
        wget "$download_url"
    }

    if [ ! -d $REPO_DIR/gnome_extensions_list ]; then
        mkdir -p $REPO_DIR/gnome_extensions_list
    fi
    cd $REPO_DIR/gnome_extensions_list

    if [ "$os_id" == "fedora" ]; then
        extensions=('3628' '1160' '3843' '3010' '4679' '3733' '6272' '6682')
    elif [ "$os_id" == "rhel" ]; then
        extensions=('1486' '3088' '3628' '4679' '1082' '3843' '120' '3733' '5219' '1460' '4670' '1160' '6272')
    fi
    for i in "${extensions[@]}"; do
        download_extension "$i"
    done

    chown -R $user_current:$user_current $REPO_DIR/gnome_extensions_list
}

check_and_run Main_extensions
