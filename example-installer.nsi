; Define Installer Name and Output
Outfile "YTDownloader-installer.exe"
InstallDir "$LOCALAPPDATA\YTDownloader"
RequestExecutionLevel admin ; Ensure it runs with admin rights

; Include required plugins for downloading files
!include "MUI2.nsh"
!include "WinInet.nsh"  ; For downloading files

Section "Install My App"
    ; Create installation directory
    SetOutPath "$INSTDIR"

    ; Copy main application files from installer directory
    File "PATH\TO\GITPROJECT\ytdownloader.exe"
    File "PATH\TO\GITPROJECT\yt-dlp.exe"

    ; Download ZIP file from GitHub
    inetc::get "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip" "$INSTDIR\ffmpeg-master-latest-win64-gpl.zip"

    ; Extract specific files from ZIP
    nsExec::Exec 'powershell -command "Expand-Archive -Path \"$INSTDIR\ffmpeg-master-latest-win64-gpl.zip\" -DestinationPath \"$INSTDIR\tmp\" -Force"'

    ; Move the 3 specific files to the installation folder
    CopyFiles "$INSTDIR\tmp\ffmpeg-master-latest-win64-gpl\bin\ffmpeg.exe" "$INSTDIR\ffmpeg.exe"
    CopyFiles "$INSTDIR\tmp\ffmpeg-master-latest-win64-gpl\bin\ffplay.exe" "$INSTDIR\ffplay.exe"
    CopyFiles "$INSTDIR\tmp\ffmpeg-master-latest-win64-gpl\bin\ffprobe.exe" "$INSTDIR\ffprobe.exe"

    ; Clean up extracted files
    RMDir /r "$INSTDIR\tmp"
    Delete "$INSTDIR\ffmpeg-master-latest-win64-gpl.zip"

    ; Add an uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; Create a desktop shortcut
    CreateShortcut "$DESKTOP\YT Downloader.lnk" "$INSTDIR\ytdownloader.exe"

    ; Notify user
    MessageBox MB_OK "Installation complete! Necessary files downloaded from GitHub and installed."
SectionEnd

; Uninstaller Section
Section "Uninstall"
    Delete "$INSTDIR\ytdownloader.exe"
    Delete "$INSTDIR\yt-dlp.exe"
    Delete "$INSTDIR\ffmpeg.exe"
    Delete "$INSTDIR\ffplay.exe"
    Delete "$INSTDIR\ffprobe.exe"
    Delete "$INSTDIR\Uninstall.exe"
    RMDir "$INSTDIR"
    Delete "$DESKTOP\YT Downloader.lnk"
SectionEnd
