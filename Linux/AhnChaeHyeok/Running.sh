#!/bin/bash
# 운영체제 x86bit를 확인하여 스크립트를 실행
# 32bit, 64bit에 각각 사용할 스크립트를 분리해 pc의 bit에 맞는 스크립트가 실행될 수 있도록 만들어야 함

ARCH=$(getconf LONG_BIT)

if [ "$ARCH" = "64" ]; then
	echo Run 64bit Version
	chmod +x ./forensics_64.sh
	./forensics_64.sh
else
	echo Run 32bit Version
	chmod +x ./forensics_32.sh
	./forensics_32.sh
fi
