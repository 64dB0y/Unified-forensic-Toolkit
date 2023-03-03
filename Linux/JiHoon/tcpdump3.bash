#!/bin/bash

# 자신의 인터페이스 이름을 자동으로 알아내어 변수에 저장하는 함수
get_interface_name() {
    # ip 명령어로 인터페이스 이름 조회
    # grep 명령어로 루프백 주소 제외한 첫 번째 인터페이스 이름 추출
    interface=$(ip link show | grep -v 'LOOPBACK' | grep -oP '(?<=: ).*(?=: )' | head -1)
    
    # 인터페이스 이름이 비어있는 경우 에러 메시지 출력 후 스크립트 종료
    if [ -z "$interface" ]; then
        echo "Failed to get interface name. Please check your network configuration."
        exit 1
    fi
}

# 캡쳐할 인터페이스 이름을 알아내기 위해 get_interface_name 함수 호출
get_interface_name

# 필요한 정보를 추출하기 위한 정규표현식
# 예시: IP 주소, MAC 주소, 포트 번호
regex="IP.* >.*: |MAC.* >.*: |port [0-9]+"

# tcpdump 명령어로 패킷 캡쳐 후 필요한 정보만 추출하여 출력
sudo tcpdump -i $interface | grep -oE "$regex" > "./tcpdump3.txt"

