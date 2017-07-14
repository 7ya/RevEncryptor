; Update date:		 11.7.2017
; Contact:			 https://twitter.com/revencryptor
; Channel:           https://t.me/RevEncryptor
;**********************************************************************************************************************************************************
include data.inc
.code
start:
;**********************************************************************************************************************************************************
	invoke GetModuleHandle, 0
	mov hInstance, eax
	invoke ini_ini, uc$("RevEncryptor.ini"), 1024
	mov ini_f, eax
	cmp ini_f, 1
	jne @F
		invoke get_data, 0, addr fLng
		invoke get_data, 0, addr hDecor
		invoke get_data, 0, addr hColor
	@@:
	invoke read_lng, uc$("RevEncryptor.lng"), 262144
	invoke get_str, addr s_Translation, 28, fLng, hInstance

	invoke GetCommandLine
	mov CommandLine, eax
	mov iccex.dwSize, sizeof INITCOMMONCONTROLSEX
	mov iccex.dwICC, ICC_WIN95_CLASSES
	invoke InitCommonControlsEx, addr iccex

	invoke LocalAlloc, 040h, 1310720
	mov trans_buff1, eax
	invoke LocalAlloc, 040h, 1310720
	mov trans_buff2, eax
	invoke LocalAlloc, 040h, 131072
	mov mega_buff_out, eax
	invoke LocalAlloc, 040h, 131072
	mov mega_buff_in, eax
	invoke RetFontHEx, offset VerdanaFont, 14, 400, 0, offset font_struct

	mov win_rec.right, 0
	mov win_rec.bottom, 0

	mov wc.cbSize, sizeof WNDCLASSEX
	mov wc.style, CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW
	mov wc.lpfnWndProc, offset RevEncryptorProc
	mov wc.cbClsExtra, 0
	mov wc.cbWndExtra, 20
	mrm wc.hInstance, hInstance
	invoke LoadIcon, hInstance, 900
	mov wc.hIcon, eax
	mov wc.hIconSm, eax
	invoke LoadCursor, 0, IDC_ARROW
	mov wc.hCursor, eax
	invoke CreateSolidBrush, hColor
	mov wc.hbrBackground, eax ; COLOR_BTNFACE+1
	mov wc.lpszMenuName, 0
	mov wc.lpszClassName, offset RevEncryptor_Class
	invoke RegisterClassEx, addr wc
	invoke crtwindow, addr RevEncryptor, 0, 0, addr RevEncryptor_Class, 0, 0, 480, 415, WS_MINIMIZEBOX or WS_SYSMENU or WS_SIZEBOX or WS_CLIPCHILDREN, WS_EX_LAYERED or WS_EX_TOPMOST, 0, 0, 0, 0, hInstance ;WS_EX_ACCEPTFILES
	mov hWin, eax
	cmp ini_f, 1
	jne @F
		invoke get_data, 0, addr font_struct
		invoke CreateFontIndirect, addr font_struct
		mov ebx, eax
		invoke SendMessage, h(offset id_edit_output), WM_SETFONT, ebx, 1
		invoke SendMessage, h(offset id_edit_input), WM_SETFONT, ebx, 1
	@@:
	invoke SetLayeredWindowAttributes, hWin, 0, 255, LWA_ALPHA
	invoke window_center, hWin
	invoke SetWindowPos, h(offset id_statusbar), HWND_TOP, 0, 0, 0, 0, SWP_SHOWWINDOW or SWP_NOMOVE
	invoke ShowWindow, hWin, SW_SHOWNORMAL
	invoke SendMessage, hWin, WM_NCPAINT, 1, 0

	invoke GetWindowRect, hWin, addr win_rec
	mov eax, win_rec.right
	sub eax, win_rec.left
	mov win_rec.right, eax
	mov ecx, win_rec.bottom
	sub ecx, win_rec.top
	mov win_rec.bottom, ecx
	invoke GetClientRect, hWin, addr cli_rec

	invoke SetTimer, hWin, 2304, 150, 0
	start_msg:
		invoke GetMessage, addr msg, 0, 0, 0
		or eax, eax
		je end_msg
		invoke tab_focus, addr msg, hWin
		cmp eax, 1
		je start_msg
		invoke TranslateMessage, addr msg
		invoke DispatchMessage, addr msg
		jmp start_msg
	end_msg:
	invoke ExitProcess, msg.wParam
;**********************************************************************************************************************************************************
SizeProc proc hWnd:DWORD, www:DWORD
LOCAL loc_rec:RECT
	add www, ebx
	invoke GetWindowRect, hWnd, addr loc_rec
	mov ecx, loc_rec.bottom
	sub ecx, loc_rec.top
	invoke SetWindowPos, hWnd, HWND_TOP, 0, 0, www, ecx, SWP_SHOWWINDOW or SWP_NOMOVE
ret
SizeProc endp
;**********************************************************************************************************************************************************
RevEncryptorProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
LOCAL hDCx:DWORD, rec:RECT, loc_m1:DWORD, loc_m2:DWORD
.IF uMsg== WM_GETMINMAXINFO && win_rec.right!= 0
	mov ebx, lParam
	mrm dword ptr[ebx+24], win_rec.right
	mrm dword ptr[ebx+28], win_rec.bottom
	mov dword ptr[ebx+32], 800
	mrm dword ptr[ebx+36], win_rec.bottom

