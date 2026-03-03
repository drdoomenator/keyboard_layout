#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook

; ------------------------------------------------------------
; Определение активной раскладки по активному окну (а не по потоку AHK)
; ------------------------------------------------------------
GetActiveLangId() {
    hwnd := WinActive("A")
    if !hwnd
        return 0
    tid := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt*", 0, "UInt")
    hkl := DllCall("GetKeyboardLayout", "UInt", tid, "UPtr")
    return hkl & 0xFFFF
}
IsRu() => GetActiveLangId() = 0x0419

SendU(codePoint) => SendText(Chr(codePoint))

; ------------------------------------------------------------
; ОБЩЕЕ (работает в любой раскладке)
; ------------------------------------------------------------

; ISO-клавиша (SC056): § / ±
SC056::SendU(0x00A7)         ; §
+SC056::SendU(0x00B1)        ; ±

; Ctrl+E -> Win+E (Проводник)
^e::Send("#e")


; F3 -> Win+Shift+S (Скриншот)
F3::Send("#+s")

; Колёсико мыши влево/вправо -> регулировка громкости
WheelLeft::Send("{Volume_Down}")
WheelRight::Send("{Volume_Up}")

; ------------------------------------------------------------
; RU-ТОЛЬКО (применяется только когда активна русская раскладка)
; ------------------------------------------------------------
#HotIf IsRu()

; RU: цифровой ряд как US по Shift (только отличающиеся клавиши)
+SC003::SendText("@")        ; Shift+2
+SC004::SendText("#")        ; Shift+3
+SC005::SendText("$")        ; Shift+4
+SC007::SendText("^")        ; Shift+6
+SC008::SendText("&")        ; Shift+7

; OEM_3 (SC029): ` и ~
; В AHK символ backtick экранируется как ``
SC029::SendText("``")        ; `
+SC029::SendText("~")        ; ~

; OEM_2 (SC035): ё и Ё
SC035::SendU(0x0451)         ; ё
+SC035::SendU(0x0401)        ; Ё

; OEM_5 (SC02B): \ и |
SC02B::SendText("\")         ; \
+SC02B::SendText("|")        ; |

#HotIf

; ------------------------------------------------------------
; NUMPAD (всегда, независимо от NumLock и активной раскладки)
; Дублируем имена клавиш для NumLock ON и OFF.
; ------------------------------------------------------------

; Decimal: NumpadDot (ON) и NumpadDel (OFF)
NumpadDot::SendText(".")
NumpadDel::SendText(".")
+NumpadDot::SendText(";")
+NumpadDel::SendText(";")

; Divide: Shift + NumpadDiv -> :
+NumpadDiv::SendText(":")

; Shift + цифры нампада -> символы (ON и OFF)
; 0 / Ins -> ,
+Numpad0::SendText(",")
+NumpadIns::SendText(",")

; 1 / End -> ?
+Numpad1::SendText("?")
+NumpadEnd::SendText("?")

; 2 / Down -> <
+Numpad2::SendText("<")
+NumpadDown::SendText("<")

; 3 / PgDn -> >
+Numpad3::SendText(">")
+NumpadPgDn::SendText(">")

; 4 / Left -> '
+Numpad4::SendText("'")
+NumpadLeft::SendText("'")

; 5 / Clear -> "
+Numpad5::SendText(Chr(34))
+NumpadClear::SendText(Chr(34))

; 6 / Right -> [
+Numpad6::SendText("[")
+NumpadRight::SendText("[")

; 7 / Home -> ]
+Numpad7::SendText("]")
+NumpadHome::SendText("]")

; 8 / Up -> {
+Numpad8::SendText("{")
+NumpadUp::SendText("{")

; 9 / PgUp -> }
+Numpad9::SendText("}")
+NumpadPgUp::SendText("}")
