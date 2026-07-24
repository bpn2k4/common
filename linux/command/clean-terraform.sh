find . -type d -name ".terraform"

find . -type d -name ".terraform" -prune -exec rm -rf {} +

find . -type f -name ".terraform.lock.hcl"

find . -type f -name ".terraform.lock.hcl" -prune -exec rm -rf {} +