.ELSEIF uMsg== WM_SIZE && wParam!= SIZE_MINIMIZED && win_rec.right!= 0
	.if wParam== SIZE_MAXIMIZED
	.elseif wParam== SIZE_RESTORED
	.endif
	mov eax, lParam
	movzx ebx, ax
	shr eax, 16
	sub ebx, cli_rec.right
	invoke SizeProc, h(offset id_edit_password), 240
	invoke SizeProc, h(offset id_edit_output), 440
	invoke SizeProc, h(offset id_edit_input), 440
	invoke SizeProc, h(offset id_statusbar), 0

.ELSEIF uMsg== WM_MOVE
	invoke InvalidateRect, hWnd, 0, 1

.ELSEIF uMsg== WM_TIMER
	mov eax, wParam
	.if ax== 2303 && fLock== 0
		movss XMM0, FP4(0.011)
		addss XMM0, ang_timer
		movss ang_timer, XMM0
		finit
		fld ang_timer
		fsin
		fmul FP4(30.0)
		fstp hRotate
		fwait
		invoke rotate_image, hRotate, 10
		invoke InvalidateRect, hWnd, 0, 0
	.elseif ax== 2304
		.if hStart== 10
			invoke KillTimer, hWin, 2304
			invoke SetTimer, hWin, 2303, 200, 0
			invoke HideShow, SW_SHOW
		.else
			inc hStart
			invoke rotate_image, FP4(0.0), hStart
			invoke InvalidateRect, hWnd, 0, 0
		.endif
	.elseif ax== 2305
		invoke GetCursorPos, addr koor
		mov ebx, pointMove.x
		sub koor.x, ebx
		mov ecx, pointMove.y
		sub koor.y, ecx
		invoke SetWindowPos, hWnd, HWND_TOP, koor.x, koor.y, 0, 0, SWP_SHOWWINDOW or SWP_NOSIZE
	.endif

.ELSEIF uMsg== WM_LBUTTONDOWN
	invoke SetCapture, hWnd
	invoke GetCursorPos, addr koor
	invoke GetWindowRect, hWnd, addr rec
	mov ecx, rec.left
	mov ebx, koor.x
	sub ebx, ecx
	mov pointMove.x, ebx
	mov ecx, rec.top
	mov ebx, koor.y
	sub ebx, ecx
	mov pointMove.y, ebx
	invoke SetTimer, hWin, 2305, 11, 0

.ELSEIF uMsg== WM_LBUTTONUP
	invoke ReleaseCapture
	invoke KillTimer, hWin, 2305

