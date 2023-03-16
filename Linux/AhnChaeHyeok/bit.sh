#!/bin/bash
# 운영체제 x86bit를 확인하는 스크립트
# 32bit, 64bit에 각각 사용할 스크립트를 분리해 pc의 bit에 맞는 스크립트가 실행될 수 있도록 만들어야 함

ARCH=$(getconf LONG_BIT)

if [ "$ARCH" = "64" ]; then
	echo 64bit
else
	echo 32bit
fi
