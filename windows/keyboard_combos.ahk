; AutoHotkey v2 Script
; Converted from Karabiner-Elements config
; Custom keyboard combos with true simultaneous key detection

#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================
; CONFIGURATION
; ============================================
; Simultaneous key press threshold (in milliseconds)
; Keys must be pressed within this time window to trigger combo
global SimultaneousThreshold := 20  ; 20ms window for simultaneous detection

; ============================================
; SIMULTANEOUS KEY COMBO SYSTEM
; ============================================
; Track key states and timestamps
global KeyStates := Map()
global KeyTimestamps := Map()
global ComboFired := Map()
global PendingKeys := Map()       ; Keys waiting to see if combo fires
global PendingShift := Map()      ; Shift state when key was pressed

; Define all simultaneous combos: [key1, key2, output, requireShift]
global SimultaneousCombos := [
    ; Shift + combos
    ["m", "SC033", "?", true],      ; LShift + m+, -> ?
    ["SC033", "SC034", "!", true],  ; LShift + ,+. -> !
    
    ; Regular simultaneous combos
    ["a", "s", "<", false],     ; a+s -> <
    ["l", "SC027", ">", false], ; l+; -> >
    ["SC033", "SC034", ".", false], ; ,+. -> .
    ["m", "SC033", ",", false],     ; m+, -> ,
    ["i", "o", "|", false],     ; i+o -> |
    ["k", "l", "&", false],     ; k+l -> &
    ["w", "e", "+", false],     ; w+e -> +
    ["s", "d", "=", false],     ; s+d -> =
    ["x", "c", "*", false],     ; x+c -> *
    ["c", "v", "/", false],     ; c+v -> /
    ["e", "r", "-", false],     ; e+r -> -
    ["u", "i", "_", false],     ; u+i -> _
    ["d", "f", '"', false],     ; d+f -> "
    ["j", "k", "'", false],     ; j+k -> '
    ["r", "t", "(", false],     ; r+t -> (
    ["y", "u", ")", false],     ; y+u -> )
    ["f", "g", "[", false],     ; f+g -> [
    ["h", "j", "]", false],     ; h+j -> ]
    ["v", "b", "{", false],     ; v+b -> {
    ["n", "m", "}", false],     ; n+m -> }
]

; Check for combo when second key arrives, return matched combo's other key or ""
CheckCombo(thisKey) {
    global KeyStates, KeyTimestamps, ComboFired, SimultaneousCombos, SimultaneousThreshold, PendingKeys
    
    currentTime := A_TickCount
    shiftHeld := GetKeyState("Shift", "P")
    
    ; Check all combos
    for combo in SimultaneousCombos {
        key1 := combo[1]
        key2 := combo[2]
        output := combo[3]
        requireShift := combo[4]
        
        ; Skip if shift requirement doesn't match
        if (requireShift != shiftHeld)
            continue
        
        ; Check if this key is part of the combo
        otherKey := ""
        if (thisKey = key1)
            otherKey := key2
        else if (thisKey = key2)
            otherKey := key1
        else
            continue
        
        ; Check if other key is pending and within time threshold
        if (PendingKeys.Has(otherKey) && PendingKeys[otherKey]) {
            if (KeyTimestamps.Has(otherKey)) {
                timeDiff := Abs(currentTime - KeyTimestamps[otherKey])
                if (timeDiff <= SimultaneousThreshold) {
                    ; Combo detected! Cancel pending timer for other key
                    comboId := key1 . key2 . (requireShift ? "S" : "")
                    if (!ComboFired.Has(comboId) || !ComboFired[comboId]) {
                        ComboFired[comboId] := true
                        ; Cancel the pending key's timer
                        SetTimer(MakeSendFunc(otherKey), 0)
                        PendingKeys[otherKey] := false
                        PendingKeys[thisKey] := false
                        SendText(output)
                        return otherKey  ; Return which key was the other part of combo
                    }
                }
            }
        }
    }
    return ""  ; No combo found
}

; Process key up - reset states
ProcessKeyUp(thisKey) {
    global KeyStates, ComboFired, SimultaneousCombos, PendingKeys
    
    KeyStates[thisKey] := false
    
    ; Reset combo fired states for combos involving this key
    for combo in SimultaneousCombos {
        key1 := combo[1]
        key2 := combo[2]
        requireShift := combo[4]
        if (thisKey = key1 || thisKey = key2) {
            comboId := key1 . key2 . (requireShift ? "S" : "")
            ComboFired[comboId] := false
        }
    }
}

; Create a bound function for timer callback
MakeSendFunc(key) {
    return SendPendingKey.Bind(key)
}

