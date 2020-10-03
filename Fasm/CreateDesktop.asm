format pe console
entry start

include 'win32ax.inc'

section '.text' code readable executable
 start:
      push explorer_path
      push desktop_name
      call CreateAnotherDesktop
      call [getchar]
      push 0
      call [ExitProcess]



proc CreateAnotherDesktop Name, Path
 locals
        file_explorer db MAX_PATH dup(0)
        desktop_thread dd ?
        other_desktop dd ?
 endl

 push MAX_PATH - 1
 lea eax, [file_explorer]
 push eax
 push [Path]
 call [ExpandEnvironmentStrings]

 push GENERIC_ALL
 push 0
 push NULL
 push [Name]
 call [OpenDesktop]
 cmp eax, 0
 jz .exit

 push NULL
 push GENERIC_ALL
 push 0
 push NULL
 push NULL
 push [Name]
 call [CreateDesktop]
 cmp eax, 0
 jz .exit




.exit:
 mov esp, ebp
 pop ebp
 ret 8
endp



section '.data' data readable writeable
 startup_info STARTUPINFO ?
 process_info PROCESS_INFORMATION ?
 second_desktop dd ?
 desktop_name db "Senju", 0
 explorer_path db "%windir%\explorer.exe", 0




section '.idata' import readable
 library kernel32, 'kernel32.dll',\
         user32,   'user32.dll',\
         msvcrt,   'msvcrt.dll'


 import kernel32,\
        ExpandEnvironmentStrings, 'ExpandEnvironmentStringsA',\
        CreateProcess,            'CreateProcessA',\
        GetCurrentThreadId,       'GetCurrentThreadId',\
        CloseHandle,              'CloseHandle',\
        CloseDesktop,             'CloseDesktop',\
        ExitProcess,              'ExitProcess'

 import user32,\
        OpenDesktop,      'OpenDesktopA',\
        CreateDesktop,    'CreateDesktopA',\
        GetThreadDesktop, 'GetThreadDesktop',\
        SetThreadDesktop, 'SetThreadDesktop',\
        RegisterHotKey,   'RegisterHotKey',\
        SwitchDesktop,    'SwitchDesktop',\
        GetMessage,       'GetMessage',\
        MessageBox,       'MessageBoxA'

 import msvcrt,\
        getchar,        'getchar'



