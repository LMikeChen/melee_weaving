; Hotkeys.au3 - hotkey registration and corresponding routines

; timeout values in milliseconds
Global $TIMEOUT_TO_FINISH_STEADY_SHOT = 3000
Global $TIMEOUT_RUN_TO_MELEE_RANGE = 5000
Global $TIMEOUT_RUN_BACK_TO_SHORT_RANGE = 1000

; register hotkeys and exit handler
HotKeySet("{F8}", "steadyShotMeleeWeaving")
HotKeySet("{F7}", "meleeWeaving")
HotKeySet("{F6}", "ExitScript")

Global $listening = False

; toggle hotkey listening
Func ToggleListening()
    $listening = Not $listening
    If $listening Then
        GUICtrlSetData($g_hToggleBtn, "Stop")
        _Log("Hotkey listening started")
    Else
        GUICtrlSetData($g_hToggleBtn, "Start")
        _Log("Hotkey listening stopped")
    EndIf
EndFunc

; handler for steady shot + weaving
Func steadyShotMeleeWeaving()

    If Not $listening Then Return

    Local $funcStart = TimerInit()

    ; Toggle stop
    If $running Then
        ReleaseMovement()
        $running = False
        _Log("Steady shot weaving stopped")
        Return
    EndIf

    Local $state = 1
    $running = True
    _Log("Steady shot weaving started")
    ; steady shot
    SendSafeKey("S")

    Local $startTime = TimerInit()

    While $running

        If TimerDiff($startTime) > $TIMEOUT_TO_FINISH_STEADY_SHOT Then
            _Log("Steady shot completion timed out")
            $running = False
            ExitLoop
        EndIf

        Local $castColor = FastPixel($castBarCheckX, $castBarCheckY)
        ; update GUI preview
        UpdateExpected($steadyShotCompleteColor, $castBarCheckX, $castBarCheckY)
        UpdateCurrent($castColor, $castBarCheckX, $castBarCheckY)

        ; STEP 1 - wait for cast start
        If $state = 1 Then
            If ColorMatch($castColor, $steadyShotCompleteColor, $ColorTolerance) Then
                _Log("Steady shot casting")
                $state = 2
            EndIf
        EndIf

        ; STEP 2 - wait for cast end
        If $state = 2 Then
            If Not ColorMatch($castColor, $steadyShotCompleteColor, $ColorTolerance) Then
                _Log("Steady shot completed " & Round(TimerDiff($startTime)))
                Sleep(120)
                $state = 3
            EndIf
        EndIf

        ; STEP 3 - run weaving detection
        If $state = 3 Then
            $running = False
            meleeWeaving()
            ExitLoop
        EndIf

        Sleep(3)

    WEnd

    _Log("Steady shot weaving completed in " & Round(TimerDiff($funcStart)) & " ms")

EndFunc

; melee weaving routine invoked from hotkey
Func meleeWeaving()

    If Not $listening Then Return

    Local $funcStart = TimerInit()

    _Log("Melee weaving routine started")

    $holdingUp = True
    Send("{UP down}")

    Local $startTime = TimerInit()

    While True

        If TimerDiff($startTime) > $TIMEOUT_RUN_TO_MELEE_RANGE Then
            _Log("Melee weaving timed out")
            Send("{UP up}")
            $holdingUp = False
            ExitLoop
        EndIf

        Local $color = FastPixel($rangeCheckLocationX, $rangeCheckLocationY)
        UpdateExpected($MeleeRangeColor, $rangeCheckLocationX, $rangeCheckLocationY)
        UpdateCurrent($color, $rangeCheckLocationX, $rangeCheckLocationY)

        If ColorMatch($color, $MeleeRangeColor, $ColorTolerance) Then

             _Log("Time took to reach Melee range: " & Round(TimerDiff($startTime)) & " ms")

            ; delay a little bit might not need
            Sleep(3)

            Send("{UP up}")
            $holdingUp = False

            Sleep(25)

            SendSafeKey("F")

            Sleep(35)

            Send("{DOWN down}")
            $holdingDown = True

            Local $innerStart = TimerInit()

            While $holdingDown

                If TimerDiff($innerStart) > $TIMEOUT_RUN_BACK_TO_SHORT_RANGE  Then
                    _Log("Short range detection timed out")
                    Send("{DOWN up}")
                    $holdingDown = False
                    ExitLoop
                EndIf

                Local $color2 = FastPixel($rangeCheckLocationX, $rangeCheckLocationY)
                UpdateExpected($ShortRangeColor, $rangeCheckLocationX, $rangeCheckLocationY)
                UpdateCurrent($color2, $rangeCheckLocationX, $rangeCheckLocationY)

                If ColorMatch($color2, $ShortRangeColor, $ColorTolerance) Then
                    _Log("Time took to reach Short range: " & Round(TimerDiff($startTime)) & " ms")
                    Send("{DOWN up}")
                    $holdingDown = False
                EndIf

                Sleep(3)

            WEnd

            ExitLoop

        EndIf

        Sleep(3)

    WEnd
    _Log("Melee weaving routine ended")
    _Log("Melee weaving completed in " & Round(TimerDiff($funcStart)) & " ms")
EndFunc
