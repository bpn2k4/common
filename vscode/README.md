## Visual Studio Code in Browser

### Build docker image

```bash
sudo chmod +x start.sh
docker build -t vscode .
```

### Quick run

```bash
docker run -dp 8080:8080 -v ./data:/home/ubuntu vscode
```

### Run by docker compose

```bash
docker compose up -d
```

### Install extension

```bash
cp /opt/install-extension.sh .
sudo chmod +x install-extension.sh
./install-extension.sh
rm -rf install-extension.sh
```