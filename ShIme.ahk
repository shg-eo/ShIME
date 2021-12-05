; ShIme.ahk Version 1.0.0

; Copyright (c) 2021 SAKUMA, Shigeo 
;
; Relased under the MIT license
; see https://opensource.org/licenses/MIT
;
; The IME_Func.ahk file is:
; see http://www.kmonos.net/nysl/  (Japanese)
;     http://www.kmonos.net/nysl/index.en.html  (English, but unofficial)
;
; Windowが切り替わるたびに, 
; また、キー入力、マウスクリック・ホイール動作(マウスカーソルの動きには追従しない)が
; 一定時間無いと
; Active Window中央に
; IMEの状態を表示する。[A] か [あ]

Version = ShIme Ver 1.0.0.
DialogTitle = "ShIME_ShIME_ShIME_ShIME"

#Include IME_Func.ahk

IniDir := % A_LineFile . "\..\"
IniFile:= % IniDir . "ShIme.ini"

; Razer Synapseなど、キーカスタマイズ系のツールを併用しているときのエラー対策
#MaxHotkeysPerInterval 350

#SingleInstance on
#Persistent

ShowFlag := 1
; SetBatchLines, 10
; Thread Priority,, High

; flag (NOw suspend or not)
SuspendState :=0

; Hidden time to show [A]/[あ]
IniRead, WaitToShow,        %IniFile%, ShIme , WaitToShow, 2000

IniRead, TransparentRate,   %IniFile%, ShIme, TransParentRate, 150
IniRead, TransparentRate2,  %IniFile%, ShIme, TransParentRate2, 50

; Time to show [A]/[あ]
IniRead, ShowTime,          %IniFile%, ShIme, ShowTime, 500

; Use "Henkan" and "MuHenkan" keys to change IME state
IniRead, ChangeHenkan,      %IniFile%, ShIme, ChangeHenkan, 1

IniRead, IgnoreMouse,       %IniFile%, ShIme, IgnoreMouse, 0

IniRead,IMEOn,              %IniFile%, ShIme, IMEOn,[あ]
IniRead,IMEOff,             %IniFile%, ShIme, IMEOff,[_A]

Menu, Tray, NoStandard
Menu, Tray, Add, %Version%, DoNothing
Menu, Tray, Add, 設定, Configuration
Menu, Tray, Add, 終了, ExitShime

SetTimer, TimerShow, %WaitToShow%

; Sence mouse moving 
MouseX :=-1
MouseY :=-1
CoordMode,Mouse,Screen
SetTimer, CheckMouse, 100

; refer https://sites.google.com/site/agkh6mze/howto/winevent
myFunc := RegisterCallback("WinActivateHandler")

myHook := DllCall("SetWinEventHook"
 , "UInt", 0x00000003 ; eventMin      : EVENT_SYSTEM_FOREGROUND
 , "UInt", 0x00000003 ; eventMax      : EVENT_SYSTEM_FOREGROUND
 , "UInt", 0          ; hModule       : self
 , "UInt", myFunc     ; hWinEventProc : 
 , "UInt", 0          ; idProcess     : All process
 , "UInt", 0          ; idThread      : All threads
 , "UInt", 0x0003     ; dwFlags       : WINEVENT_SKIPOWNTHREAD | WINEVENT_SKIPOWNPROCESS
 , "UInt")

Return

DoNothing:
    Return

