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
global SimultaneousThreshold := 30  ; 30ms window for simultaneous detection

; ============================================
; SIMULTANEOUS KEY COMBO SYSTEM
; ============================================
; Track key states and timestamps
global KeyStates := Map()
global KeyTimestamps := Map()
global ComboFired := Map()

; Define all simultaneous combos: [key1, key2, output, requireShift]
global SimultaneousCombos := [
    ; Shift + combos
    ["m", ",", "?", true],      ; LShift + m+, -> ?
    [",", ".", "!", true],      ; LShift + ,+. -> !
    
    ; Regular simultaneous combos
    ["a", "s", "<", false],     ; a+s -> <
    ["l", ";", ">", false],     ; l+; -> >
    [",", ".", ".", false],     ; ,+. -> .
    ["m", ",", ",", false],     ; m+, -> ,
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

; Process key down - check for simultaneous combos
ProcessKeyDown(thisKey) {
    global KeyStates, KeyTimestamps, ComboFired, SimultaneousCombos, SimultaneousThreshold
    
    currentTime := A_TickCount
    KeyStates[thisKey] := true
    KeyTimestamps[thisKey] := currentTime
    
    ; Check shift state
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
        
        ; Check if other key is pressed and within time threshold
        if (KeyStates.Has(otherKey) && KeyStates[otherKey]) {
            if (KeyTimestamps.Has(otherKey)) {
                timeDiff := Abs(currentTime - KeyTimestamps[otherKey])
                if (timeDiff <= SimultaneousThreshold) {
                    ; Combo detected! Mark as fired and send output
                    comboId := key1 . key2 . (requireShift ? "S" : "")
                    if (!ComboFired.Has(comboId) || !ComboFired[comboId]) {
                        ComboFired[comboId] := true
                        SendText(output)
                        return true  ; Combo fired, suppress key
                    }
                }
            }
        }
    }
    return false  ; No combo, let key through
}

; Process key up - reset states
ProcessKeyUp(thisKey) {
    global KeyStates, ComboFired, SimultaneousCombos
    
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

; ============================================
; HOTKEY DEFINITIONS - Simultaneous Keys
; ============================================
; We need to hook all keys involved in combos

#HotIf true  ; Always active

; Row: q w e r t y u i o p
*q::HandleKey("q", "q")
*w::HandleKey("w", "w")
*e::HandleKey("e", "e")
*r::HandleKey("r", "r")
*t::HandleKey("t", "t")
*y::HandleKey("y", "y")
*u::HandleKey("u", "u")
*i::HandleKey("i", "i")
*o::HandleKey("o", "o")
*p::HandleKey("p", "p")

; Row: a s d f g h j k l ;
*a::HandleKey("a", "a")
*s::HandleKey("s", "s")
*d::HandleKey("d", "d")
*f::HandleKey("f", "f")
*g::HandleKey("g", "g")
*h::HandleKey("h", "h")
*j::HandleKey("j", "j")
*k::HandleKey("k", "k")
*l::HandleKey("l", "l")
*SC027::HandleKey(";", ";")  ; semicolon

; Row: z x c v b n m , .
*z::HandleKey("z", "z")
*x::HandleKey("x", "x")
*c::HandleKey("c", "c")
*v::HandleKey("v", "v")
*b::HandleKey("b", "b")
*n::HandleKey("n", "n")
*m::HandleKey("m", "m")
*,::HandleKey(",", ",")
*.::HandleKey(".", ".")

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
*SC027 Up::ProcessKeyUp(";")
*z Up::ProcessKeyUp("z")
*x Up::ProcessKeyUp("x")
*c Up::ProcessKeyUp("c")
*v Up::ProcessKeyUp("v")
*b Up::ProcessKeyUp("b")
*n Up::ProcessKeyUp("n")
*m Up::ProcessKeyUp("m")
*, Up::ProcessKeyUp(",")
*. Up::ProcessKeyUp(".")

; Handle key press with combo detection
HandleKey(key, defaultOutput) {
    if (!ProcessKeyDown(key)) {
        ; No combo fired, send the default character
        ; But we need to handle shift state properly
        if (GetKeyState("Shift", "P"))
            SendText(Format("{:U}", defaultOutput))  ; Uppercase
        else
            SendText(defaultOutput)
    }
}

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
