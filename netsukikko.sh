#!/bin/bash

lang="japanese"

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
    unset result[${#result[@]}-1] 2>/dev/null

    #get rightBounds
    rightBoundsResult=()
    rightBounds ${result[@]: -1} $numEnd
    #remove last from right bounds
    unset rightBoundsResult[${#rightBoundsResult[@]}-1] 2>/dev/null

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

if [[ "$2" == "-mpv" ]] ; then
	mpv="1"
else
	mpv="0"
fi

nosquare=$(echo "$1" | sed 's/_/ /g;s/\(.*\)- .*/\1/;s/[0-9]//g;s/\[[^]]*\]//g;s/[0-9]//g;s/([^)]*)//g;s/\.[^.]*$//;s/^ *//g;s/ *$//' | sort -nf | uniq -ci | sort -nr | head -n1 | awk '{ print substr($0, index($0,$2)) }' | sed 's/ /%20/g')
anime=$(curl -s "https://kitsu.io/api/edge/anime?filter\[text\]=$nosquare&page\[limit\]=1&page\[offset\]=0" | grep -o "canonicalTitle\":\".*" | sed -n 's/\(,\).*/\1/p'|  cut -d':' -f 2- | sed 's/^\"//;s/,$//;s/\"$//;s/-.*$//;s/^ *//;s/ *$//;s/TV//' | sed 's/[[:punct:]]\+//g;s/ /.*/g')
episode=$(echo "$1"  |  sed 's/\[[^]]*\]//g;s/([^)]*)//g;s/\.[^.]*$//;s/^ *//g;s/ *$//' | grep -o "[[:digit:]]*" | tail -n1 | awk '{print $NF}' )
grepisode=$(echo "$episode" | sed 's/^0*/\.\*/g')
nulno=$(echo "$episode" | sed 's/^0*//')
emin=$((nulno - 1))
emax=$((nulno + 1))
emin=$(regexsh 0 $emin) #| sed 's/(/(?:/')
emax=$(regexsh $emax 9999) # | sed 's/(/(?:/')
epigrep="$emin-.*$emax"
ws=$(curl -s https://kitsunekko.net/subtitles/$lang/ | grep -i "$anime"  | sed -n 's/.*href="\([^"]*\).*/\1/p' | sed "s/^/https:\/\/kitsunekko.net\/subtitles\/$lang\//" | head -n1)
ws=$(curl -s "$ws")
choose=$(echo "$ws" |  grep "^<li>"| sed 's/^.*> //;s/<.*$//;s/_/ /g'| sed -e 's/\([0]\)/.*/g;s/[[:digit:]]\+[x×X][[:digit:]]\+/.*/g;s/[xX]26[45]/.*/g' | grep -E "$grepisode|$epigrep" | grep -v "[[:digit:]]\\$grepisode[[:digit:]]\|[[:digit:]]\\$grepisode\|\\$grepisode[[:digit:]]" | awk -v 'expr=srt:ass:zip:rar' 'BEGIN { n=split(expr, e, /:/);for(i=i; i<=n; ++i) m[i]="" }{ for(i=1; i<=n; ++i) if ($0 ~ e[i]) {m[i]=m[i] $0 ORS; next } }END { for (i=1; i<=n; ++i) printf m[i] }' | head -n1| sed 's/\[/\\[/g;s/\]/\\]/g' | sed 's/ /./g')
if echo "$choose" | grep -q ".srt$\|.ass$"; then
    all=$(echo "$ws" | grep "$choose")
    link=$(echo "$all" | sed -n 's/.*href="\([^"]*\).*/\1/p' | sed "s/^/https:\/\/kitsunekko.net\/subtitles\/$lang\//" | head -n1)
    name=$(echo "$all" | sed 's/^.*> //' | grep -o "$choose")
    echo "$name"
    if [[ "$mpv" == "1" ]] ; then
	    ext=${choose##*.}
	    curl -sL "$link" -o "$1"."$ext"
    else
	    echo "$link"
    fi

elif echo "$choose" | grep -q ".zip$\|.rar$"; then
    all=$(echo "$ws" | grep "$choose")
    link=$(echo "$all" | sed -n 's/.*href="\([^"]*\).*/\1/p' | sed "s/^/https:\/\/kitsunekko.net\/subtitles\/$lang\//" | head -n1)
    name=$(echo "$all" | sed 's/^.*> //' | grep -o "$choose")
    echo "$name"
    if [[ "$mpv" == "1" ]] ; then
	    ext=${choose##*.}
	    curl -sL "$link" -o "/tmp/chmonime.$ext"
	    number=$(7z l -slt "/tmp/chmonime.$ext"  | grep "^Path =" | sed 's/^Path = //' | grep "$episode" | head -n1)
	    subext=${number##*.}
	    7z e -so "/tmp/chmonime.$ext" "$number" -r > "$1"."$subext"
    else
	    echo "$link"
    fi
fi
