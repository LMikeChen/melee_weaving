#include <Array.au3>
#include <Misc.au3>
#include <WinAPI.au3>

; ===== INPUT RELIABILITY SETTINGS =====
Opt("SendMode", 1)
Opt("SendKeyDelay", 0)
Opt("SendKeyDownDelay", 0)
Opt("PixelCoordMode", 0)

; ===== SETTINGS =====
$castBarCheckX = 1326
$castBarCheckY = 1030
$steadyShotCompleteColor = 0xFFFFFF

$rangeCheckLocationX = 1270
$rangeCheckLocationY = 880
$MeleeRangeColor = 0x001D08
$ShortRangeColor = 0xF7C900
$ColorTolerance = 15

; ===== STATE VARIABLES =====
$running = False
$holdingUp = False
$holdingDown = False

; ===== FAST PIXEL READER =====
Global $hDC = _WinAPI_GetDC(0)

#include "GUI.au3"
#include "Hotkeys.au3"

OnAutoItExitRegister("ExitScript")

; start GUI event loop (blocks)
GUI_Run()


; steadyShotMeleeWeaving is now defined in Hotkeys.au3


; meleeWeaving is now defined in Hotkeys.au3


; ==========================
Func FastPixel($x, $y)

    Return _WinAPI_GetPixel($hDC, $x, $y)

EndFunc


; ==========================
Func SendSafeKey($key)

    Local $shift = _IsPressed("10")
    Local $ctrl = _IsPressed("11")
    Local $alt = _IsPressed("12")

    If $shift Then Send("{SHIFT up}")
    If $ctrl Then Send("{CTRL up}")
    If $alt Then Send("{ALT up}")

    Send("{" & $key & " down}")
    Sleep(8)
    Send("{" & $key & " up}")

    If $shift Then Send("{SHIFT down}")
    If $ctrl Then Send("{CTRL down}")
    If $alt Then Send("{ALT down}")

EndFunc


; ==========================
Func ReleaseMovement()

    If $holdingUp Then Send("{UP up}")
    If $holdingDown Then Send("{DOWN up}")

    $holdingUp = False
    $holdingDown = False

EndFunc




; ==========================
Func ColorMatch($pixelColor, $targetColor, $tolerance = 5)

    Local $r1 = BitShift(BitAND($pixelColor, 0xFF0000), 16)
    Local $g1 = BitShift(BitAND($pixelColor, 0x00FF00), 8)
    Local $b1 = BitAND($pixelColor, 0x0000FF)

    Local $r2 = BitShift(BitAND($targetColor, 0xFF0000), 16)
    Local $g2 = BitShift(BitAND($targetColor, 0x00FF00), 8)
    Local $b2 = BitAND($targetColor, 0x0000FF)

    If Abs($r1 - $r2) <= $tolerance And _
       Abs($g1 - $g2) <= $tolerance And _
       Abs($b1 - $b2) <= $tolerance Then
        Return True
    EndIf

    Return False

EndFunc


; ==========================
Func ExitScript()
    ; log when exit handler runs
    If IsFunc("_Log") Then _Log("ExitScript invoked")

    ReleaseMovement()

    If $hDC <> 0 Then
        _WinAPI_ReleaseDC(0, $hDC)
    EndIf

    Exit

EndFunc