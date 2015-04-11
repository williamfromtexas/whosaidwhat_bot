#!/bin/sh

cd whosaidwhat_bot/;

# remove blank line from last run
grep -v '^$' tally.txt > tally1.txt;

# get data
input=$(shuf -n 1 tally1.txt);

# remove data from list
# improper use of cat XD
cat tally1.txt | sed "s/$input//" > tally2.txt;

rm tally.txt;

rm tally1.txt;
mv tally2.txt tally.txt;

#fire!
echo "var imagedate = '$(echo $input | cut -d' ' -f1)';" > img-to-tweet.js;
echo "var imagehash = '$(echo $input | cut -d' ' -f2)';" >> img-to-tweet.js;
echo "var imagewho = '$(echo $input | sed -E 's/(([^ ]+ ){2})(.*)/\3/')';" >> img-to-tweet.js;
echo "exports.imagedate = imagedate; exports.imagewho = imagewho; exports.imagehash = imagehash;" >> img-to-tweet.js;

echo $(cat img-to-tweet.js);

/usr/bin/nodejs bot.js;

echo "done!";
