lsimages () {
    curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $dotok" "https://api.digitalocean.com/v2/images?page=1&per_page=1000&type=distribution" | jq
}
