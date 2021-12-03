# Bitbucket 2 Github

Migrates all bitbucket repos in an org to github org.  

- has an exclude list for skipping some bitbucket repos.
- will skip over repos that have the same name and already exist in github.
- Does not delete the repos in bitbucket.

## Prerequisites

- Be able to clone repos from bitbucket and create repos in github.
- Install jq https://stedolan.github.io/jq/download/
- Create a .env file with the following value.
  ```bash
  GH_TOKEN=<personal access token>
  GH_USERNAME=<user>
  GH_ORGANIZATION=<target org> 
  
  BB_USERNAME=<user>
  BB_PASSWORD=<password>
  BB_ORGANIZATION=<source org>
  ```

## Run it

```bash
./bb2gh.sh
```
