## Author:Brycen Medart
## URL:https://treantlabs.com
## Version: 1.1
## License: MIT License

#   Argument Variables - Do not change unless use case is understood
#   Variables for path, category and full file path arguments

$inputObj = (
    @{
        category = $Args[0]
        full_path = $Args[1]
    }
)

#   Global change variables - Change to configure for your environment.

#   Filetype array
$ext_array = @(".avi", ".flv", ".mkv", ".mov", ".mp4", ".wmv", ".srt", ".en.srt")

#   FFMPEG variables
$crf_quality = 24
$preset = "medium"
$desired_acodec = "aac"

#   This setting will remove non MP4 files after processing and remove the M | 0=no 1=yes
$del_file = 1

#   Remove parent directory upon conversion completion | 0=no 1=yes
$del_parent =1

#   Enable SFTP Transfer | 0=no 1=yes
$sftp_transfer = 1

#   FFMPEG and WINSCP folders
$ffmpeg_location = "D:\TOR\ffmpeg-5.0-essentials_build\bin"
$winscp_location = "D:\TOR\WinSCP-5.19.6-Automation"

#   Remote Server Information For SFTP Transfer. Alter these values to match your environment.
$ssh_private_key_loc = "C:\Users\bryce\.ssh\rsa-piplex.ppk"
$ssh_fingerprint = "ssh-ed25519 255 Kdrw/Wlbl2hUooxtp4idYQUllH54YYSXT8O8UtKb2hw="
$remote_address = "192.168.1.121"
$remote_user = "pi"
$remote_folder = "/media/PIPLEX"

function transfer_file($file) {

    try  {
        # Load WinSCP .NET assembly
        Add-Type -Path "$($winscp_location)\WinSCPnet.dll"
 
        Write-Host "Info: Transferring file to remote server"
        # Setup session options
        $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
            Protocol = [WinSCP.Protocol]::Sftp
            HostName = $remote_address
            UserName = $remote_user
            SshPrivateKeyPath = $ssh_private_key_loc
            SshHostKeyFingerprint = $ssh_fingerprint
        }
 
        $session = New-Object WinSCP.Session
 
        try {
            # Connect
            $session.Open($sessionOptions)
 
            # Upload files
            $transferOptions = New-Object WinSCP.TransferOptions
            $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
 
            $transferResult =
                $session.PutFiles("$($file)", "$($remote_folder)/$($inputObj.category)/", $False, $transferOptions)
 
            # Throw on any error
            $transferResult.Check()
 
            # Print results
            foreach ($transfer in $transferResult.Transfers)
            {
                Write-Host "Info: Upload succeeded"
                Write-Host "Warn: Removing file after transfer"
                Remove-Item -LiteralPath $file
            }
        }
    finally {
        # Disconnect, clean up
        $session.Dispose()
    }
 
}
catch   {
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}}

function ConvertFile($path){

    $file = Get-Item -LiteralPath $path
    if ($file.Extension -ne '.srt' -Or $file.Extension -ne '.en.srt') {

           

            #   Assign Video/Audio codecs to variables
            $ffprobe = Get-Command -CommandType Application -Name "$($ffmpeg_location)\ffprobe.exe" -ErrorAction SilentlyContinue
            $ffprobe = $ffprobe.Source
            $ffmpeg = Get-Command -CommandType Application -Name "$($ffmpeg_location)\ffmpeg.exe" -ErrorAction SilentlyContinue
            $ffmpeg = $ffmpeg.Source

            $vcodec = $(& $ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nokey=1:noprint_wrappers=1 $file.FullName)

                #   IF Codec does not equal H264 and MP4, CONVERT
                if ($vcodec -ne 'h264' -Or $file.Extension -ne '.mp4') {
                    Write-Host "Info: Beginning conversion of - $($file.name)"

                    $tmp_file = "$($file.DirectoryName)\tmp_$($file.BaseName).mp4"

                    Write-Host "Info: Running ffmpeg conversion"
                    & $ffmpeg -v quiet -stats -i $file.FullName -c:v libx264 -preset $($preset) -crf $($crf_quality) -c:a $($desired_acodec) $tmp_file
                    Write-Host "Info: Conversion complete!"
                    #   delete original file after conversion
                    Write-Host "Warn: Removing original file -  $($file.Name)"
                    Remove-Item  -LiteralPath $file.FullName

                    #   Rename converted file to the original file name that is now deleted
                    Rename-Item -LiteralPath $tmp_file -NewName "$($file.BaseName).mp4"

                    #   If sftp_transfer enabled pass to sftp_transfer function
                    if($sftp_transfer -eq 1){
                        transfer_file("$($file.DirectoryName)\$($file.BaseName).mp4")
                    }
                    
                }

                #   Sftp_transfer if mp4 and h264 codec
                else{
                        Write-Host "Info: Conversion not required - Beginning transfer of $($file.BaseName)"
                        transfer_file($file.FullName)
                }

    }
    else    {
            #   Rename srt file with en extension
            Rename-Item -LiteralPath $file -NewName "$($file.BaseName).en.srt"
                
            if($sftp_transfer -eq 1){
                transfer_file("$($file.DirectoryName)\$($file.BaseName).en.srt")
            }
        }

    }


#   Identify files before sending to ConvertFile function for video conversion

Write-Host @"
Author: Brycen Medart 
URL: https://treantlabs.com
Version: 1.0
License: MIT License
-----------------------------

"@

#   If path supplied is file
if((Test-Path -LiteralPath $inputObj.full_path -PathType leaf) -eq $true){
    
    #   Write-Host "File Provided"
    
    $file = Get-Item -LiteralPath $inputObj.full_path

    if ($file.Extension -in $ext_array) {
        ConvertFile($inputObj.full_path)
    }

}

#   Path supplied is directory
else {
    
    #   Write-Host "Directory provided"

    $files = Get-ChildItem -LiteralPath $inputObj.full_path
    foreach ($file in $files) {
        $path_to_file = "$($file.Directory)\$($file)"
        
        if ($file.Extension -in $ext_array) {
            ConvertFile($path_to_file)
        }
        else {
            
            if($del_file -eq 1){
                #rm file
                Write-Host 'Warn: ' $file.name " - not present in the extention array - removing..."
                Remove-Item  -LiteralPath $path_to_file
            }

        }

    }
}

#if directory empty and exists, remove
if($del_parent -eq 1){
    if (((Test-Path -Path "$($inputObj.full_path)\*") -eq $False) -AND (Test-Path -Path "$($inputObj.full_path)") -eq $True) {
        Write-Host "Info: Directory empty, removing folder - $($inputObj.full_path)"
        Remove-Item -LiteralPath $inputObj.full_path
    } 

    else{
        Write-Host "Warn: Parent folder not empty, skipping removal"
    }   
}

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');