.ELSEIF uMsg== WM_COMMAND
	mov eax, wParam
	ror eax, 16
	.IF ax== BN_CLICKED || ax== EN_CHANGE
		shr eax, 16
		.IF eax== id_button_enc_and_copy ; шифровать и копировать
			invoke SendMessage, h(offset id_edit_output), WM_GETTEXT, 655360, trans_buff2
			invoke lstrlen, trans_buff2
			.if eax!= 0
				invoke WhirlpoolInit
				invoke lstrlen, addr pswd_buff
				mov ebx, eax
				shl ebx, 1 ; *2
				invoke WhirlpoolUpdate, addr pswd_buff, ebx
				invoke WhirlpoolFinal
				invoke digest2hex, eax, addr w_dig_hex, 16
				invoke lstrlen, trans_buff2
				shl eax, 1 ; *2
				add eax, 2
				mov lenEncDec, eax
				invoke AESEncrypt, trans_buff2, offset lenEncDec, offset w_dig_hex
				.if eax!= 0
					invoke CryptBinaryToString, trans_buff2, lenEncDec, CRYPT_STRING_BASE64, 0, addr loc_m1 ;return len in TCHAR + 0
					.if eax!= 0
						mov eax, loc_m1
						shl eax, 1 ; *2
						add eax, 64
						invoke LocalAlloc, 040h, eax
						mov loc_m2, eax
						invoke CryptBinaryToString, trans_buff2, lenEncDec, CRYPT_STRING_BASE64, loc_m2, addr loc_m1
						.if eax!= 0
							;invoke MultiByteToWideChar, CP_ACP, 0, addr w_dig_hex, -1, trans_buff2, MAX_PATH
							invoke BSProc, loc_m2, trans_buff2
							invoke SetClipboardD, trans_buff2, hWnd
							.if eax!= 0
								invoke SendMessage, h(offset id_edit_output), WM_SETTEXT, 0, uc$("")
								invoke SetWindowText, h(offset id_statusbar), s_CipherCopiedToClipboard ;Шифр скопирован в буфер обмена
							.endif
						.endif
						invoke LocalFree, loc_m2
					.endif
				.endif
			.else
				invoke FocusSize, 0
				invoke MessageBox, hWnd, s_EnterTextInTheBox, addr RevEncryptor, MB_OK
				invoke SetFocus, h(offset id_edit_output)
			.endif
		.ELSEIF eax== id_edit_password
			invoke EnableProc, hWnd
		.ELSEIF eax>= 5001 && eax< 5100	 ; смена €зыка
			sub eax, 5000
			mov fLng, eax
			invoke get_str, addr s_RestartProgram, 0, fLng, 0
			invoke MessageBox, hWnd, s_RestartProgram, addr RevEncryptor, MB_OK
			invoke SendMessage, hWnd, WM_CLOSE, 0, 0
		.ELSEIF eax== 5000               ; о программе
			invoke lstrcpy, addr temp_str2, ucc$("2017. RevEncryptor version 1.0\nRevolutionary Encryption System (RES) based on Rijndael (AES)\nContact: https://twitter.com/RevEncryptor\nChannel: https://t.me/RevEncryptor\nDonate: WebMoney WMR: R363822863556\n\n")
			invoke lstrcat, addr temp_str2, s_Translation
			invoke about_box, hInstance, hWin, addr temp_str2, addr RevEncryptor, MB_OK, 900
        .ELSEIF eax== 4712               ;Ўрифт
			lea esi, font_struct
			lea edi, font_struct2
			mov ecx, sizeof LOGFONT
			rep movsb
			invoke Font_Dialog, hWnd, offset font_struct, CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT or CF_FORCEFONTEXIST
			.if eax== IDOK
				invoke CreateFontIndirect, offset font_struct
				mov loc_m1, eax
				invoke SendMessage, h(offset id_edit_output), WM_SETFONT, loc_m1, 1
				invoke SendMessage, h(offset id_edit_input), WM_SETFONT, loc_m1, 1
			.else
				lea esi, font_struct2
				lea edi, font_struct
				mov ecx, sizeof LOGFONT
				rep movsb
            .endif
		.ELSEIF eax== 4710               ; цвет фона
			invoke ColorProc, hWnd, hColor
			mov hColor, eax
			invoke SetColor, hWnd, hColor
			invoke rotate_image, FP4(0.0), 10
			invoke InvalidateRect, hWnd, 0, 1
		.ELSEIF eax== 4700               ; 51117
			mov hDecor, 0
			invoke DecorProc, hDecor
			invoke SetColor, hWnd, hColor
			invoke rotate_image, hRotate, 10
			invoke InvalidateRect, hWnd, 0, 1
		.ELSEIF eax== 4701               ; cia
			mov hDecor, 1
			invoke DecorProc, hDecor
			invoke SetColor, hWnd, hColor
			invoke rotate_image, FP4(0.0), 10
			invoke InvalidateRect, hWnd, 0, 1
		.ELSEIF eax== 4702               ; kgb
			mov hDecor, 2
			invoke DecorProc, hDecor
			invoke SetColor, hWnd, hColor
			invoke rotate_image, FP4(0.0), 10
			invoke InvalidateRect, hWnd, 0, 1
		.ELSEIF eax== 4703               ; mas
			mov hDecor, 3
			invoke DecorProc, hDecor
			invoke SetColor, hWnd, hColor
			invoke rotate_image, hRotate, 10
			invoke InvalidateRect, hWnd, 0, 1
		.ELSEIF eax== 4704               ; cap
			mov hDecor, 4
			invoke DecorProc, hDecor
			invoke SetColor, hWnd, hColor
			invoke rotate_image, hRotate, 10
			invoke InvalidateRect, hWnd, 0, 1
		.ELSEIF eax== 4705               ; rev
			mov hDecor, 5
			invoke DecorProc, hDecor
			invoke SetColor, hWnd, hColor
			invoke rotate_image, FP4(0.0), 10
			invoke InvalidateRect, hWnd, 0, 1
		.ELSEIF eax== 4706               ; anonymous
			mov hDecor, 6
			invoke DecorProc, hDecor
			invoke SetColor, hWnd, hColor
			invoke rotate_image, FP4(0.0), 10
			invoke InvalidateRect, hWnd, 0, 1
		.ELSEIF eax== 4707               ; mechanic
			mov hDecor, 7
			invoke DecorProc, hDecor
			invoke SetColor, hWnd, hColor
			invoke rotate_image, hRotate, 10
			invoke InvalidateRect, hWnd, 0, 1
		.ELSEIF eax== 4708               ; panda
			mov hDecor, 8
			invoke DecorProc, hDecor
			invoke SetColor, hWnd, hColor
			invoke rotate_image, FP4(0.0), 10
			invoke InvalidateRect, hWnd, 0, 1
		.ELSEIF eax== 4709               ; kamikaze
			mov hDecor, 9
			invoke DecorProc, hDecor
			invoke SetColor, hWnd, hColor
			invoke rotate_image, hRotate, 10
			invoke InvalidateRect, hWnd, 0, 1
		.ELSEIF eax== 4711               ; holy father
			mov hDecor, 10
			invoke DecorProc, hDecor
			invoke SetColor, hWnd, hColor
			invoke rotate_image, FP4(0.0), 10
			invoke InvalidateRect, hWnd, 0, 1
		.ELSEIF eax== 4800
			invoke SetFocus, h(offset id_edit_password)
		.ELSEIF eax== 4801
			invoke Beep, 888, 555
		.ENDIF
	.ENDIF

