__UNICODE__ equ 1
include masm32rt.inc

includelib setti\setti.lib
includelib lang\lang.lib
includelib ex_api\ex_api.lib
includelib w\w.lib
includelib enc_dec\enc_dec.lib

include \masm32\include\cryptdll.inc
includelib \masm32\lib\cryptdll.lib
include \masm32\include\advapi32.inc
includelib \masm32\lib\advapi32.lib
include \masm32\include\shlwapi.inc
includelib \masm32\lib\shlwapi.lib
include \masm32\include\gdiplus.inc
includelib \masm32\lib\gdiplus.lib
include \masm32\include\msimg32.inc
includelib \masm32\lib\msimg32.lib
include \masm32\include\crypt32.inc
includelib \masm32\lib\crypt32.lib

EditOutProc              proto :DWORD, :DWORD, :DWORD, :DWORD
EditInProc               proto :DWORD, :DWORD, :DWORD, :DWORD
MemoryCopy               proto :DWORD, :DWORD, :DWORD
digest2hex               proto :DWORD, :DWORD, :DWORD
Font_Dialog              proto :DWORD, :DWORD, :DWORD
SizeProc                 proto :DWORD, :DWORD
BitmapFromResourceEx     proto :DWORD, :DWORD
rotate_image             proto :DWORD, :DWORD
GetClipboardD            proto :DWORD, :DWORD
SetClipboardD            proto :DWORD, :DWORD
ColorProc                proto :DWORD, :DWORD
SetColor                 proto :DWORD, :DWORD
BSProc                   proto :DWORD, :DWORD
DecorProc                proto :DWORD
Paint_Proc               proto :DWORD
FocusSize                proto :DWORD
DecryptProc              proto :DWORD
EnableProc               proto :DWORD
HideShow                 proto :DWORD
include lib.inc

;macro
    xparam MACRO n_const, ident
        mov edx, ident
        mov ecx, n_const
        shl ecx, 16
        or ecx, edx
        EXITM <ecx>
    ENDM

;struct
    MD5_CTX STRUCT
        i      db 8 dup(?)
        buf    db 16 dup(?)
        inn    db 64 dup(?)
        digest db 16 dup(?)
    MD5_CTX ENDS

.const
    STR_A                   equ 0
    STR_W                   equ -1
    STR_ITALIC              equ 010000h
    STR_UNDERLINE           equ 0100h
    STR_STRIKEOUT           equ 01h

.data
    UC RevEncryptor_Class,  "RevEncryptor_v1_Class", 0
    UC statusbar,           "msctls_statusbar32", 0
    UC edit,                "edit", 0
    UC button,              "button", 0
    UC VerdanaFont,         "Verdana", 0
	UC RevEncryptor,        "RevEncryptor  v1.0", 0

    fLng                    dd 1
	hDecor                  dd 0
	hStart                  dd 0
	hColor                  dd 0bbbbbbh
	listColor               dd 0bbbbbbh,0ee8888h,0550000h,0bbffbbh,0aaaaaah,0bbeeeeh,0ccbbbbh,0f3f3f3h,0fec8bdh,0,0ffffffh,0ddbbbbh,0eebb88h,0550077h,033ddbbh,033aaaah,0bbee11h,0cc77bbh,03a3afah,0fe88bdh  
    fLock                   dd 0
    fButton                 dd 0
	wwww                    dd 500
	hhhh                    dd 500
	ang_timer               dd 0.0
	hRotate                 dd 0.0
	hBrush                  dd 0
	hPen                    dd 0
	nPswd                   dd 0
    
    s_Translation                   dd 0, 10000   ; Перевод
    s_RestartProgram                dd 0, 10010   ; Перезапустите программу
    s_About                         dd 0, 10020   ; О программе
    s_EncryptAndCopy                dd 0, 10030   ; Копировать код
    s_BigBrother1                   dd 0, 10040   ; Большой брат следит за тобой!
    s_BigBrother2                   dd 0, 10050   ; 5/11  Не ждём, а готовимся!
    s_Decor                         dd 0, 10060   ; Оформление
    s_Revolutionary                 dd 0, 10070   ; Революционер
    s_CIAagent                      dd 0, 10080   ; Агент ЦРУ
    s_AgentOfTheKGB                 dd 0, 10090   ; Агент КГБ
    s_Standard                      dd 0, 10100   ; Стандартное
    s_EnterTextInTheBox             dd 0, 10110   ; Введите текст
    s_EnterPassword                 dd 0, 10120   ; Введите пароль и повторите попытку
    s_RevolutionWillBe              dd 0, 10130   ; Революция будет!
    s_CaptainAmerica                dd 0, 10140   ; Супергерой(Капитан Америка)
    s_Revolution                    dd 0, 10150   ; Революция
    s_Anonymous                     dd 0, 10160   ; Аноним
    s_Mechanic                      dd 0, 10170   ; Механик
    s_Panda                         dd 0, 10180   ; Партизан ПАНДа
    s_PartisAntiCorrupMovem         dd 0, 10190   ; Партизанское АНтикоррупционное Движение
    s_Kamikaze                      dd 0, 10200   ; Камикадзе
    s_BackgroundColor               dd 0, 10210   ; Цвет фона
    s_HolyFather                    dd 0, 10220   ; Святой отец
	s_Font                          dd 0, 10230   ; Шрифт
	s_Decrypted                     dd 0, 10240   ; Дешифровано
	s_CiphIsCorOrPassIsIncor        dd 0, 10250   ; Шифротекст повреждён или пароль неправильный
	s_CipherNotRecognized           dd 0, 10260   ; Шифротекст не опознан
	s_BufferIsEmpty                 dd 0, 10270   ; Буфер пуст
	s_CipherCopiedToClipboard       dd 0, 10280   ; Шифротекст скопирован в буфер

    id_statusbar                    dd 3050, 0, -1
    id_button_enc_and_copy          dd 3040, 0, 0
    id_edit_password                dd 3030, 0, 0
    id_edit_output                  dd 3020, 0, 0
    id_edit_input                   dd 3010, 0, 0

