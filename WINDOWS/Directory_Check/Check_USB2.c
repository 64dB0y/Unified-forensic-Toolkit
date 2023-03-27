#include <fcntl.h>
#include <io.h>
#include <windows.h>
#include <stdio.h>
#include <locale.h>

int wmain()
{
    // 윈도우 콘솔 폰트를 설정하는 부분입니다.
    CONSOLE_FONT_INFOEX cfi;
    cfi.cbSize = sizeof(cfi);
    cfi.nFont = 0;
    cfi.dwFontSize.X = 0;
    cfi.dwFontSize.Y = 16;
    cfi.FontFamily = FF_DONTCARE;
    cfi.FontWeight = FW_NORMAL;
    wcscpy_s(cfi.FaceName, LF_FACESIZE, L"Lucida Console");

    // (Volume Name) (Device Name) (Mount Point) 문자열을 출력합니다.
    wprintf(L"\t\t\tVolume Name\t\t\tDevice Name\tMount Point\n");

    WCHAR szVolumeName[MAX_PATH];
    // Windows API를 이용해 볼륨 이름을 가져온 뒤, QueryDosDeviceW 함수를 이용해 장치 이름을 가져옵니다.
    HANDLE hFind = FindFirstVolumeW(szVolumeName, _countof(szVolumeName));
    if (hFind == INVALID_HANDLE_VALUE)
    {
        // FindFirstVolumeW 함수가 실패한 경우, 에러 코드를 출력하고 프로그램을 종료합니다.
        wprintf(L"Error: %d\n", GetLastError());
        return -1;
    }

    // 모든 볼륨에 대한 정보를 가져오기 위해 do-while 문을 사용합니다.
    do
    {
        size_t lastIndex = wcslen(szVolumeName) - 1;
        // 볼륨 이름의 마지막 문자를 널 문자로 변경하여 볼륨 이름을 저장합니다. (QueryDosDeviceW가 장치 이름 중 \를 사용하지 못하기 때문 )
        szVolumeName[lastIndex] = L'\0';

        WCHAR szDeviceName[MAX_PATH];
        // QueryDosDeviceW 함수를 이용해 장치 이름을 가져옵니다. 가져온 값을 szDeviceName에 저장합니다.
        // 경로 표기법인 \\?\ 부분인 인덱스 0 ~ 3까지의 부분을 제거 해야 함
        size_t numberOfStored = QueryDosDeviceW(&szVolumeName[4], szDeviceName, _countof(szDeviceName));
        // QueryDosDeviceW() 함수를 호출하여 가져온 장치 이름에는 null 문자가 포함되어 있지 않다.
        // 하지만 szVolumeName 배열은 Null로 끝나는 문자열이어야 해서 맨끝에 \ 문자를 삽입하여야 한다.
        // 그래서 szVolumeName 배열은 null로 끝나는 문자열로 다시 복원 됩니다.
        szVolumeName[lastIndex] = L'\\';

        if (0 == numberOfStored)
        {
            // QueryDosDeviceW 함수가 실패한 경우, 에러 코드를 출력합니다.
            DWORD dwError = GetLastError();
            break;
        }

        WCHAR szMountPoints[MAX_PATH] = { 0 };
        DWORD cchReturnLength;
        // GetVolumePathNamesForVolumeNameW 함수를 이용해 볼륨 이름에 대한 모든 마운트 포인트를 가져옵니다.
        // 가져온 값을 szMountPoints에 저장합니다.
        if (GetVolumePathNamesForVolumeNameW(szVolumeName, szMountPoints, _countof(szMountPoints), &cchReturnLength))
        {
            // 마운트 포인트가 있는 경우, 볼륨 이름, 장치 이름, 마운트 포인트를 출력합니다.
            wprintf(L"%s (%s) -> %s\n", szVolumeName, szDeviceName, szMountPoints);
        }
        else
        {
            // 마운트 포인트가 없는 경우, 볼륨 이름과 장치 이름만 출력합니다.
            wprintf(L"%s (%s)\n", szVolumeName, szDeviceName);
        }
        // FindNextVolumeW 함수는 현재 검색 중인 볼륨의 다음 볼륨을 찾습니다
    } while (FindNextVolumeW(hFind, szVolumeName, _countof(szVolumeName)));
    // 핸들을 닫습니다.
    FindVolumeClose(hFind);

    return 0;
}