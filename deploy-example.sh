#!/usr/bin/env bash

set -x

git fetch origin master:master

stashed=$(git stash -u)
echo $stashed

pages_folder=$(pwd)

cd $(mktemp -d)
git clone $pages_folder . --branch master

yarn install --pure-lockfile

NODE_ENV=production \
    PUBLIC_URL=https://pinterest.github.io/bonsai/analyze/ \
    REACT_APP_API_LIST_ENDPOINT=/bonsai/example-index.json \
    REACT_APP_EXTERNAL_URL_PREFIX= \
    yarn run build

rm -Rf "$pages_folder/analyze"
mv build "$pages_folder/analyze"

rm -Rf "$pages_folder/storybook"
yarn run build-storybook -- -o "$pages_folder/storybook"

NODE_ENV=production \
    ./node_modules/webpack/bin/webpack.js --json \
    --config ./node_modules/react-scripts/config/webpack.config.prod.js > "$pages_folder/example.json"

rm -rf $(pwd)

cd $pages_folder

git add -A .
git commit -m 'Push the latest Bonsai version to gh-pages with example.json'
git push origin

if ! [[ $stashed == 'No local changes'* ]]; then
    git stash pop
fi
