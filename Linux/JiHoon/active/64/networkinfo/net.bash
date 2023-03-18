#!/bin/bash

# Get the current network connections
connections=$(netstat -tulpn)

# Save the output to a file
echo "$connections" > network_connections.txt

# Display the content of the file
cat network_connections.txt

#리눅스에서 네트워크 연결 정보를 수집하기 위해서는 netstat 명령어를 사용할 수 있습니다. 다음은 netstat 명령어를 이용해 현재 열려있는 네트워크 연결의 상태를 수집하는 bash 스크립트 예제입니다:

