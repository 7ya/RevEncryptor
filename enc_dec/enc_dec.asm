; Update date:		 11.7.2017
; Contact:			 https://twitter.com/revencryptor
; Channel:           https://t.me/RevEncryptor
;**********************************************************************************************************************************************************
__UNICODE__ equ 1
include \masm32\include\masm32rt.inc
include \masm32\include\crypt32.inc
includelib \masm32\lib\crypt32.lib
include \masm32\include\cryptdll.inc
includelib \masm32\lib\cryptdll.lib
include \masm32\include\advapi32.inc
includelib \masm32\lib\advapi32.lib

AESEncrypt       proto :DWORD, :DWORD, :DWORD
AESDecrypt       proto :DWORD, :DWORD, :DWORD

.const
	ALG_CLASS_DATA_ENCRYPT	equ 3 SHL 13
	ALG_TYPE_BLOCK			equ 3 SHL 9
	ALG_SID_AES_128			equ 14
	ALG_SID_AES_192			equ 15
	ALG_SID_AES_256			equ 16
	CALG_AES_128			equ ALG_CLASS_DATA_ENCRYPT or ALG_TYPE_BLOCK or ALG_SID_AES_128
	CALG_AES_192			equ ALG_CLASS_DATA_ENCRYPT or ALG_TYPE_BLOCK or ALG_SID_AES_192
	CALG_AES_256			equ ALG_CLASS_DATA_ENCRYPT or ALG_TYPE_BLOCK or ALG_SID_AES_256

	ALG_CLASS_HASH			equ 4 SHL 13
	ALG_TYPE_ANY			equ 0
	ALG_SID_SHA_256			equ 12
	ALG_SID_SHA_384			equ 13
	ALG_SID_SHA_512			equ 14
	CALG_SHA_256			equ (ALG_CLASS_HASH or ALG_TYPE_ANY or ALG_SID_SHA_256)
	CALG_SHA_384			equ (ALG_CLASS_HASH or ALG_TYPE_ANY or ALG_SID_SHA_384)
	CALG_SHA_512			equ (ALG_CLASS_HASH or ALG_TYPE_ANY or ALG_SID_SHA_512)

.data
    UC s_RSAandAESCryptProv,  "Microsoft Enhanced RSA and AES Cryptographic Provider", 0

.data?
    hProv     dd ?
    hHash     dd ?
	hKey      dd ?

.code
;**********************************************************************************************************************************************************
AESEncrypt proc uses ebx userInf:DWORD, len_in_out_Inf:DWORD, userKey:DWORD
invoke CryptAcquireContext, addr hProv, 0, addr s_RSAandAESCryptProv, PROV_RSA_AES, CRYPT_VERIFYCONTEXT ;CryptReleaseContext
.if eax!= 0
	invoke CryptCreateHash, hProv, CALG_SHA_512, 0, 0, addr hHash ;CryptDestroyHash
	.if eax!= 0
		invoke lstrlenA, userKey ;ASCII
		invoke CryptHashData, hHash, userKey, eax, 0
		.if eax!= 0
			invoke CryptDeriveKey, hProv, CALG_AES_256, hHash, 0, addr hKey ;CryptDestroyKey
			.if eax!= 0
				invoke CryptEncrypt, hKey, 0, TRUE, 0, userInf, len_in_out_Inf, 1310720
				mov ebx, eax
				invoke CryptDestroyKey, hKey
				invoke CryptDestroyHash, hHash
				invoke CryptReleaseContext, hProv, 0
				return ebx
			.else
				invoke CryptDestroyHash, hHash
				invoke CryptReleaseContext, hProv, 0
				return 0;error
			.endif
		.else
			invoke CryptDestroyHash, hHash
			invoke CryptReleaseContext, hProv, 0
			return 0;error
		.endif
	.else
		invoke CryptReleaseContext, hProv, 0
		return 0;error
	.endif
.else
	return 0;error
.endif
return 0
AESEncrypt endp
;**********************************************************************************************************************************************************
AESDecrypt proc uses ebx userInf:DWORD, len_in_out_Inf:DWORD, userKey:DWORD
invoke CryptAcquireContext, addr hProv, 0, addr s_RSAandAESCryptProv, PROV_RSA_AES, CRYPT_VERIFYCONTEXT ;CryptReleaseContext
.if eax!= 0
	invoke CryptCreateHash, hProv, CALG_SHA_512, 0, 0, addr hHash ;CryptDestroyHash
	.if eax!= 0
		invoke lstrlenA, userKey ;ASCII
		invoke CryptHashData, hHash, userKey, eax, 0
		.if eax!= 0
			invoke CryptDeriveKey, hProv, CALG_AES_256, hHash, 0, addr hKey ;CryptDestroyKey
			.if eax!= 0
				invoke CryptDecrypt, hKey, 0, TRUE, 0, userInf, len_in_out_Inf
				mov ebx, eax
				invoke CryptDestroyKey, hKey
				invoke CryptDestroyHash, hHash
				invoke CryptReleaseContext, hProv, 0
				return ebx
			.else
				invoke CryptDestroyHash, hHash
				invoke CryptReleaseContext, hProv, 0
				return 0;error
			.endif
		.else
			invoke CryptDestroyHash, hHash
			invoke CryptReleaseContext, hProv, 0
			return 0;error
		.endif
	.else
		invoke CryptReleaseContext, hProv, 0
		return 0;error
	.endif
.else
	return 0;error
.endif
return 0
return 0
AESDecrypt endp
;**********************************************************************************************************************************************************
end
