#!/bin/bash

git commit -am "deploy arg from command line" && git push
jekyll build
cd _site && tar -czf b.tar.gz * --exclude=./*.gz && cd ..

#curl -i https://api.selcdn.ru/auth/v1.0 -H "X-Auth-User:${SEL_USER}" -H "X-Auth-Key:${SEL_PASS}"

shopt -s extglob # Required to trim whitespace; see below

while IFS=':' read -r key value; do
    value=${value##+([[:space:]])}; value=${value%%+([[:space:]])}

    case "$key" in
        x-auth-token*) SEL_TOKEN="$value"
          ;;
     esac
done < <(curl -i -q https://api.selcdn.ru/auth/v1.0 -H "X-Auth-User:${SEL_USER}" -H "X-Auth-Key:${SEL_PASS}")

curl -i -XPUT --progress-bar -q https://api.selcdn.ru/v1/SEL_"${SEL_ACCOUNT}"/"${SEL_CONTAINER}"/?extract-archive=tar.gz -H "X-Auth-Token: ${SEL_TOKEN}" -T _site/b.tar.gz

rm -rf _site

# or 7z -czf b.tar.gz * --exclude=./*.gz
#consider to use https://s3browser.com/
# выгрузить в селектел по логину и паролю.