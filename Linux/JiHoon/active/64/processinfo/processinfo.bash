#!/bin/bash

#아래는 ps, top, htop, pstree, pgrep, kill 명령어를 이용하여 프로세스 정보를 수집하는 bash 스크립트입니다.

# Using ps command
ps -ef > ps_info.txt

# Using top command
top -b -n 1 > top_info.txt

# Using htop command
htop -C > htop_info.txt

# Using pstree command
pstree -paul > pstree_info.txt

# Using pgrep command
pgrep -a bash > pgrep_info.txt

# Using kill command
#kill -0 PID > kill_info.txt

#위 스크립트에서 마지막 줄의 "PID"는 종료시키고자 하는 프로세스의 식별자(PID)로 대체되어야 합니다. 이 스크립트를 실행하면, 각각의 명령어 결과를 파일로 저장할 것입니다. 파일 이름과 저장 경로를 자신이 원하는 것으로 바꿀 수 있습니다.


# --------------------------------------------------------------------------------------------------
# htop
#htop는 시스템 상태를 실시간으로 모니터링하는 프로세스 관리 도구이며, 기본적으로 설치되어 있지 않을 수 있습니다. 따라서 htop을 사용하기 위해서는 먼저 설치해야 합니다.
#Ubuntu/Debian 계열에서는 다음과 같은 명령어로 설치할 수 있습니다.

#sudo apt-get install htop

#CentOS/RHEL 계열에서는 다음과 같은 명령어로 설치할 수 있습니다.

#sudo yum install htop

#설치 후에는 htop 명령어를 사용할 수 있습니다.






