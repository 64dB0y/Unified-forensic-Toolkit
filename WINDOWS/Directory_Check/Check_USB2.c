#include <fcntl.h>
#include <io.h>
#include <windows.h>
#include <stdio.h>
#include <locale.h>

int wmain()
{
    CONSOLE_FONT_INFOEX cfi;
    cfi.cbSize = sizeof(cfi);
    cfi.nFont = 0;
    cfi.dwFontSize.X = 0;
    cfi.dwFontSize.Y = 16;
    cfi.FontFamily = FF_DONTCARE;
    cfi.FontWeight = FW_NORMAL;
    wcscpy_s(cfi.FaceName, LF_FACESIZE, L"Lucida Console");

    WCHAR szVolumeName[MAX_PATH];

    HANDLE hFind = FindFirstVolumeW(szVolumeName, _countof(szVolumeName));
    if (hFind == INVALID_HANDLE_VALUE)
    {
        wprintf(L"Error: %d\n", GetLastError());
        return -1;
    }

    do
    {
        size_t lastIndex = wcslen(szVolumeName) - 1;
        szVolumeName[lastIndex] = L'\0';

        WCHAR szDeviceName[MAX_PATH];
        size_t numberOfStored = QueryDosDeviceW(&szVolumeName[4], szDeviceName, _countof(szDeviceName));
        szVolumeName[lastIndex] = L'\\';

        if (0 == numberOfStored)
        {
            DWORD dwError = GetLastError();
            break;
        }

        WCHAR szMountPoints[MAX_PATH] = { 0 };
        DWORD cchReturnLength;
        if (GetVolumePathNamesForVolumeNameW(szVolumeName, szMountPoints, _countof(szMountPoints), &cchReturnLength))
        {
            wprintf(L"%s (%s) -> %s\n", szVolumeName, szDeviceName, szMountPoints);
        }
        else
        {
            wprintf(L"%s (%s)\n", szVolumeName, szDeviceName);
        }
    } while (FindNextVolumeW(hFind, szVolumeName, _countof(szVolumeName)));

    FindVolumeClose(hFind);

    return 0;
}