.ELSEIF uMsg== WM_CREATE
	mov gdisi.GdiplusVersion, 1
	invoke GdiplusStartup, addr gditoken, addr gdisi, 0

	invoke BitmapFromResourceEx, hInstance, 910
	mov hIm511, eax
	invoke BitmapFromResourceEx, hInstance, 920
	mov hImCIA, eax
	invoke BitmapFromResourceEx, hInstance, 930
	mov hImKGB, eax
	invoke BitmapFromResourceEx, hInstance, 940
	mov hImMAS, eax
	invoke BitmapFromResourceEx, hInstance, 950
	mov hImCAP, eax
	invoke BitmapFromResourceEx, hInstance, 960
	mov hImREV, eax
	invoke BitmapFromResourceEx, hInstance, 970
	mov hImANO, eax
	invoke BitmapFromResourceEx, hInstance, 980
	mov hImMEC, eax
	invoke BitmapFromResourceEx, hInstance, 990
	mov hImPAN, eax
	invoke BitmapFromResourceEx, hInstance, 1000
	mov hImKAM, eax
	invoke BitmapFromResourceEx, hInstance, 1010
	mov hImFAT, eax

	invoke CreateMenu
	mov hMenu, eax
	invoke CreateLngMenu, hMenu, fLng
	invoke CreatePopupMenu
	mov hMenu2, eax
	invoke AppendMenu, hMenu, MF_POPUP or MF_STRING, hMenu2, s_Decor
	invoke AppendMenu, hMenu2, MF_STRING, 4712, s_Font
	invoke AppendMenu, hMenu2, MF_STRING, 4710, s_BackgroundColor
	invoke AppendMenu, hMenu2, MF_SEPARATOR, 0, 0
	invoke AppendMenu, hMenu2, MF_STRING, 4700, s_Revolutionary
	invoke AppendMenu, hMenu2, MF_STRING, 4701, s_CIAagent
	invoke AppendMenu, hMenu2, MF_STRING, 4702, s_AgentOfTheKGB
	invoke AppendMenu, hMenu2, MF_STRING, 4703, s_Standard
	invoke AppendMenu, hMenu2, MF_STRING, 4704, s_CaptainAmerica
	invoke AppendMenu, hMenu2, MF_STRING, 4705, s_Revolution
	invoke AppendMenu, hMenu2, MF_STRING, 4706, s_Anonymous
	invoke AppendMenu, hMenu2, MF_STRING, 4707, s_Mechanic
	invoke AppendMenu, hMenu2, MF_STRING, 4708, s_Panda
	invoke AppendMenu, hMenu2, MF_STRING, 4709, s_Kamikaze
	invoke AppendMenu, hMenu2, MF_STRING, 4711, s_HolyFather
	invoke AppendMenu, hMenu, MF_STRING, 5000, s_About
	invoke SetMenu, hWnd, hMenu

	invoke crtwindow, s_EncryptAndCopy, offset id_button_enc_and_copy, hWnd, offset button, 20, 20, 180, 40, 058000000h, 0, offset VerdanaFont, 14, 400, 0, hInstance
	invoke crtwindow, 0, offset id_edit_password, hWnd, offset edit, 220, 20, 240, 40, 0500000A1h, 000000200h, offset VerdanaFont, 20, 400, 0, hInstance
	invoke SetFocus, eax
	invoke crtwindow, 0, offset id_edit_output, hWnd, offset edit, 20, 80, 440, 200, 058200044h xor WS_VISIBLE, 000000200h, offset VerdanaFont, 14, 400, 0, hInstance
	invoke SendMessage, h(offset id_edit_output), EM_SETHANDLE, mega_buff_out, 0
	invoke SendMessage, h(offset id_edit_output), EM_SETLIMITTEXT, 65536, 0
	invoke SetWindowLong, h(offset id_edit_output), GWL_WNDPROC, addr EditOutProc
	mov hEditOutProc, eax
	invoke crtwindow, 0, offset id_edit_input, hWnd, offset edit, 20, 300, 440, 60, 058200844h xor WS_VISIBLE, 000000200h, offset VerdanaFont, 14, 400, 0, hInstance
	invoke SendMessage, h(offset id_edit_input), EM_SETHANDLE, mega_buff_in, 0
	invoke SendMessage, h(offset id_edit_input), EM_SETLIMITTEXT, 65536, 0
	invoke SetWindowLong, h(offset id_edit_input), GWL_WNDPROC, addr EditInProc
	mov hEditInProc, eax
	invoke crtwindow, s_BigBrother1, offset id_statusbar, hWnd, offset statusbar, 0, 0, 0, 0, WS_CHILD or WS_VISIBLE, 0, offset VerdanaFont, 14, 400, 0, hInstance
	invoke SendMessage, eax, SB_SETMINHEIGHT, 35, 0
	invoke SendMessage, h(offset id_statusbar), SB_SETICON, 0, wc.hIcon

	invoke GetDC, hWnd
	mov hDCx, eax
	invoke CreateCompatibleDC, 0
	mov hDC1, eax
	invoke CreateCompatibleBitmap, hDCx, wwww, hhhh
	mov bitmap, eax
	invoke SelectObject, hDC1, bitmap
	invoke DeleteObject, bitmap
	invoke ReleaseDC, hWnd, hDCx

	mov ebx, hColor
	invoke DecorProc, hDecor
	mov hColor, ebx
	invoke SetColor, hWnd, hColor
	invoke rotate_image, FP4(0.0), 1
	invoke InvalidateRect, hWnd, 0, 1

