# faraday-poc

## Check your Github PAT is working

```console
curl --request GET \
--url "https://api.github.com/octocat" \
--header "Authorization: Bearer $GITHUB_PAT" \
--header "X-GitHub-Api-Version: 2022-11-28
```
