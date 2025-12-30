

!ifndef BUILD_DIR
  !define BUILD_DIR ".\dist"
!endif

Unicode true
ManifestDPIAware true

!define APP_NAME "Programa"
!define SHORT_APP_NAME "Programa"
!define COMP_NAME "NaxiStudio Project"
!define WEB_SITE "https://naxistudio.pages.dev"
!ifndef VERSION
  !define VERSION "v0.0.1" #<major version>.<minor version>.<build number>
!endif
!ifndef CLEAN_VERSION
  !define CLEAN_VERSION "0.0.1" #<major version>.<minor version>.<build number>
!endif
!define COPYRIGHT "Bruno Cardoso © 2025"
!define DESCRIPTION "Teste do Github Actions."
!define LICENSE_TXT "${BUILD_DIR}/../COPYING"
!define INSTALLER_NAME "${BUILD_DIR}/../${APP_NAME}-${VERSION}-Installer-Windows-x86_64.exe"
!define MAIN_APP_EXE "${APP_NAME}.exe"
!define INSTALL_TYPE "SetShellVarContext all"
!define REG_ROOT "HKLM"
!define REG_APP_PATH "Software\Microsoft\Windows\CurrentVersion\App Paths\${MAIN_APP_EXE}"
!define UNINSTALL_PATH "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"

!define APPNAMEANDVERSION "${APP_NAME} ${VERSION}"

######################################################################

!include WinVer.nsh
!include x64.nsh

######################################################################

VIProductVersion  "${CLEAN_VERSION}.0"
VIAddVersionKey "ProductName"  "${APP_NAME}"
VIAddVersionKey "CompanyName"  "${COMP_NAME}"
VIAddVersionKey "LegalCopyright"  "${COPYRIGHT}"
VIAddVersionKey "FileDescription"  "${DESCRIPTION}"
VIAddVersionKey "FileVersion"  "${VERSION}"

######################################################################

SetCompressor ZLIB
Name "${APPNAMEANDVERSION}"
Caption "${APP_NAME}"
OutFile "${INSTALLER_NAME}"
BrandingText "${APP_NAME}"
XPStyle on
InstallDirRegKey "${REG_ROOT}" "${REG_APP_PATH}" ""
InstallDir "$PROGRAMFILES64\${SHORT_APP_NAME}"

######################################################################

RequestExecutionLevel admin ; Need Admin

!include "MUI.nsh"

!define MUI_ICON "icon.ico"
!define MUI_UNICON "icon.ico"
!define MUI_HEADERIMAGE_BITMAP "header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "banner.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "banner.bmp"

!define MUI_ABORTWARNING
!define MUI_UNABORTWARNING

!define MUI_LANGDLL_REGISTRY_ROOT "${REG_ROOT}"
!define MUI_LANGDLL_REGISTRY_KEY "${UNINSTALL_PATH}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

######################################################################
  
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE PreReqCheck

!define MUI_HEADERIMAGE

!define MUI_FINISHPAGE_RUN

!define MUI_FINISHPAGE_RUN_FUNCTION "Launch"
!define MUI_FINISHPAGE_SHOWREADME "https://github.com/BrunoCardosoFS/Teste-Actions-Qt/releases/"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED

!define MUI_FINISHPAGE_LINK_LOCATION "${WEB_SITE}/quick-start-guide"
!define MUI_FINISHPAGE_LINK "New to ${APP_NAME}? Check out our 4-step Quickstart Guide."
!define MUI_FINISHPAGE_LINK_COLOR 000080


######################################################################

!ifdef REG_START_MENU
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "${APP_NAME}"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${REG_ROOT}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${UNINSTALL_PATH}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${REG_START_MENU}"
!insertmacro MUI_PAGE_STARTMENU Application $SM_Folder
!endif

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${LICENSE_TXT}"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "PortugueseBR"
!insertmacro MUI_RESERVEFILE_LANGDLL

######################################################################

LangString MUI_WELCOMEPAGE_TEXT ${LANG_ENGLISH} \
  "This setup will guide you through installing ${APP_NAME}.\n\nIt is recommended that you close all other applications before starting, including ${APP_NAME}. This will make it possible to update relevant files without having to reboot your computer.\n\nClick Next to continue."

LangString MUI_WELCOMEPAGE_TEXT ${LANG_PORTUGUESEBR} \
  "Este assistente irá guiá-lo na instalação do ${APP_NAME}.\n\nÉ recomendável que você feche todos os outros aplicativos antes de começar, incluindo o ${APP_NAME}. Isso tornará possível atualizar arquivos relevantes sem precisar reiniciar o computador.\n\nClique em Avançar para continuar."