.ELSEIF uMsg== WM_DROPFILES
	.if nPswd> 0
		invoke DragQueryFile, wParam, 0, offset temp_str, sizeof temp_str
		invoke DragFinish, wParam
		;invoke FocusSize, 1
	.else
		invoke MessageBox, hWnd, s_EnterPassword, addr RevEncryptor, MB_OK
		invoke SetFocus, h(offset id_edit_password)
	.endif

.ELSEIF uMsg== WM_DISPLAYCHANGE
	call SetBackgroundPos

.ELSEIF uMsg== WM_ACTIVATEAPP
	mov eax, wParam
	.if ax== 0
		invoke HideShow, SW_HIDE
		invoke SetLayeredWindowAttributes, hWnd, 0, 200, LWA_ALPHA
	.else
		invoke HideShow, SW_SHOW
		invoke SetLayeredWindowAttributes, hWnd, 0, 255, LWA_ALPHA
		invoke DecryptProc, hWnd
	.endif

.ELSEIF uMsg== WM_PAINT
	invoke Paint_Proc, hWnd

.ELSEIF uMsg== WM_CLOSE
	invoke ShowWindow, hWnd, SW_HIDE
	invoke KillTimer, hWin, 2303
	invoke DeleteObject, hBrush
	invoke DeleteObject, hPen
	invoke DeleteDC, hDC1
	invoke GdipDisposeImage, hIm511
	invoke GdipDisposeImage, hImCIA
	invoke GdipDisposeImage, hImKGB
	invoke GdipDisposeImage, hImMAS
	invoke GdipDisposeImage, hImCAP
	invoke GdipDisposeImage, hImREV
	invoke GdipDisposeImage, hImANO
	invoke GdipDisposeImage, hImMEC
	invoke GdipDisposeImage, hImPAN
	invoke GdipDisposeImage, hImKAM
	invoke GdipDisposeImage, hImFAT
	invoke GdiplusShutdown, gditoken
	invoke set_data, 0, addr fLng, 4
	invoke set_data, 0, addr hDecor, 4
	invoke set_data, 0, addr hColor, 4
	invoke set_data, 0, addr font_struct, sizeof LOGFONT
	invoke write_ini
	invoke free_lng
	invoke LocalFree, trans_buff1
	invoke LocalFree, trans_buff2
	invoke LocalFree, mega_buff_out
	invoke LocalFree, mega_buff_in
	invoke PostQuitMessage, 0
.ELSE
	invoke DefWindowProc, hWnd, uMsg, wParam, lParam
	ret
.ENDIF
return 0
RevEncryptorProc endp
;**********************************************************************************************************************************************************
HideShow proc hShow:DWORD
.if hShow== SW_SHOW
	invoke ShowWindow, h(offset id_button_enc_and_copy), SW_SHOW
	invoke ShowWindow, h(offset id_edit_password), SW_SHOW
	invoke ShowWindow, h(offset id_edit_output), SW_SHOW
	invoke ShowWindow, h(offset id_edit_input), SW_SHOW
.elseif hShow== SW_HIDE
	invoke ShowWindow, h(offset id_button_enc_and_copy), SW_HIDE
	invoke ShowWindow, h(offset id_edit_password), SW_HIDE
	invoke ShowWindow, h(offset id_edit_output), SW_HIDE
	invoke ShowWindow, h(offset id_edit_input), SW_HIDE
.endif
ret
HideShow endp
;**********************************************************************************************************************************************************
EnableProc proc hWnd:DWORD
	invoke SendMessage, h(offset id_edit_password), WM_GETTEXT, 2048, addr pswd_buff
	invoke lstrlen, addr pswd_buff
	mov nPswd, eax
	.if nPswd>= 10
		invoke DecryptProc, hWnd
		invoke EnableWindow, h(offset id_button_enc_and_copy), 1
		invoke EnableWindow, h(offset id_edit_output), 1
		invoke EnableWindow, h(offset id_edit_input), 1
	.else
		invoke EnableWindow, h(offset id_button_enc_and_copy), 0
		invoke EnableWindow, h(offset id_edit_output), 0
		invoke EnableWindow, h(offset id_edit_input), 0
	.endif
ret
EnableProc endp
;**********************************************************************************************************************************************************
Paint_Proc proc hWnd:DWORD
LOCAL hDC:DWORD, ps:PAINTSTRUCT, loc_poi:POINT, blfu:BLENDFUNCTION
	mrm loc_poi.x, img_poi.x
	mrm loc_poi.y, img_poi.y
	invoke ScreenToClient, hWnd, addr loc_poi
	invoke BeginPaint, hWnd, addr ps
	mov hDC, eax
	invoke BitBlt, hDC, loc_poi.x, loc_poi.y, wwww, hhhh, hDC1, 0, 0, SRCCOPY
	invoke EndPaint, hWnd, addr ps
