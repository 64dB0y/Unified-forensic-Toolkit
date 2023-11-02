import os
import subprocess

# 시작 디렉토리 (최상위 폴더)
start_directory = os.getcwd()  # 시작 디렉토리 경로로 변경

# 재귀적으로 디렉토리를 탐색하고 Python 스크립트 실행
for root, dirs, files in os.walk(start_directory):
    for file in files:
        if file.endswith(".py"):
            script_path = os.path.join(root, file)

            # 실행 중인 스크립트 자체를 실행하지 않도록 예외 처리
            if script_path != __file__:
                result = subprocess.run(["python", script_path, "input.txt", "output.pdf"], stdout=subprocess.PIPE,
                                        stderr=subprocess.PIPE)
                print(f"스크립트 '{script_path}' 실행 결과:")
                print("표준 출력:", result.stdout)
                print("에러 출력:", result.stderr)
                print("리턴 코드:", result.returncode)
