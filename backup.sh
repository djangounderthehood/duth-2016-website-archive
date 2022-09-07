#!/bin/bash
set -euo pipefail

rm -rf _build
mkdir _build

cd _build

# Mirror the whole 2016 website, including some images stored in AWS
wget \
  --convert-links \
  --html-extension \
  --no-check-certificate \
  --no-parent \
  --page-requisites \
  --recursive \
  --user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36' \
  -w 0 \
  --restrict-file-names=windows \
  -H --domains 2016.djangounderthehood.com,duth-uploads.s3.amazonaws.com \
  http://2016.djangounderthehood.com \
  http://2016.djangounderthehood.com/static/img/stroopwafel.e16ffa43d092.png \
  http://2016.djangounderthehood.com/static/img/logo-watercolor.0d6bdc62a6d5.png \
  https://duth-uploads.s3.amazonaws.com/baptistek.jpg \
  https://duth-uploads.s3.amazonaws.com/ola_sendecka.jpg \
  https://duth-uploads.s3.amazonaws.com/201708_dcus-b_800px.jpg \
  https://duth-uploads.s3.amazonaws.com/kasia.jpg \
  https://duth-uploads.s3.amazonaws.com/ania2.jpg \
  https://duth-uploads.s3.amazonaws.com/agata.jpg \
  https://duth-uploads.s3.amazonaws.com/tomek.jpg \
  https://duth-uploads.s3.amazonaws.com/paul.jpg \
  https://duth-uploads.s3.amazonaws.com/rob.jpg \
  https://duth-uploads.s3.amazonaws.com/marc.jpg \
  https://duth-uploads.s3.amazonaws.com/ola_sitarska.jpg \
  || true


# Images from AWS include signatures, let's strip them
echo "Removing AWS signatures from images filenames..."
find duth-uploads.s3.amazonaws.com -name '*\@Signature*' | rename 's/@.*//'

# Move images from AWS to statics folder
cp -r duth-uploads.s3.amazonaws.com 2016.djangounderthehood.com/static/

# Replace all mentions to the AWS folder and strip signatures, all in one lovely line
echo "Removing AWS signatures image URL in HTML..."
grep -rl duth-uploads.s3.amazonaws.com . | xargs sed \
  -e 's/http:\/\/2016.djangounderthehood.com\/team\/&quot;https:\/\/duth-uploads.s3.amazonaws.com:443\//..\/static\/duth-uploads.s3.amazonaws.com\//' \
  -e 's/?Signature[^)]*//' \
  -e 's/\.\.\/duth-uploads.s3.amazonaws.com/static\/duth-uploads.s3.amazonaws.com/' \
  -e 's/@[^"]*//' -i ''

echo "Fixing HTTP -> HTTPS..."
grep -rl 'http://maxcdn.bootstrapcdn.com' | xargs sed -e 's/http:\/\/maxcdn.bootstrapcdn.com/https:\/\/maxcdn.bootstrapcdn.com/' -i ''
#grep -rl 'http://fonts.googleapis.com' | xargs sed -e 's/http:\/\/fonts.googleapis.com/https:\/\/fonts.googleapis.com/' -i ''
grep -rl 'http://brick.a.ssl.fastly.net' | xargs sed -e 's/http:\/\/brick.a.ssl.fastly.net/https:\/\/brick.a.ssl.fastly.net/' -i ''
#grep -rl 'http://use.typekit.net' | xargs sed -e 's/http:\/\/use.typekit.net/https:\/\/use.typekit.net/' -i ''
# grep -rl 'http://www.youtube.com' | xargs sed -e 's/http:\/\/www.youtube.com/https:\/\/www.youtube.com/' -i ''
grep -rl 'http://speakerdeck.com' | xargs sed -e 's/http:\/\/speakerdeck.com/https:\/\/speakerdeck.com/' -i ''
grep -rl 'http://www.slideshare.net' | xargs sed -e 's/http:\/\/www.slideshare.net/https:\/\/www.slideshare.net/' -i ''
#grep -rl 'http://platform.twitter.com' | xargs sed -e 's/http:\/\/platform.twitter.com/https:\/\/platform.twitter.com/' -i ''
echo 'Done.'

cd ..

mkdir -p docs
cp -r _build/2016.djangounderthehood.com/* docs/