ret
Paint_Proc endp
;**********************************************************************************************************************************************************
rotate_image proc ang:DWORD, scale:DWORD
LOCAL l_ww:DWORD, l_hh:DWORD
	cvtsi2ss XMM0, scale
	divss XMM0, FP4(10.0)
	movss scale, XMM0
	invoke GdipCreateFromHDC, hDC1, addr src_gr_con
	invoke GdipScaleWorldTransform, src_gr_con, scale, scale, MatrixOrderAppend
	invoke GdipRotateWorldTransform, src_gr_con, ang, 1
	cvtsi2ss XMM0, wwww
	divss XMM0, FP4(2.0)
	movss l_ww, XMM0
	cvtsi2ss XMM1, hhhh
	divss XMM1, FP4(2.0)
	movss l_hh, XMM1
	invoke GdipTranslateWorldTransform, src_gr_con, l_ww, l_hh, 1

	invoke SelectObject, hDC1, hBrush
	mov hBrushOld, eax
	invoke SelectObject, hDC1, hPen
	mov hPenOld, eax
	invoke Rectangle, hDC1, 0, 0, wwww, hhhh
	invoke SelectObject, hDC1, hPenOld
	invoke SelectObject, hDC1, hBrushOld

	mov eax, wwww
	shr eax, 1
	neg eax
	mov ecx, hhhh
	shr ecx, 1
	neg ecx
	invoke GdipDrawImageRectI, src_gr_con, hBmp, eax, ecx, wwww, hhhh
	invoke GdipResetWorldTransform, src_gr_con
	invoke GdipDeleteGraphics, src_gr_con
ret
rotate_image endp
;**********************************************************************************************************************************************************
BitmapFromResourceEx proc hModule:DWORD, ResNumber:DWORD
LOCAL hResource:DWORD, dwFileSize:DWORD, hImage:DWORD, s_image:DWORD, pStream:DWORD, pGlobal:DWORD, hResGlob:DWORD
	invoke FindResource, hModule, ResNumber, uc$("IMAGE")
	or eax, eax
	jnz @f
	invoke SetLastError, ERROR_FILE_NOT_FOUND
	xor eax, eax
	ret
@@:
	mov hResource, eax
	invoke LoadResource, hModule, hResource
	mov hResGlob, eax
	invoke LockResource, hResGlob
	mov hImage, eax
	invoke SizeofResource, hModule, hResource
	mov dwFileSize, eax
	.if dwFileSize
		invoke CoTaskMemAlloc, dwFileSize
		.if !eax
			ret
		.endif
		mov pGlobal, eax
		invoke MemoryCopy, hImage, pGlobal, dwFileSize
		invoke FreeResource, hResGlob
		invoke CreateStreamOnHGlobal, pGlobal, 1, addr pStream
		or eax, eax
		jz @f 
		invoke CoTaskMemFree, pGlobal
		return 0
	@@:
		invoke GdipLoadImageFromStream, pStream, addr s_image
		mov eax, pStream
		call release_pStream
		mov eax, s_image
	.else
		invoke SetLastError, ERROR_FILE_NOT_FOUND
		xor eax, eax
	.endif
ret
BitmapFromResourceEx  endp
;**********************************************************************************************************************************************************
release_pStream proc ;release the stream
	push eax
	mov eax, [eax]
	call [eax].IPicture.Release
ret
release_pStream endp
;**********************************************************************************************************************************************************
MemoryCopy proc hSource:DWORD, hDest:DWORD, hln:DWORD
	mov esi, hSource
	mov edi, hDest
	mov ecx, hln
	rep movsb
ret
MemoryCopy endp
;**********************************************************************************************************************************************************
DecorProc proc uses ebx hMode:DWORD
	.if hMode== 0
		mrm hBmp, hIm511
		invoke lstrcpy, addr tmp_status, s_BigBrother2
		mov hColor, 0bbbbbbh
		mov fLock, 0
	.elseif hMode== 1
		mrm hBmp, hImCIA
		invoke lstrcpy, addr tmp_status, s_BigBrother1
		mov hColor, 0ee8888h
		mov fLock, 1
	.elseif hMode== 2
		mrm hBmp, hImKGB
		invoke lstrcpy, addr tmp_status, s_BigBrother1
		mov hColor, 0550000h
		mov fLock, 1
	.elseif hMode== 3
		mrm hBmp, hImMAS
		invoke lstrcpy, addr tmp_status, addr RevEncryptor
		mov hColor, 0bbffbbh
		mov fLock, 0
	.elseif hMode== 4
		mrm hBmp, hImCAP
		invoke lstrcpy, addr tmp_status, addr RevEncryptor
		mov hColor, 0aaaaaah
		mov fLock, 0
	.elseif hMode== 5
		mrm hBmp, hImREV
		invoke lstrcpy, addr tmp_status, s_RevolutionWillBe
		mov hColor, 0bbeeeeh
		mov fLock, 1
	.elseif hMode== 6
		mrm hBmp, hImANO
		invoke lstrcpy, addr tmp_status, addr RevEncryptor
		mov hColor, 0000000h
		mov fLock, 1
	.elseif hMode== 7
		mrm hBmp, hImMEC
		invoke lstrcpy, addr tmp_status, addr RevEncryptor
		mov hColor, 0ccbbbbh
		mov fLock, 0
	.elseif hMode== 8
		mrm hBmp, hImPAN
		invoke lstrcpy, addr tmp_status, s_PartisAntiCorrupMovem
		mov hColor, 0ffffffh
		mov fLock, 1
	.elseif hMode== 9
		mrm hBmp, hImKAM
		invoke lstrcpy, addr tmp_status, addr RevEncryptor
		mov hColor, 0fec8bdh
		mov fLock, 0
	.elseif hMode== 10
		mrm hBmp, hImFAT
		invoke lstrcpy, addr tmp_status, addr RevEncryptor
		mov hColor, 0bbddbbh
		mov fLock, 1
	.endif
	invoke SetWindowText, h(offset id_statusbar), addr tmp_status
	invoke GdipGetImageWidth, hBmp, addr wwww
	invoke GdipGetImageHeight, hBmp, addr hhhh
	call SetBackgroundPos