.data?
    hInstance       dd ?
    CommandLine     dd ?
    ini_f           dd ?
    hWin            dd ?
    hMenu           dd ?
	hMenu2          dd ?
	hBmp            dd ?
	hIm511          dd ?
	hImCIA          dd ?
	hImKGB          dd ?
	hImMAS          dd ?
	hImCAP          dd ?
	hImREV          dd ?
	hImANO          dd ?
	hImMEC          dd ?
	hImPAN          dd ?
	hImKAM          dd ?
	hImFAT          dd ?
    gditoken        dd ?
	hend            dd ?
	rzv             dd ?
	src_gr_con      dd ?
	hDC1            dd ?
	gdipPen         dd ?
	hBrushOld       dd ?
	hPenOld         dd ?
	bitmap          dd ?
	trans_buff1     dd ?
	trans_buff2     dd ?
	mega_buff_out   dd ?
	mega_buff_in    dd ?
	hEditOutProc    dd ?
	hEditInProc     dd ?
	lenEncDec       dd ?
	

    temp_str        TCHAR 2048 dup (?)
    temp_str2       TCHAR 2048 dup (?)
	tmp_status      TCHAR 256 dup (?)
    pswd_buff       TCHAR 2048 dup (?)
    w_dig_hex       db 512 dup (?)
	
    gdisi           GdiplusStartupInput <>
    wc              WNDCLASSEX <>
    msg             MSG <>
    iccex           INITCOMMONCONTROLSEX <>
    ofn             OPENFILENAME <>
    lrgi            LARGE_INTEGER <>
    md5             MD5_CTX <>
	win_rec         RECT <>
	cli_rec         RECT <>
	img_poi         POINT <>
	pointMove       POINT <>
	koor            POINT <>
    font_struct     LOGFONT <>
    font_struct2    LOGFONT <>

	IPicture STRUCT
		; IUnknown methods
		QueryInterface          DWORD   ?
		AddRef                  DWORD   ?
		Release                 DWORD   ?
		; IPicture methods
		get_Handle              DWORD   ?
		get_hPal                DWORD   ?
		get_Type                DWORD   ?
		get_Width               DWORD   ?
		get_Height              DWORD   ?
		Render                  DWORD   ?	
		set_hPal                DWORD   ?
		get_CurDC               DWORD   ?
		SelectPicture           DWORD   ?
		get_KeepOriginalFormat  DWORD   ?
		put_KeepOriginalFormat  DWORD   ?
		PictureChanged          DWORD   ?
		SaveAsFile              DWORD   ?
		get_Attributes          DWORD   ?
	IPicture ENDS
	