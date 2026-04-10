find . -type d -name ".terraform"

find . -type d -name ".terraform" -prune -exec rm -rf {} +
