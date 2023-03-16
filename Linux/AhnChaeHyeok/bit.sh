#!/bin/bash

ARCH=$(getconf LONG_BIT)

if [ "$ARCH" = "64" ]; then
	echo 64bit
else
	echo 32bit
fi
