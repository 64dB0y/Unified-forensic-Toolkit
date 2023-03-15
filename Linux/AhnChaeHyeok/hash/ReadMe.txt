리눅스에서 사용할 수 있습니다.

직접 컴파일 하기 위해서는 아래가 준비되어야 합니다.

-사전 설치사항-
sudo apt-get update && sudo apt-get install libssl-dev

-컴파일 방법-
gcc -o hash.exe main.c -lssl -lcrypto
