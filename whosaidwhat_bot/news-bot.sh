#!/bin/bash

cd whosaidwhat_bot/;

#geturl="cnn.com";
geturl=$1

# getting content
lynx -dump -width=990 -nolist http://$geturl | grep -E " said | says | say | Said | Says | Say " | tr -d '*' | while read -r phrase; do
echo 'do';
echo $phrase;

crc=$(crc32 <(echo -n $phrase));
touch tally.txt

# already done loop
ifyes=$(grep $crc bak/tally*.txt | wc -l)
if [ $ifyes -gt 0 ]
	then echo "already done";
	else 


# clean leading " blah" 
phrase0a=$(echo $phrase | sed -r 's/^\s//');
# clean final "blah " 
phrase0b=$(echo $phrase0a | sed -r 's/\s$//');
# clean "blah blah icon-video.gif" strings 
phrase2a=$(echo $phrase0b | sed -r 's/(\w*-)?\w*\....$//');
# clean bullets "1. 1Blah"
phrase2b=$(echo $phrase2a | sed -r 's/[0-9]\.\s[0-9]//');
# clean leading "-" or " -"
phrase2c=$(echo $phrase2b | sed -r 's/^\-||^\s\-//');
# clean final - junk "blah - 6 hours || - Reuters"
phrase2d=$(echo $phrase2c | sed -r 's/(.*)(\s\-\s.*)/\1/');
# clean final date "blah blah12345678 1234"
phrase2e=$(echo $phrase2d | sed -r 's/[0-9]{,8}\s[0-9]{,4}$//');
# clean final timestamp "blah 2:44pm EST"
phrase2f=$(echo $phrase2e | sed -r 's/[0-9]{1,2}\:[0-9]{,2}(am|pm)\s[A-Z]{,4}//');
# clean starting location "NEW YORK, Ky. - blah"
phrase2g=$(echo $phrase2f | sed -r 's/^\s\s\s[A-Z]*(\s[A-Z]*)?(,.*)?\s\-\s//');
# clean links, kills everything after "blah http://t.co/ljdsf/123.html"
phrase2=$(echo $phrase2g | sed -r 's/http.*//');

# strip all chars except safe stuff
phrase3=$(echo $phrase2 | tr -dc ". [:alnum:]-\n");

echo 'whowhat';
string1=$(echo $phrase3 | sed -e 's/\(.*\)\( said \| says \| say \| Said \| Says \| Say \)\(.*\)/\1/');
string2=$(echo $phrase3 | sed -e 's/\(.*\)\( said \| says \| say \| Said \| Says \| Say \)\(.*\)/\3/');
c1=$(echo ${#string1});
c2=$(echo ${#string2});

if [ $c1 -gt $c2 ]
	then 
		who=$string2;
		saidwhat=$string1;
	else 
		who=$string1;
		saidwhat=$string2;
fi

echo $string1 $string2;
echo $who $saidwhat;

# too long loop
iflong=$(echo $saidwhat | wc -w);
if [ $iflong -gt 14 ]
	then echo "too long";
	else

# OK, let's go!
echo 'getting';

# getting first image URL
imageURL=$(wget -qO- "http://images.google.com/images?q=$who" -U "Firefox on Ubuntu Gutsy: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.14) Gecko/20080418 Ubuntu/7.10 (gutsy) Firefox/2.0.0.14" | grep -Po '^.*?\K(?<=src\=\"http://).*?(?=\"\ w)');
echo $imageURL;

time=$(date +%Y%m%d);
timenice=$(date +%Y/%m/%d);
echo $timenice;

# imageURL=t0.gstatic.com/images?q=tbn:ANd9GcSVcCN3mcnthFuvaHkRqSO53BdvHr9iTuHyhiBtsCsVeiTH1ksxUILJ74Lp
wget -O "image-$time-a.jpg" http://$imageURL;

# enlarging and adding caption

echo 'a > big'

width=$(identify -ping -format '%W');
height=$(identify -ping -format '%H');
if [ $width > 150 ]
	then convert -resize 300% "image-$time-a.jpg" "image-$time-big.jpg";
	else convert -resize 250% "image-$time-a.jpg" "image-$time-big.jpg";
fi

echo 'bubble';
saidtext=$(echo $saidwhat | sed -E "s/(([^ ]+ ){2})/&\n/g");
convert -gravity North -font Helvetica -pointsize 43 -annotate +200+40 "${saidtext^}!" word-bubble-hi.png "image-$time-bub-a.png";
saidurl=$(echo $geturl | tr '[:lower:]' '[:upper:]' | cut -d/ -f1);
convert -gravity NorthWest -font Courier-Bold -pointsize 24 -annotate +20+20 "$saidurl $timenice" "image-$time-bub-a.png" "image-$time-bub.png";

saidphrase=$(echo $phrase | sed -E "s/(([^ ]+ ){7})/&\n/g");
echo 'bub > bg';
convert -gravity South -font Courier-Bold -pointsize 28 -annotate +0+0 "$saidphrase" "image-$time-bub.png" "image-$time-bg.png";

echo 'bg + big = cap';
composite -gravity West "image-$time-big.jpg" "image-$time-bg.png" "image-$time-cap.png";

echo 'cap + texture = fin';
composite -gravity center "image-$time-cap.png" word-bubbgle-whitebg.png "image-$time-$crc-fin.jpg";

mv "image-$time-$crc-fin.jpg" images/

# remove whitespace for hashtag
# https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-bash-variable
whonospace=$(echo $who | tr -d ' ');
echo -e "${time} ${crc} $whonospace" >> tally.txt;

cp tally.txt bak/tally-$time-$saidurl.txt;

fi # /loop - already done
fi # /loop - too long
done

echo 'done';
