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
$fpath = $Args[2]

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

function transfer_file($ft) {

    if ($enable_transfer -eq 1 -AND (Get-Item -Path "$fpath\$ft" )) {
        #Call winscp and pass parameters
        & "$winSCPLoc\WinSCP.com" `
            /log="$winSCPLoc\WinSCP.log" /ini=nul `
            /command `
            "open sftp://pi:Brymed%232020@192.168.1.121/ -hostkey=`"`"ssh-ed25519 255 Kdrw/Wlbl2hUooxtp4idYQUllH54YYSXT8O8UtKb2hw=`"`"" `
            "put $fpath\$ft $rem_saveFolder/$cat/" `
            "exit"

        $winscpResult = $LastExitCode
        if ($winscpResult -eq 0) {

            Start-Sleep -s 1

            #If transfer is successful delete movie from folder
            if ($del_file -eq 1) {
                Remove-Item $fpath\$ft
                Write-Host "Removed -  $ft"
            }

        }
        else {
            Write-Host "Error with WinSCP Transfer"
        }
    }
}

function convert_file($file) {

    $fileBase = $file.BaseName

    #Assign Video/Audio codecs to variables
    $ffprobe = Get-Command -CommandType Application -Name $ffmpegLoc\'ffprobe.exe' -ErrorAction SilentlyContinue
    $ffprobe = $ffprobe.Source
    $ffmpeg = Get-Command -CommandType Application -Name $ffmpegLoc\'ffmpeg.exe' -ErrorAction SilentlyContinue
    $ffmpeg = $ffmpeg.Source

    $vidC = $(& $ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nokey=1:noprint_wrappers=1 "$fpath\$file")
    
    if ($file.Extension -ne '.srt' -Or $file.Extension -ne '.en.srt') {

        #IF NOT H264 & MP4, CONVERT
        if (($file.Extension -ne '.mp4' -AND $vidC -eq 'h264') -OR ($file.Extension -eq '.mp4' -AND $vidC -ne 'h264')) {
            
            & $ffmpeg -i $fpath\$file -c:v libx264 -preset veryfast -crf 23 -c:a aac "$fpath\$fileBase.mp4"
            
            #Pass to transfer function for processing
            transfer_file("$fileBase.mp4")

            #delete original file after conversion
            Remove-Item  $fpath\$file
            Write-Host "Removed -  $file"
        }
        #transfer if mp4 and h264 codec   
        else {
            transfer_file("$file")
        }
    } 
  
    #Pass to transfer function for processing subtitle
    else {
        transfer_file("$file")
    }
}

#Loop through files in fpath location and send to convert_file function for processing
$files = Get-ChildItem -File "$fpath"
foreach ($f in $files) {
    #File is movie or subtitle
    if ($f.Extension -in $ext_array) {
        convert_file($f)
    }
    else {
        Remove-Item $fpath\$f
        Write-Host "Removed -  $f"
    }
}

#If the movie path does not equal the save folder path delete movie folder
if ("$fpath" -ne "$path") {
    Remove-Item $fpath -Recurse
    Write-Host "Removed -  $fpath"
}

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');