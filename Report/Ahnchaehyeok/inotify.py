import pyinotify
import os
from datetime import datetime

# 감시할 디렉토리 경로
watched_directory = '/path/to/watched/directory'

# 감시 이벤트 종류
mask = pyinotify.IN_CREATE | pyinotify.IN_ACCESS | pyinotify.IN_MODIFY

# 이벤트 핸들러 클래스 정의
class EventHandler(pyinotify.ProcessEvent):
    def process_event(self, event):
        event_type = None
        if event.mask & pyinotify.IN_CREATE:
            event_type = "Created"
        elif event.mask & pyinotify.IN_ACCESS:
            event_type = "Accessed"
        elif event.mask & pyinotify.IN_MODIFY:
            event_type = "Modified"

        file_path = os.path.join(event.path, event.name)
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        # 시간 정보와 함께 이벤트 출력 또는 기록
        log_message = f"{timestamp} - {event_type} - {file_path}"
        print(log_message)

# inotify 인스턴스 생성
wm = pyinotify.WatchManager()
handler = EventHandler()
notifier = pyinotify.Notifier(wm, handler)

# 감시할 디렉토리에 대한 이벤트 추가
wdd = wm.add_watch(watched_directory, mask, rec=True)

# 감시 시작
print(f"Watching directory: {watched_directory}")
notifier.loop()