; Timer callback - send the key if still pending
SendPendingKey(key) {
    global PendingKeys, PendingShift
    
    ; Disable this timer
    SetTimer(MakeSendFunc(key), 0)
    
    ; If key is still pending (combo didn't fire), send it
    if (PendingKeys.Has(key) && PendingKeys[key]) {
        PendingKeys[key] := false
        ; Send with proper shift state
        if (PendingShift.Has(key) && PendingShift[key])
            Send("{Blind}{" key "}")
        else
            Send("{Blind}{" key "}")
    }
}

; Handle key press with delayed combo detection
HandleKey(key) {
    global KeyStates, KeyTimestamps, PendingKeys, PendingShift, SimultaneousThreshold
    
    currentTime := A_TickCount
    KeyStates[key] := true
    KeyTimestamps[key] := currentTime
    PendingShift[key] := GetKeyState("Shift", "P")
    
    ; Check if this key completes a combo with any pending key
    otherKey := CheckCombo(key)
    if (otherKey != "") {
        ; Combo fired, don't send anything (combo already sent output)
        return
    }
    
    ; No immediate combo - mark as pending and start timer
    PendingKeys[key] := true
    SetTimer(MakeSendFunc(key), -SimultaneousThreshold)  ; Negative = run once
}

; ============================================
; HOTKEY DEFINITIONS - Simultaneous Keys
; ============================================
; We need to hook all keys involved in combos

#HotIf true  ; Always active

; Row: q w e r t y u i o p
*q::HandleKey("q")
*w::HandleKey("w")
*e::HandleKey("e")
*r::HandleKey("r")
*t::HandleKey("t")
*y::HandleKey("y")
*u::HandleKey("u")
*i::HandleKey("i")
*o::HandleKey("o")
*p::HandleKey("p")

; Row: a s d f g h j k l ;
*a::HandleKey("a")
*s::HandleKey("s")
*d::HandleKey("d")
*f::HandleKey("f")
*g::HandleKey("g")
*h::HandleKey("h")
*j::HandleKey("j")
*k::HandleKey("k")
*l::HandleKey("l")
*SC027::HandleKey("SC027")  ; semicolon

; Row: z x c v b n m , .
*z::HandleKey("z")
*x::HandleKey("x")
*c::HandleKey("c")
*v::HandleKey("v")
*b::HandleKey("b")
*n::HandleKey("n")
*m::HandleKey("m")
*SC033::HandleKey("SC033")  ; comma
*SC034::HandleKey("SC034")  ; period

; Key up handlers
*q Up::ProcessKeyUp("q")
*w Up::ProcessKeyUp("w")
*e Up::ProcessKeyUp("e")
*r Up::ProcessKeyUp("r")
*t Up::ProcessKeyUp("t")
*y Up::ProcessKeyUp("y")
*u Up::ProcessKeyUp("u")
*i Up::ProcessKeyUp("i")
*o Up::ProcessKeyUp("o")
*p Up::ProcessKeyUp("p")
*a Up::ProcessKeyUp("a")
*s Up::ProcessKeyUp("s")
*d Up::ProcessKeyUp("d")
*f Up::ProcessKeyUp("f")
*g Up::ProcessKeyUp("g")
*h Up::ProcessKeyUp("h")
*j Up::ProcessKeyUp("j")
*k Up::ProcessKeyUp("k")
*l Up::ProcessKeyUp("l")
*SC027 Up::ProcessKeyUp("SC027")
*z Up::ProcessKeyUp("z")
*x Up::ProcessKeyUp("x")
*c Up::ProcessKeyUp("c")
*v Up::ProcessKeyUp("v")
*b Up::ProcessKeyUp("b")
*n Up::ProcessKeyUp("n")
*m Up::ProcessKeyUp("m")
*SC033 Up::ProcessKeyUp("SC033")  ; comma
*SC034 Up::ProcessKeyUp("SC034")  ; period

#HotIf

; ============================================
; ALT + KEY HOTKEYS (simple remaps)
; ============================================
; Alt + top row -> numbers
!q::SendText("1")
!w::SendText("2")
!e::SendText("3")
!r::SendText("4")
!t::SendText("5")
!y::SendText("6")
!u::SendText("7")
!i::SendText("8")
!o::SendText("9")
!p::SendText("0")

; Alt + home row -> symbols
!a::SendText("!")
!s::SendText("@")
!d::SendText("#")
!f::SendText("$")
!g::SendText("%")
!h::SendText("^")
!j::SendText("&")
!k::SendText("*")
!l::SendText("(")
!SC027::SendText(")")  ; Alt + ;

; ============================================
; MUTED KEYS - Number row disabled
; ============================================
*1::return
*2::return
*3::return
*4::return
*5::return
*6::return
*7::return
*8::return
*9::return
*0::return
*-::return
*=::return

; ============================================
; MOUSE CONTROLS
; ============================================
; Horizontal scroll -> volume control
WheelLeft::SoundSetVolume("-1")
WheelRight::SoundSetVolume("+1")

; Left Alt + Middle Mouse Button -> Screenshot (Win+Shift+S)
!MButton::Send("#+s")
