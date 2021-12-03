#!/bin/bash

# don't process these repositories
ignore_list=("springboard" "springboard-library" "springboard-sites")

# how many pages of repositories to process
pages=2

if [ -f .env ]
then
    export $(cat .env | xargs)
else
    echo ".env file not found"
    exit 1
fi

set -e
mkdir -p repos
# iterate 2 times
for page in {1..$pages}
do
    repos=$(curl -s --user $BB_USERNAME:$BB_PASSWORD https://api.bitbucket.org/2.0/repositories/$BB_ORGANIZATION\?pagelen\=100\&page\=$page | jq ".values[].full_name" -r)
    for org_repo in $repos
    do
        repo_name=${org_repo#"$BB_ORGANIZATION/"}
        if [ ! -d repos/$repo_name ]; then
            # skip ignored repos
            if [[ ! " ${ignore_list[@]} " =~ " ${repo_name} " ]]; then
                echo "Syncing $BB_ORGANIZATION/$repo_name"
                
                git clone -q --bare git@bitbucket.org:$org_repo repos/$repo_name
                existCode=$(curl --write-out '%{http_code}' --silent --output /dev/null --user $GH_USERNAME:$GH_TOKEN https://api.github.com/repos/$org_repo)
                # check for 404
                if [ "$existCode" != "404" ]; then
                    echo "Skipping as exists in github already"
                else
                    curl -s -u $GH_USERNAME:$GH_TOKEN https://api.github.com/orgs/$GH_ORGANIZATION/repos -d "{\"name\": \"$repo_name\", \"private\": true}" | jq ".html_url" -r
                    cd repos/$repo_name
                    git push --quiet --mirror git@github.com:$GH_ORGANIZATION/$repo_name.git
                    cd ../..
                fi
            else
                echo "Skipping dangerous $repo_name"
            fi
        else
            echo "Skipping existing $repo_name"
        fi
        break
    done
done
rm -rf repos