ret
DecorProc endp
;**********************************************************************************************************************************************************
SetBackgroundPos proc
	invoke GetSystemMetrics, SM_CXSCREEN
	sub eax, wwww
	shr eax, 1
	mov img_poi.x, eax
	invoke GetSystemMetrics, SM_CYSCREEN
	sub eax, hhhh
	shr eax, 1
	mov img_poi.y, eax
ret
SetBackgroundPos endp
;**********************************************************************************************************************************************************
SetColor proc hWnd:DWORD, locColor:DWORD
LOCAL lb:LOGBRUSH
	invoke CreateSolidBrush, locColor
	invoke SetClassLong, hWnd, GCL_HBRBACKGROUND, eax
	cmp hBrush, 0
	je @F
	invoke DeleteObject, hBrush
	@@:
	cmp hPen, 0
	je @F
	invoke DeleteObject, hPen
	@@:
	mov lb.lbStyle, BS_SOLID
	mrm lb.lbColor, locColor ;-------------цвет фона
	invoke CreateBrushIndirect, addr lb
	mov hBrush, eax
	invoke CreatePen, 0, 1, locColor ;-------------цвет рамки
	mov hPen, eax
ret
SetColor endp
;**********************************************************************************************************************************************************
EditOutProc proc hEdit:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	.if uMsg== WM_LBUTTONUP
		invoke FocusSize, 0
	.endif
	invoke CallWindowProc, hEditOutProc, hEdit, uMsg, wParam, lParam
ret
EditOutProc endp
;**********************************************************************************************************************************************************
EditInProc proc hEdit:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	.if uMsg== WM_LBUTTONUP
		invoke FocusSize, 1
	.endif
	invoke CallWindowProc, hEditInProc, hEdit, uMsg, wParam, lParam
ret
EditInProc endp
;**********************************************************************************************************************************************************
FocusSize proc hMode:DWORD
LOCAL loc_rec:RECT
	invoke GetClientRect, hWin, addr loc_rec
	mov ebx, loc_rec.right
	sub ebx, cli_rec.right
	add ebx, 440
	.if hMode== 0
		invoke SetWindowPos, h(offset id_edit_output), HWND_TOP, 20, 80, ebx, 200, SWP_SHOWWINDOW
		invoke SetWindowPos, h(offset id_edit_input), HWND_TOP, 20, 300, ebx, 60, SWP_SHOWWINDOW
	.elseif hMode== 1
		invoke SetWindowPos, h(offset id_edit_output), HWND_TOP, 20, 80, ebx, 60, SWP_SHOWWINDOW
		invoke SetWindowPos, h(offset id_edit_input), HWND_TOP, 20, 160, ebx, 200, SWP_SHOWWINDOW
	.endif
ret
FocusSize endp
;**********************************************************************************************************************************************************
GetClipboardD proc hBuffer:DWORD, hWnd:DWORD
LOCAL hClip:DWORD
	invoke IsClipboardFormatAvailable, CF_UNICODETEXT
	cmp eax, 0
	je get_fail_1
	invoke OpenClipboard, hWnd
	cmp eax, 0
	je get_fail_1
	invoke GetClipboardData, CF_UNICODETEXT
	cmp eax, 0
	je get_fail_2
	mov hClip, eax
	invoke GlobalLock, hClip
	invoke lstrcpy, hBuffer, eax
	invoke GlobalUnlock, hClip
	invoke CloseClipboard
	return 1

get_fail_2:
invoke CloseClipboard
get_fail_1:
return 0
GetClipboardD endp
;**********************************************************************************************************************************************************
SetClipboardD proc hBuffer:DWORD, hWnd:DWORD
LOCAL trans_global:DWORD
	invoke OpenClipboard, hWnd
	cmp eax, 0
	je set_fail_1
	invoke EmptyClipboard
	invoke GlobalAlloc, GMEM_MOVEABLE, 1310720
	cmp eax, 0
	je set_fail_2
	mov trans_global, eax
	invoke GlobalLock, trans_global
	invoke lstrcpy, eax, hBuffer
	invoke GlobalUnlock, trans_global
	invoke SetClipboardData, CF_UNICODETEXT, trans_global
	cmp eax, 0
	je set_fail_3
	invoke CloseClipboard
	return 1

