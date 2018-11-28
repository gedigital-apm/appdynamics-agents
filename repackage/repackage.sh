#!/bin/bash

destination="https://raw.githubusercontent.com/gedigital-apm/appdynamics-agents/master"

output_dir="./dist"
index_filename="index.yml"

rm -rf "$output_dir"

curl --create-dirs -o "$output_dir/$index_filename" -sSL "https://packages.appdynamics.com/java/index.yml" -H "user-agent: Ruby" -H "accept-encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3" -H "accept: /"

while IFS='' read -r target || [[ -n "$target" ]]; do

    echo "Processing target '$target'"

    targetUrl=`sed -n -e "/^$target:/p" $output_dir/$index_filename`
    targetUrl="${targetUrl//$target: /}"

    if [ "$targetUrl" == '' ]
    then
        echo "    ERROR: TARGET '$target'. Skipping..."
        continue
    fi

    agent_filename="${targetUrl##*/}"
    echo "    Downloading $agent_filename from $targetUrl"
    curl --create-dirs -o "$output_dir/$agent_filename" -sSL "$targetUrl"
    echo "    Done downloading"

    agent_folder=$(echo $agent_filename | rev | cut -f 2- -d '.' | rev)
    echo "    Unzipping '$output_dir/$agent_filename' to '$output_dir/$agent_folder'"
    unzip -o "$output_dir/$agent_filename" -d "$output_dir/$agent_folder" > /dev/null 2>&1
    rm -f "$output_dir/$agent_filename"

    config_file="app-agent-config.xml"
    echo "    Copying over $config_file..."
    cp -f "$config_file" $output_dir/$agent_folder/ver*/conf/$config_file

    echo "    Zipping '$output_dir/$agent_filename' to '$output_dir/$agent_folder'"
    cd "$output_dir/$agent_folder"
    zip -r "../$agent_filename" * > /dev/null 2>&1
    cd "../.."
    rm -rf "$output_dir/$agent_folder"

    echo "    Updating $index_filename..."
    sed -i "" "s,$targetUrl,$destination/$agent_filename,g" "$output_dir/$index_filename"

    echo "    COMPLETED TARGET '$target'"

done < "targets.txt"
