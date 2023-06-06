#include <windows.h>
#include <tchar.h>

int main(void)
{
    DWORD dwSize = MAX_PATH * sizeof(TCHAR);
    TCHAR szLogicalDrives[MAX_PATH] = { 0 };
    DWORD dwResult = GetLogicalDriveStrings(dwSize, szLogicalDrives);

    if (dwResult > 0 && dwResult <= MAX_PATH)
    {
        TCHAR* szSingleDrive = szLogicalDrives;
        while (*szSingleDrive)
        {
            // 다음 드라이브 문자열이 있는지 확인합니다.
            TCHAR* szNextDrive = szSingleDrive + _tcslen(szSingleDrive) + 1;

            // szSingleDrive는 드라이브 문자를 가리킵니다.
            // 다음 드라이브 문자열이 있으면 ", "를 출력하고, 없으면 개행 문자를 출력합니다.
            _tprintf(_T("%s%s"), szSingleDrive, *szNextDrive ? _T(", ") : _T("\n"));

            // 다음 드라이브 문자로 이동합니다.
            szSingleDrive = szNextDrive;
        }
    }

    return 0;
}