set_fail_3:
invoke GlobalFree, trans_global
set_fail_2:
invoke CloseClipboard
set_fail_1:
return 0
SetClipboardD endp
;**********************************************************************************************************************************************************
DecryptProc proc hWnd:DWORD
LOCAL loc_m1:DWORD, loc_m2:DWORD
.if nPswd> 0
	invoke GetClipboardD, trans_buff1, hWnd
	.if eax!= 0
		invoke CryptStringToBinary, trans_buff1, 0, CRYPT_STRING_BASE64, 0, addr loc_m1, 0, 0
		.if eax!= 0
			mov eax, loc_m1
			add eax, 64
			invoke LocalAlloc, 040h, eax
			mov loc_m2, eax
			invoke CryptStringToBinary, trans_buff1, 0, CRYPT_STRING_BASE64, loc_m2, addr loc_m1, 0, 0
			.if eax!= 0
				invoke WhirlpoolInit
				invoke lstrlen, addr pswd_buff
				mov ebx, eax
				shl ebx, 1 ; *2
				invoke WhirlpoolUpdate, addr pswd_buff, ebx
				invoke WhirlpoolFinal
				invoke digest2hex, eax, addr w_dig_hex, 16
				invoke AESDecrypt, loc_m2, addr loc_m1, offset w_dig_hex
				.if eax!= 0
					;invoke MultiByteToWideChar, CP_ACP, 0, addr w_dig_hex, -1, trans_buff1, MAX_PATH
					invoke SendMessage, h(offset id_edit_input), WM_SETTEXT, 0, loc_m2
					invoke FocusSize, 1
					invoke SetWindowText, h(offset id_statusbar), s_Decrypted ;Дешифровано
				.else
					invoke SetWindowText, h(offset id_statusbar), s_CiphIsCorOrPassIsIncor ;Шифр повреждён либо пароль неправильный
				.endif
			.endif
			invoke LocalFree, loc_m2
		.else
			invoke SetWindowText, h(offset id_statusbar), s_CipherNotRecognized ;Шифр не опознан
		.endif
	.else
		invoke SetWindowText, h(offset id_statusbar), s_BufferIsEmpty ;Буфер пуст
	.endif
.else
	invoke PostMessage, hWnd, WM_COMMAND, xparam(BN_CLICKED, 4800), 0 ;set focus -> password
.endif
ret
DecryptProc endp
;**********************************************************************************************************************************************************
BSProc proc uses ebx esi edi ebp in_buf:DWORD, out_buf:DWORD
mov esi, in_buf
mov edi, out_buf
xor edx, edx
start_bs:
cmp word ptr[esi], 0
je end_bs
	cmp dword ptr[esi], 000a000dh ; пропустить перенос строки
	je ad_bs
		cmp edx, 16  ; через 16 tchar
		je @F
			mov ax, word ptr[esi]
			mov word ptr[edi], ax
			add esi, 2
			add edi, 2
			inc edx
			jmp start_bs
		@@:
		mov word ptr[edi], 0020h ; ' '
		add edi, 2
		xor edx, edx
		jmp start_bs
	ad_bs:
	add esi, 4
	jmp start_bs
end_bs:
mov word ptr[edi], 0
ret
BSProc endp
;**********************************************************************************************************************************************************
digest2hex proc hDigest:DWORD, out_buff:DWORD, nDWord:DWORD
LOCAL m1:DWORD
	mrm m1, nDWord
	@@:
	cmp m1, 0
	je @F
	mov eax, hDigest
	mov ecx, dword ptr[eax]
	xchg ch, cl
	ror ecx, 16
	xchg ch, cl
	mov ebx, out_buff
	invoke dw2hex, ecx, ebx
	add hDigest, 4
	add out_buff, 8
	dec m1
	jmp @B
	@@:
ret
digest2hex endp
;**********************************************************************************************************************************************************
ColorProc proc hWnd:DWORD, hRGB:DWORD
LOCAL ccl:CHOOSECOLOR
	mrm ccl.rgbResult, hRGB
	mov ccl.lStructSize, sizeof CHOOSECOLOR
	mrm ccl.hwndOwner, hWnd
	mrm ccl.hInstance, hInstance
	lea ebx, listColor
	mov ccl.lpCustColors, ebx
	mov ccl.Flags, CC_RGBINIT
	mov ccl.lCustData, 0
	mov ccl.lpfnHook, 0
	mov ccl.lpTemplateName, 0
	invoke ChooseColor, addr ccl
return ccl.rgbResult
ColorProc endp
;**********************************************************************************************************************************************************
Font_Dialog proc hWnd:DWORD, lf:DWORD, fStyle:DWORD
LOCAL hDC:DWORD, cf:CHOOSEFONT
    invoke GetDC, hWnd
    push eax
    mov hDC, eax
    mov cf.lStructSize, sizeof CHOOSEFONT
    push hWnd
    pop cf.hWndOwner
    pop eax
    mov cf.hDC, eax
    push lf
    pop cf.lpLogFont
    mov cf.iPointSize, 0
    push fStyle
    pop cf.Flags
    mov cf.rgbColors, 0
    mov cf.lCustData, 0
    mov cf.lpfnHook, 0
    mov cf.lpTemplateName, 0
    mov cf.hInstance, 0
    mov cf.lpszStyle, 0
    mov cf.nFontType, 0
    mov cf.Alignment, 0
    mov cf.nSizeMin, 0
    mov cf.nSizeMax, 0
    invoke ChooseFont, addr cf
    push eax
    invoke ReleaseDC, hWnd, hDC
    pop eax
ret
Font_Dialog endp
;**********************************************************************************************************************************************************
;include w.asm
;**********************************************************************************************************************************************************
end start