Configuration:  ; 設定ダイアログ
    TexX = 10
    LocX = 50
    GUI, Add, Text, X%TexX% ,ウィンドウが切り替わった時の表示時間

    GUI, Add, Edit, X%LocX%
    GUI, Add, UpDown, vShowTime Range0-10000 X%LocX%, %ShowTime%
    GUI, Add, Text, X+10, [ms]

    mes1 := "ウィンドウが切り替わった時に表示する透明度"
    Tr := 255 - TransParentRate
    GUI, Add, Text, X%TexX% Y+30 , %mes1%
    GUI, Add, Slider, vTr Range0-255 X%LocX%, %Tr%

    GUI, Add, Text, X%TexX% ,キー・マウスの入力が無いと判断するまで
    GUI, Add, Edit, X%LocX%
    GUI, Add, UpDown, vWaitToShow Range0-10000 X%LocX%, %WaitToShow%
    GUI, Add, Text, X+10, [ms]
        
    mes := "キー・マウスの入力が無くなった時に表示する透明度"
    Tr2 := 255 - TransParentRate2
    GUI, Add, Text, X%TexX% Y+30 , %mes%
    GUI, Add, Slider, vTr2 Range0-255 X%LocX%, %Tr2%

    GUI, Add, CheckBox, X%TexX% Y+10 vIgnoreMouse Checked%IgnoreMouse%, マウスクリック、ホイール操作を無反応にする

    GUI, Add, CheckBox, X%TexX% Y+10 vChangeHenkan Checked%ChangeHenkan%,「変換」「無変換」キーをIMEの切り替えに使用する

    GUI, Add, Button, W70 X25 Y+20 Default, Ok
    GUI, Add, Button, W70 X+0, Cancel
    GUI, Add, Button, W70 X+5, Reset

    GUI, Show, H330, 設定

    Return

ButtonReset:
    WaitToShow          := 2000
    TransParentRate     := 150
    TransParentRate2    := 50
    ShowTime            := 500
    IgnoreMouse         := 1
    ChangeHenkan        := 1
    IMEOn               := "[あ]"
    IMEOff              := "[_A]"
    GUI, Destroy
    ; GoSub Configuration
    Return

ButtonOK:
    GUI, Submit
    TransParentRate  := 255 - Tr
    TransParentRate2 := 255 - Tr2

    IniWrite, %WaitToShow%,         %IniFile%, ShIme, WaitToShow
    IniWrite, %TransparentRate%,    %IniFile%, ShIme, TransParentRate
    IniWrite, %TransparentRate2%,   %IniFile%, ShIme, TransParentRate2
    IniWrite, %ShowTime%,           %IniFile%, ShIme, ShowTime
    IniWrite, %IgnoreMouse%,        %IniFile%, ShIme, IgnoreMouse
    IniWrite, %ChangeHenkan%,       %IniFile%, ShIme, ChangeHenkan
    IniWrite, %IMEOn%,              %IniFile%, ShIme, IMEOn
    IniWrite, %IMEOff%,             %IniFile%, ShIme, IMEOff

GuiEscape:
GuiClose:
ButtonCancel:
    ;GUI, Cancel
    GUI, Destroy
    Return

Return

ShowDiag(string, x, y, trans){
    ;Progress, B Zh0 FM72 FS72 x%x% y%y% w210 CT000000 CWdddddd, %string%, ,p
    Progress, B Zh0 R0-1000 M72 FS72 x%x% y%y% CT000000 CWdddddd, %string%, , %DialogTitle%
    WinSet, Transparent, %trans%, %DialogTitle%
    WinSet, ExStyle, +0x00000020, %DialogTitle%
    Return
}

SuspendShime:
    if(SuspendState == 0){
        SuspendState := 1
        Menu, Tray, Check, Suspend
        Suspend, On
    }else{
        SuspendState := 0
        Menu, Tray, UnCheck, Suspend
        Suspend, Off
    }
    Return

ExitShime:
    ExitApp

WinActivateHandler(hWinEventHook, event, hwnd, idObject, idChild, thread, time) {
    global ShowFlag, ShowTime, TransParentRate, IMEOn, IMEOff
    ShowFlag := 0
    SetTimer, TimerShow, %WaitToShow%

    WinGetActiveStats, Title, Width, Height, X, Y
    if (title == "") {
        Return
    }

    xPos := X + Width /2-150
    yPos := Y + Height/2-20

    if (IME_CHECK("A") ==0)
    { 
        Progress, Off
        ShowDiag(IMEOff, xPos, yPos, TransParentRate)
        Sleep, %ShowTime%
        Progress, Off
    }
    else
    {
        Progress, Off
        ;Tooltip, [あ]
        ShowDiag(IMEOn, xPos, yPos, TransParentRate)
        Sleep, %ShowTime%
        Progress, Off
    }
}


