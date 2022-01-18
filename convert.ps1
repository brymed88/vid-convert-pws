## Author:Brycen Medart
## URL:https://treantlabs.com
## Version: 1.0
## License: MIT License

##--------------
# Argument Variables - Do not change unless use case is understood
# Variables for path, category and full file path arguments
##--------------------
$path = $Args[0]
$cat = $Args[1]
$lit_path = Get-Item -LiteralPath $Args[2]

#Array of file types
$ext_array = @(".avi", ".flv", ".mkv", ".mov", ".mp4", ".wmv", ".srt", ".en.srt")

##-------------
#Global change variables - Change to configure for your environment.
##--------------------

#Remove converted local file after transfer 0=no 1=yes
$del_file = 1

#FFMPEG and WINSCP folders
$ffmpegLoc = "C:\Users\bryce\Videos\TOR\ffmpeg"
$winSCPLoc = "C:\Users\bryce\Videos\TOR\WinSCP-5.19.3-Portable"

#Remote Server Information For SFTP Transfer. Alter these values to match your environment.
$enable_transfer = 1
$rem_saveFolder = "/media/PIPLEX"


function transfer_file($file) {

    Write-Host "Transferring - $file to server"
    if ($enable_transfer -eq 1 -AND (Get-Item -LiteralPath $file )) {
        #Call winscp and pass parameters
        & "$winSCPLoc\WinSCP.com" `
            /log="$winSCPLoc\WinSCP.log" /ini=nul `
            /command `
            "open sftp://pi:Brymed%232020@192.168.1.121/ -hostkey=`"`"ssh-ed25519 255 Kdrw/Wlbl2hUooxtp4idYQUllH54YYSXT8O8UtKb2hw=`"`"" `
            "put $file $rem_saveFolder/$cat/" `
            "exit"

        $winscpResult = $LastExitCode
        if ($winscpResult -eq 0) {
            Start-Sleep -s 1

            #If transfer is successful delete movie from folder
            if ($del_file -eq 1) {
                Write-Host "Removed -  $file after winSCP transfer"
                Remove-Item $file
            }
        }
        else {
            Write-Host "Error with WinSCP Transfer"
        }
    }
}
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
    
                $vidC = $(& $ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nokey=1:noprint_wrappers=1 $joined_path)
        
                #IF NOT H264 & MP4, CONVERT
                if (($file_ext -ne '.mp4' -AND $vidC -eq 'h264') -OR ($file_ext -eq '.mp4' -AND $vidC -ne 'h264')) {
                    & $ffmpeg -i $joined_path -c:v libx264 -preset veryfast -crf 23 -c:a aac "$lit_path\$fileBase.mp4"
                    
                    #Pass to transfer function for processing
                    transfer_file("$lit_path\$fileBase.mp4")
        
                    #delete original file after conversion
                    Write-Host "Removed original file -  $f - Conversion Complete"
                    Remove-Item  -LiteralPath $joined_path
                    
                }
                #transfer if mp4 and h264 codec   
                else {
                    transfer_file("$f")
                }
            } 
            #Pass to transfer function for processing subtitle
            else {
                transfer_file("$f")
            }
        }
        else {
            Remove-Item  -LiteralPath $lit_path\$f
            Write-Host "Removing file - $f - incorrect file type!"
        }
    }

    #if directory empty and video folder is not the $path folder
    if ((-Not (Test-Path $lit_path*)) -AND $lit_path -ne $path ) {
        Write-Host "Removing folder - $lit_path"
        Remove-Item -LiteralPath $lit_path -Recurse
    }        
}

process_file
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');