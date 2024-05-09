#!/bin/bash

sudo chown -R ubuntu:ubuntu /home/ubuntu/workspace

code-server --host 0.0.0.0 --port 8080 --auth none --user-data-dir /home/ubuntu