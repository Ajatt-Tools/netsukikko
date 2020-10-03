#!/bin/bash
regexsh() {
    # this nice regex shell converter created by Luis C - https://github.com/luiscassih/RegeXNumRangeGenerator
    numStart="$1"
    numEnd="$2"


    # returns to a resultFromStart variable
    fromStart()
    {
        resultFromStart="$1"
        for (( i=${#resultFromStart}-1; i>=0 ;i--)); do
            if [ "${resultFromStart:$i:1}" == "0" ]; then
                resultFromStart=$(echo ${resultFromStart:0:$i}"9"${resultFromStart:$i+1})
            else
                resultFromStart=$(echo ${resultFromStart:0:$i}"9"${resultFromStart:$i+1})
                break
            fi
        done
    }

    # returns to a resultFromEnd variable
    fromEnd()
    {
        resultFromEnd="$1"
        for (( i=${#resultFromEnd}-1; i>=0 ;i--)); do
            if [ "${resultFromEnd:$i:1}" == "9" ]; then
                resultFromEnd=$(echo ${resultFromEnd:0:$i}"0"${resultFromEnd:$i+1})
            else
                resultFromEnd=$(echo ${resultFromEnd:0:$i}"0"${resultFromEnd:$i+1})
                break
            fi
        done
    }

    leftBounds()
    {
        leftBoundsStart="$1"
        leftBoundsEnd="$2"
        while ((leftBoundsStart < leftBoundsEnd )); do
            fromStart $leftBoundsStart
            result+=("$leftBoundsStart")
            result+=("$resultFromStart")
            leftBoundsStart=$((resultFromStart + 1))
        done
    }

    rightBounds()
    {
        rightBoundsStart="$1"
        rightBoundsEnd="$2"
        while ((rightBoundsStart < rightBoundsEnd )); do
            fromEnd $rightBoundsEnd
            rightBoundsResult+=("$rightBoundsEnd")
            rightBoundsResult+=("$resultFromEnd")
            rightBoundsEnd=$((resultFromEnd - 1))
        done
    }


    result=()

    #get leftBounds
    leftBounds $numStart $numEnd

    #remove last from left bounds
    unset result[${#result[@]}-1]

    #get rightBounds
    rightBoundsResult=()
    rightBounds ${result[@]: -1} $numEnd
    #remove last from right bounds
    unset rightBoundsResult[${#rightBoundsResult[@]}-1]

    #echo ${rightBoundsResult[@]}

    #reverse right bounds and join them to left bounds
    for (( i=${#rightBoundsResult[@]}-1; i>=0; i-- )); do
        result+=("${rightBoundsResult[i]}")
    done

    parsedRegex=""
    for (( i=0; i<=${#result[@]}-1;i=i+2 )); do
        #echo "${result[@]:$i:1} and ${result[@]:$i+1:1}"
        if (( i>0 )); then
            parsedRegex=$parsedRegex"|"
        fi
        currentChar="${result[@]:$i:1}"
        currentNextChar="${result[@]:$i+1:1}"
        for ((j=0;j<=${#currentChar}-1;j++)); do
            if [ ${currentChar:$j:1} == ${currentNextChar:$j:1} ]; then
                parsedRegex=$parsedRegex"${currentChar:$j:1}"
            else
                parsedRegex=$parsedRegex"[${currentChar:$j:1}-${currentNextChar:$j:1}]"
            fi
        done
    done
    echo "($parsedRegex)"
}

nosquare=$(echo "$1" | sed 's/_/ /g;s/\(.*\)- .*/\1/;s/[0-9]//g;s/\[[^]]*\]//g;s/[0-9]//g;s/([^)]*)//g;s/\.[^.]*$//;s/^ *//g;s/ *$//' | sort -nf | uniq -ci | sort -nr | head -n1 | awk '{ print substr($0, index($0,$2)) }' | sed 's/ /%20/g')
anime=$(curl -s "https://kitsu.io/api/edge/anime?filter\[text\]=$nosquare&page\[limit\]=1&page\[offset\]=0" | grep -o "canonicalTitle\":\".*" | sed -n 's/\(,\).*/\1/p'|  cut -d':' -f 2- | sed 's/^\"//;s/,$//;s/\"$//;s/-.*$//;s/^ *//;s/ *$//' | sed 's/[[:punct:]]\+//g;s/ /.*/g')
episode=$(echo "$1"  |  sed 's/\[[^]]*\]//g;s/([^)]*)//g;s/\.[^.]*$//;s/^ *//g;s/ *$//' | awk '{print $NF}' )
grepisode=$(echo "$episode" | sed 's/0/\.\*/g')
nulno=$(echo "$episode" | sed 's/^0*//')
emin=$((nulno - 1))
emax=$((nulno + 1))
emin=$(regexsh 0 $emin) #| sed 's/(/(?:/')
emax=$(regexsh $emax 9999) # | sed 's/(/(?:/')
epigrep="$emin-.*$emax"
ws=$(curl -s 'https://kitsunekko.net/dirlist.php?dir=subtitles%2Fjapanese%2F' | grep -i "$anime" | sed -n 's/.*href="\([^"]*\).*/\1/p' | sed 's/^/https:\/\/kitsunekko.net/' | head -n1 )
ws=$(curl -s "$ws")
choose=$(echo "$ws" |  grep "<strong>" | sed 's/^.*<strong>//;s/<\/strong>.*$//' | sed -e 's/\<00*\([1-9]\)/.*\1/g' | grep -E "$grepisode|$epigrep" | awk -v 'expr=srt:ass:zip:rar' 'BEGIN { n=split(expr, e, /:/);for(i=i; i<=n; ++i) m[i]="" }{ for(i=1; i<=n; ++i) if ($0 ~ e[i]) {m[i]=m[i] $0 ORS; next } }END { for (i=1; i<=n; ++i) printf m[i] }' | head -n1)
if echo "$choose" | grep -q ".srt$\|.ass$"; then
    link=$(echo "$ws" | grep "$choose"  | sed -n 's/.*href="\([^"]*\).*/\1/p' | sed 's/^/https:\/\/kitsunekko.net\//' | head -n1)
    name=$(echo "$choose" | sed 's/\.\*/0/g')
    echo "$name"
    ext=${choose##*.}
    curl -sL "$link" -o "$1"."$ext"
elif echo "$choose" | grep -q ".zip$\|.rar$"; then
    link=$(echo "$ws" | grep "$choose"  | sed -n 's/.*href="\([^"]*\).*/\1/p' | sed 's/^/https:\/\/kitsunekko.net\//' | head -n1)
    name=$(echo "$choose" | sed 's/\.\*/0/g')
    echo "$name"
    curl -sLO "$link"
    echo "Archive downloaded"
fi


