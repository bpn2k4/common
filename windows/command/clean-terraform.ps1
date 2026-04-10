Get-ChildItem -Recurse -Directory -Filter ".terraform"

Get-ChildItem -Recurse -Directory -Filter ".terraform" | Remove-Item -Recurse -Force