; ; ALT+ESCでIMEのトグル
; !ESC::  IME_TOGGLE("A")

; 無変換
;vk1Dsc07B::   ; obsolate
vk1D:: 
    if (ChangeHenkan == 1){
        IME_OFF("A")
        ShowDiag(IMEOff, xPos, yPos, TransParentRate2)
        Sleep, %ShowTime%
        Progress, Off
        ShowFlag := 0
        SetTimer, TimerShow, %WaitToShow%
    }
    Return

; 変換
;vk1Csc079::   ; obsolate
vk1C:: 
    if (ChangeHenkan == 1){
        IME_ON("A")
        ShowDiag(IMEOn, xPos, yPos, TransParentRate2)
        Sleep, %ShowTime%
        Progress, Off
        ShowFlag := 0
        SetTimer, TimerShow, %WaitToShow%
    }
    Return


; 主要なキーを HotKey に設定し、[A] [あ] 表示を消す。
*~LButton::
*~RButton::
*~MButton::
*~XButton1::
*~XButton2::
*~WheelDown::
*~WheelUp::
*~WheelLeft::
*~WheelRight::
    if (ignoreMouse == 1){
        Return
    }

RShift::
LShift::
Shift::
*~a::
*~b::
*~c::
*~d::
*~e::
*~f::
*~g::
*~h::
*~i::
*~j::
*~k::
*~l::
*~m::
*~n::
*~o::
*~p::
*~q::
*~r::
*~s::
*~t::
*~u::
*~v::
*~w::
*~x::
*~y::
*~z::
*~1::
*~2::
*~3::
*~4::
*~5::
*~6::
*~7::
*~8::
*~9::
*~0::
*~F1::
*~F2::
*~F3::
*~F4::
*~F5::
*~F6::
*~F7::
*~F8::
*~F9::
*~F10::
*~F11::
*~F12::
*~`::
*~~::
*~!::
*~@::
*~#::
*~$::
*~%::
*~^::
*~&::
*~*::
*~(::
*~)::
*~-::
*~_::
*~=::
*~+::
*~[::
*~{::
*~]::
*~}::
*~\::
*~|::
*~;::
*~'::
*~"::
*~,::
*~<::
*~.::
*~>::
*~/::
*~?::
*~Esc::
*~Tab::
*~Space::
*~LAlt::
*~RAlt::
*~Left::
*~Right::
*~Up::
*~Down::
*~Enter::
*~PrintScreen::
*~Delete::
*~Home::
*~End::
*~PgUp::
*~PgDn::
    Progress, Off   ; 表示を消す
    ;if (ShowFlag == 1){
    ;    ShowIMEState(500)
    ;}
    ShowFlag := 0
    SetTimer, TimerShow, %WaitToShow%
    Return

TimerShow:
    global IMEOn, IMEOff
    if (ShowFlag == 0){
        WinGetActiveStats, Title, Width, Height, X, Y
        if (title == "") 
        {
            return
        }
        xPos := X + Width  / 2 - 150
        yPos := Y + Height / 2 - 20
        if (IME_CHECK("A") == 0 )
        { 
            ;Tooltip, [A]
            ShowDiag(IMEOff, xPos, yPos, TransParentRate2)
        }
        else
        {
            ;Tooltip, [あ]
            ShowDiag(IMEOn, xPos, yPos, TransParentRate2)
        }

        ShowFlag := 1
        Return
    }

CheckMouse:
    MouseGetPos, X, Y, Win, Control, 0
    if (MouseX != X) OR (MouseY != Y) {
        Progress, Off
        ShowFlag := 0
        SetTimer, TimerShow, %WaitToShow%
    }
    MouseX := X
    MouseY := Y
    Return
