; GUI.au3 - User interface for Weaving Detection script
#include <GuiConstants.au3>

; create main window and log control
Global $g_hGUI = GUICreate("Weaving Detection", 500, 225)
Global $g_hLog = GUICtrlCreateEdit("", 200, 10, 300, 205, BitOR($ES_AUTOVSCROLL, $ES_MULTILINE, $WS_VSCROLL, $ES_READONLY))
GUISetState(@SW_SHOW)

; color preview controls
Global $g_hExpectedBox = GUICtrlCreateLabel("", 10, 50, 50, 50)
GUICtrlSetStyle($g_hExpectedBox, BitOR($GUI_SS_DEFAULT_LABEL, $WS_BORDER))
Global $g_hExpectedText = GUICtrlCreateLabel("Expected: N/A", 70, 50, 130, 20)
Global $g_hExpectedCoord = GUICtrlCreateLabel("X: , Y:", 70, 70, 130, 20)
Global $g_hCurrentBox = GUICtrlCreateLabel("", 10, 110, 50, 50)
GUICtrlSetStyle($g_hCurrentBox, BitOR($GUI_SS_DEFAULT_LABEL, $WS_BORDER))
Global $g_hCurrentText = GUICtrlCreateLabel("Current: N/A", 70, 110, 130, 20)
Global $g_hCurrentCoord = GUICtrlCreateLabel("X: , Y:", 70, 130, 130, 20)

; buttons
Global $g_hExitBtn = GUICtrlCreateButton("Exit (F6)", 10, 10, 60, 30)
Global $g_hToggleBtn = GUICtrlCreateButton("Start (F9)", 80, 10, 60, 30)

; helper to update the preview boxes
Func UpdateExpected($color, $x, $y)
    GUICtrlSetBkColor($g_hExpectedBox, $color)
    GUICtrlSetData($g_hExpectedText, "Expected: 0x" & Hex($color,6))
    GUICtrlSetData($g_hExpectedCoord, "X: " & $x & "  Y: " & $y)
EndFunc

Func UpdateCurrent($color, $x, $y)
    GUICtrlSetBkColor($g_hCurrentBox, $color)
    GUICtrlSetData($g_hCurrentText, "Current: 0x" & Hex($color,6))
    GUICtrlSetData($g_hCurrentCoord, "X: " & $x & "  Y: " & $y)
EndFunc


; display message in log
Func _Log($msg)
    Local $cur = GUICtrlRead($g_hLog)
    GUICtrlSetData($g_hLog, $cur & @CRLF & $msg)
    GUICtrlSendMsg($g_hLog, 0x0115, 7, 0) ; WM_VSCROLL, SB_BOTTOM
EndFunc

; run the GUI loop
Func GUI_Run()
    While True
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ; diagnostic
                If IsFunc("_Log") Then _Log("GUI received close event")
                ; if ExitScript is available call it, otherwise just exit
                If IsFunc("ExitScript") Then
                    ExitScript()
                Else
                    Exit
                EndIf
            Case $g_hExitBtn
                ExitScript()
            Case $g_hToggleBtn
                ToggleListening()
        EndSwitch
        Sleep(20)
    WEnd
EndFunc

; NOTE: this file is meant to be #included by the main script. Running GUI.au3 by
; itself will create the window but not set up hotkeys or define ExitScript, so
; the close button may not stop the script. Always start with
; "Weaving Detection.au3" unless you add your own ExitScript handler.
