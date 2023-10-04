#!/bin/bash

## A bash script to search Purdue Directory 'https://www.purdue.edu/directory/'

## Check if HTML-XML-Utils is installed
if ! brew list html-xml-utils &>/dev/null; then
   echo -e "Command not found! Install? (y/n) \c"
   read -r
   if [ "$REPLY" = "y" ]; then
        brew install html-xml-utils
   else
        echo "Could not install brew:html-xml-utils"
        exit 1
   fi
fi



## PARAMS
if [ $# -ne 1 ]; then
    echo "Usage: $0 <Name>"
    exit 1
fi

name="$1"
labels=("Name:" "Alias" "Email:" "Campus:" "School:" "Department:" "Department:" "Title:" "School:" "Vcard:")
counter=0

## Search Query
hxresult=$(curl -sS 'https://www.purdue.edu/directory/' --compressed -X POST --data-raw "SearchString=$name" | hxclean | hxnormalize -x | hxselect "#results" | hxselect -c -s '\n' 'h2.cn-name, a[href^="mailto:"], th.icon-key+td, th.icon-library+td, th.icon-sitemap, th.icon-sitemap+td, th.icon-briefcase+td, th.icon-graduation+td, th.icon-vcard')
echo
while IFS= read -r result; do
    # Process each result as needed
    if [[ "$result" == "" ]]; then
        echo "No Results Found"
    elif [[ "$result" == *"Qualified Name"* ]]; then
        ((counter=0))
        echo
    elif [[ "$result" == *"Department"* ]]; then
        ## Using HTML format as a way to differentite text - skip label
        ((counter+=2))

    else
        echo "${labels[$counter]} $result"
        ((counter++))
    fi
done <<< "$hxresult"
