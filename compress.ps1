## Author:Brycen Medart
## URL:https://treantlabs.com
## Version: 1.0
## License: MIT License

##--------------
# Argument Variables - Do not change unless use case is understood
# Variables for path, category and full file path arguments
##--------------------
$lit_path = Get-Item -LiteralPath $Args[0]
$lit_path_save = Get-Item -LiteralPath $Args[1]

#Array of file types
$ext_array = @(".avi", ".flv", ".mkv", ".mov", ".mp4", ".wmv", ".srt", ".en.srt")

##-------------
#Global change variables - Change to configure for your environment.
##--------------------

#FFMPEG and WINSCP folders
$ffmpegLoc = "C:\Users\bryce\Videos\TOR\ffmpeg"



function process_file() {
    #get files from parent folder
    $files = Get-ChildItem -LiteralPath $lit_path

    #loop files for those matching array above
    foreach ($f in $files) {

        #File is movie or subtitle
        if ($f.Extension -in $ext_array) {
            $joined_path = Join-Path $lit_path -ChildPath $f
            $fileBase = $f.BaseName
            $file_ext = $f.Extension

            #if movie file
            if ($file_ext -ne '.srt' -Or $file_ext -ne '.en.srt') {
                Write-Host "Converting file - $f"
                #Assign Video/Audio codecs to variables
                $ffprobe = Get-Command -CommandType Application -Name $ffmpegLoc\'ffprobe.exe' -ErrorAction SilentlyContinue
                $ffprobe = $ffprobe.Source
                $ffmpeg = Get-Command -CommandType Application -Name $ffmpegLoc\'ffmpeg.exe' -ErrorAction SilentlyContinue
                $ffmpeg = $ffmpeg.Source
        
                #IF NOT H264 & MP4, CONVERT
                & $ffmpeg -i $joined_path -c:v libx264 -preset medium -crf 24 -c:a aac "$lit_path_save\$fileBase.mp4"
            }
        }    
    }
}
    process_file
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');