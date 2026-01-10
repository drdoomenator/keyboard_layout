#Requires AutoHotkey v2.0
#SingleInstance Force

; ------------------------------------------------------------
; Определение активной раскладки по активному окну (не по потоку AHK)
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

; Утилита отправки символа по Unicode codepoint
SendU(codePoint) => SendText(Chr(codePoint))

; ------------------------------------------------------------
; ОБЩЕЕ (работает в любой раскладке)
; ------------------------------------------------------------

; ISO-клавиша (SC056, обычно рядом с левым Shift на ISO-клавиатурах)
; SC056 -> §
; Shift+SC056 -> ±
SC056::SendU(0x00A7)         ; §
+SC056::SendU(0x00B1)        ; ±

; ------------------------------------------------------------
; RU-ТОЛЬКО (применяется только когда активна русская раскладка)
; ------------------------------------------------------------
#HotIf IsRu()

; Цифровой ряд в RU привести к US по Shift (только отличающиеся клавиши):
; Shift+2 -> @
; Shift+3 -> #
; Shift+4 -> $
; Shift+6 -> ^
; Shift+7 -> &
+SC003::SendText("@")        ; Shift+2
+SC004::SendText("#")        ; Shift+3
+SC005::SendText("$")        ; Shift+4
+SC007::SendText("^")        ; Shift+6
+SC008::SendText("&")        ; Shift+7

; Клавиша слева от 1 (OEM_3, SC029):
; SC029 -> `
; Shift+SC029 -> ~
; В AHK обратный апостроф (backtick) экранируется как ``
SC029::SendText("``")        ; `
+SC029::SendText("~")        ; ~

; Клавиша / ? (OEM_2, SC035):
; SC035 -> ё
; Shift+SC035 -> Ё
SC035::SendU(0x0451)         ; ё
+SC035::SendU(0x0401)        ; Ё

; Клавиша \ | (OEM_5, SC02B):
; SC02B -> \
; Shift+SC02B -> |
SC02B::SendText("\")         ; \
+SC02B::SendText("|")        ; |

#HotIf

; ------------------------------------------------------------
; NUMPAD (всегда, независимо от NumLock и активной раскладки)
; Используем SC-коды, чтобы работало одинаково при NumLock On/Off
; ------------------------------------------------------------

; Numpad Decimal (SC053):
; SC053 -> .
; Shift+SC053 -> ;
SC053::SendText(".")         ; .
+SC053::SendText(";")        ; ;

; Numpad Divide:
; Shift+NumpadDiv -> :
+NumpadDiv::SendText(":")    ; :

; Shift + цифры нампада (физические клавиши):
; Shift+Num0 -> ,
; Shift+Num1 -> ?
; Shift+Num2 -> <
; Shift+Num3 -> >
; Shift+Num4 -> '
; Shift+Num5 -> "
; Shift+Num6 -> [
; Shift+Num7 -> ]
; Shift+Num8 -> {
; Shift+Num9 -> }
+SC052::SendText(",")        ; Shift+Num0
+SC04F::SendText("?")        ; Shift+Num1
+SC050::SendText("<")        ; Shift+Num2
+SC051::SendText(">")        ; Shift+Num3
+SC04B::SendText("'")        ; Shift+Num4
+SC04C::SendText(Chr(34))    ; Shift+Num5 -> "
+SC04D::SendText("[")        ; Shift+Num6
+SC047::SendText("]")        ; Shift+Num7
+SC048::SendText("{")        ; Shift+Num8
+SC049::SendText("}")        ; Shift+Num9
