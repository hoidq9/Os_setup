#!/bin/bash
mkdir -p data/{postgres,mysql,mssql,cloudbeaver}
podman unshare chown 10001:10001 -R ./data/mssql
podman-compose up
