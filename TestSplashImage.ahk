FileName=jp.png

;Usage sample:
imgSize(FileName, imageWidth , imageHeight)
MsgBox ,  w= %imageWidth% _ h= %imageHeight%
;SplashImage, JP.png, B ZH32 ZW-1,,, ppp
SplashImage, %FileName%, B ,,, ppp
WinSet, Transparent, 64, ppp
WinSet, ExStyle, +0x00000020, ppp
Return

imgSize(img, ByRef width , ByRef height)
{ ; Get image's dimensions
    If FileExist(img) {
        GUI, Add, Picture, hwndpic, %img%
        ;GUI, show
        ControlGetPos,,, width, height,, ahk_id %pic%
        Gui, Destroy
    } Else {
        height := -1
        width := -1
    }
}

ESC:: ExitApp