; !define MUI_FINISHPAGE_TITLE "Completed Setup"
LangString MUI_FINISHPAGE_TITLE ${LANG_ENGLISH} "Completed Setup"
LangString MUI_FINISHPAGE_TITLE ${LANG_PORTUGUESEBR} "Instalação Concluída"

; !define MUI_FINISHPAGE_RUN_TEXT "Launch ${APPNAMEANDVERSION}"
LangString MUI_FINISHPAGE_RUN_TEXT ${LANG_ENGLISH} "Launch ${APPNAMEANDVERSION}"
LangString MUI_FINISHPAGE_RUN_TEXT ${LANG_PORTUGUESEBR} "Iniciar ${APPNAMEANDVERSION}"

; !define MUI_FINISHPAGE_SHOWREADME_TEXT "View Release Notes"
LangString MUI_FINISHPAGE_SHOWREADME_TEXT ${LANG_ENGLISH} "View Release Notes"
LangString MUI_FINISHPAGE_SHOWREADME_TEXT ${LANG_PORTUGUESEBR} "Ver Notas de Lançamento"

######################################################################

Function .onInit
!insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

######################################################################

; Section "Visual Studio Runtime"
;   SetOutPath "$INSTDIR"
;   File "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Redist\MSVC\14.40.33807\vc_redist.x64.exe"
;   ExecWait "$INSTDIR\vc_redist.x64.exe /quiet /norestart"
;   Delete "$INSTDIR\vc_redist.x64.exe"
; SectionEnd

Section -MainProgram
SetRegView 64
${INSTALL_TYPE}
SetOverwrite ifnewer
SetOutPath "$INSTDIR"
File /r "${BUILD_DIR}\*"
SectionEnd

######################################################################

Section -Icons_Reg
SetOutPath "$INSTDIR"
WriteUninstaller "$INSTDIR\uninstall.exe"

; !ifdef REG_START_MENU
; !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
; CreateDirectory "$SMPROGRAMS\$SM_Folder"
; CreateShortCut "$SMPROGRAMS\$SM_Folder\${APP_NAME}.lnk" "$INSTDIR\${MAIN_APP_EXE}"
; CreateShortCut "$SMPROGRAMS\$SM_Folder\Uninstall ${APP_NAME}.lnk" "$INSTDIR\uninstall.exe"
; !insertmacro MUI_STARTMENU_WRITE_END
; !endif

!ifndef REG_START_MENU
CreateDirectory "$SMPROGRAMS\${APP_NAME}"
CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${MAIN_APP_EXE}"
CreateShortCut "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk" "$INSTDIR\uninstall.exe"
!endif

WriteRegStr ${REG_ROOT} "${REG_APP_PATH}" "" "$INSTDIR\${MAIN_APP_EXE}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "DisplayName" "${APP_NAME}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "UninstallString" "$INSTDIR\uninstall.exe"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "DisplayIcon" "$INSTDIR\${MAIN_APP_EXE}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "DisplayVersion" "${VERSION}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "Publisher" "${COMP_NAME}"

!ifdef WEB_SITE
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "URLInfoAbout" "${WEB_SITE}"
!endif
SectionEnd

######################################################################

Section Uninstall
${INSTALL_TYPE} 
Delete "$INSTDIR\uninstall.exe"
RMDir /r "$INSTDIR"

; !ifdef REG_START_MENU
; !insertmacro MUI_STARTMENU_GETFOLDER "Application" $SM_Folder
; Delete "$SMPROGRAMS\$SM_Folder\${APP_NAME}.lnk"
; !endif

!ifndef REG_START_MENU
Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
Delete "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk"
!endif

DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}"
DeleteRegKey ${REG_ROOT} "${UNINSTALL_PATH}"
SectionEnd

######################################################################

Function un.onInit
!insertmacro MUI_UNGETLANGUAGE
FunctionEnd

######################################################################

Function Launch
	Exec '"$INSTDIR\${MAIN_APP_EXE}"'
FunctionEnd

######################################################################

Function PreReqCheck
	${if} ${RunningX64}
	${Else}
		IfSilent +1 +3
			SetErrorLevel 3
			Quit
		MessageBox MB_OK|MB_ICONSTOP "${APP_NAME} is not compatible with your operating system's architecture."
	${EndIf}
	; Abort on 8.1 or lower

	${If} ${AtLeastWin10}
	${Else}
		IfSilent +1 +3
			SetErrorLevel 3
			Quit
		MessageBox MB_OK|MB_ICONSTOP "${APP_NAME} requires Windows 10 or higher and cannot be installed on this version of Windows."
		Quit
	${EndIf}
FunctionEnd