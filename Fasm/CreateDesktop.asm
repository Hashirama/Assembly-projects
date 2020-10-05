format pe console
entry start

include 'win32ax.inc'

section '.text' code readable executable
 start:
      push explorer_path
      push desktop_name
      call CreateAnotherDesktop
      mov [second_desktop], eax

      call [GetCurrentThreadId]
      push eax
      call [GetThreadDesktop]
      mov [original_desktop], eax

      push [second_desktop]
      call [SetThreadDesktop]

      push [second_desktop]
      call [SwitchDesktop]

      push 0x45
      mov eax, MOD_CONTROL
      or eax, MOD_ALT
      ;or eax, MOD_NOREPEAT
      push eax
      push 1
      push NULL
      call [RegisterHotKey]

    .loop:
      push 0
      push 0
      push NULL
      lea eax, [message]
      push eax
      call [GetMessage]
      cmp eax, 0
      jz .exit

      cmp [message.message], WM_HOTKEY
      jnz .loop

      push [original_desktop]
      call [SwitchDesktop]
    .exit:
      call [getchar]
      push 0
      call [ExitProcess]


proc MsgBx
  locals
        Pip db "Hey",0
  endl
  stdcall [MessageBox], NULL, addr Pip, addr Pip, MB_OK
  ret
endp

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
 jnz .exit

 push NULL
 push GENERIC_ALL
 push 0
 push NULL
 push NULL
 push [Name]
 call [CreateDesktop]
 cmp eax, 0
 jz .exit

 mov [other_desktop], eax
 call [GetCurrentThreadId]
 push eax
 call [GetThreadDesktop]
 mov [desktop_thread], eax

 push [other_desktop]
 call [SetThreadDesktop]

 lea eax, [file_explorer]
 push eax
 call CreateProc

 push [desktop_thread]
 call [SetThreadDesktop]
 mov eax, [other_desktop]

.exit:
 mov esp, ebp
 pop ebp
 ret 8
endp

proc CreateProc Path
 locals
       startup_info STARTUPINFO ?
       process_info PROCESS_INFORMATION ?
 endl

 ;push sizeof.STARTUPINFO
 ;lea eax, [startup_info]
 ;push eax
 ;call [memset]

 mov [startup_info.cb], sizeof.STARTUPINFO
 ;lea eax, [desktop_name]
 mov [startup_info.lpDesktop], desktop_name

 stdcall [CreateProcess], [Path], 0, 0, 0, 0, 0, 0, 0, addr startup_info, addr process_info
 cmp eax, 0
 jz .fail
 jmp .exit

.exit:
 mov esp, ebp
 pop ebp
 ret 4
endp


section '.data' data readable writeable
 message MSG ?
 second_desktop dd ?
 original_desktop dd ?
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
        GetMessage,       'GetMessageA',\
        MessageBox,       'MessageBoxA'

 import msvcrt,\
        getchar,        'getchar',\
        memset,         'memset'



