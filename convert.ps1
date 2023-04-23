## Author:Brycen Medart
## URL:https://treantlabs.com
## Version: 2.0
## License: MIT License

# Argument Variables - Do not change unless use case is understood
# Variables for path, category and full file path arguments

$inputObj = (
    @{
        category  = $Args[0]
        full_path = $Args[1]
    }
)

# Global change variables - Change to configure for your environment.

# Filetype array
$ext_array = @(".avi", ".flv", ".mkv", ".mov", ".mp4", ".m4v", ".wmv", ".srt", ".en.srt")

# FFMPEG variables
$crf_quality = 24
$preset = "fast"
$desired_acodec = "aac"

# This setting will remove non MP4 files after processing and remove non video files in folder | 0=no 1=yes
$delete_files = 0

# Remove parent directory upon conversion completion | 0=no 1=yes
$delete_parent_folder = 0

# Enable SFTP Transfer | 0=no 1=yes
$sftp_transfer = 1

# FFMPEG and WINSCP folders
$ffmpeg_location = "D:\tor\executables\ffmpeg\bin"
$winscp_location = "D:\tor\executables\WinSCP-5.21.2-Automation"

# Remote Server Information For SFTP Transfer. Alter these values to match your environment.
$ssh_fingerprint = ""
$remote_address = ""
$remote_user = ""
$remote_password = ""
$remote_folder = ""

function transfer_file($file) {

    try {
        # Load WinSCP .NET assembly
        Add-Type -Path "$($winscp_location)\WinSCPnet.dll"
        Write-Host "Info: Transferring $($file) to remote server"

        # Set up session options
        $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
            Protocol              = [WinSCP.Protocol]::Sftp
            HostName              = $remote_address
            UserName              = $remote_user
            Password              = $remote_password
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
            foreach ($transfer in $transferResult.Transfers) {
                Write-Host "Info: Upload succeeded"

                if ($delete_files -eq 1) {
                    Write-Host "Warn: Removing local file after transfer"
                    Remove-Item -LiteralPath $file
                }
            }
        }
        finally {
            # Disconnect, clean up
            $session.Dispose()
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)"
        exit 1
    }
}

function ConvertFile($path) {

    $file = Get-Item -LiteralPath $path
   
    if ($file.Extension -ne ".srt" -And $file.Extension -ne ".en.srt") {

        # Assign Video/Audio codecs to variables
        $ffprobe = Get-Command -CommandType Application -Name "$($ffmpeg_location)\ffprobe.exe" -ErrorAction SilentlyContinue
        $ffprobe = $ffprobe.Source
        $ffmpeg = Get-Command -CommandType Application -Name "$($ffmpeg_location)\ffmpeg.exe" -ErrorAction SilentlyContinue
        $ffmpeg = $ffmpeg.Source

        # Convert to reduce file size no matter the extension
        Write-Host " "
        Write-Host "Info: Beginning conversion of - $($file.FullName)"

        $tmp_file = "$($file.DirectoryName)\tmp_$($file.BaseName).mp4"

        # Convert file using ffmpeg and argument variables
        # Format: video codec: H264

        & $ffmpeg -v quiet -stats -i $file.FullName -c:v libx264 -preset $($preset) -crf $($crf_quality) -c:a $($desired_acodec) $tmp_file
 
        Write-Host "Info: File Conversion complete!"
        
        if ($delete_files -eq 1) {
            # Delete original file after conversion
            Remove-Item  -LiteralPath $file.FullName
        }
        else {
            # Rename original file after conversion
            Rename-item -LiteralPath $file -NewName "old.$($file.basename)$($file.Extension)"
        }
    
        # Rename converted file to the original file name that is now deleted/renamed
        Rename-Item -LiteralPath $tmp_file -NewName "$($file.BaseName).mp4"

        # Transfer if enabled
        if ($sftp_transfer -eq 1) {
            transfer_file("$($file.DirectoryName)\$($file.BaseName).mp4")
        }
    }
    else {
        # Rename srt file with .en extension
        Rename-Item -LiteralPath $file -NewName "$($file.BaseName).en.srt"
                
        if ($sftp_transfer -eq 1) {
            Write-Host " "
            transfer_file("$($file.DirectoryName)\$($file.BaseName).en.srt")
        }
    }

}

Write-Host @"
Author: Brycen Medart 
URL: https://treantlabs.com
Version: 2.0
License: MIT License
-----------------------------

"@

# Identify files before sending to ConvertFile function for video conversion

# If path supplied is file
if ((Test-Path -LiteralPath $inputObj.full_path -PathType leaf) -eq $true) {
    
    Write-Host "File Provided: $($inputObj.FullName)"
    
    $file = Get-Item -LiteralPath $inputObj.full_path

    if ($file.Extension -in $ext_array) {
        ConvertFile($inputObj.full_path)
    }

}

# Path supplied is directory
else {
    
    Write-Host "Info: Directory Provided -" $inputObj.full_path

    $files = Get-ChildItem -LiteralPath $inputObj.full_path
    
    foreach ($file in $files) {

        #if sub-directory transverse.
        if ((Test-Path -Path $file.FullName -PathType Container) -eq $true) {
            Write-Host "Info: Found sub directory -" $file.FullName

            $subfile = Get-ChildItem -LiteralPath $file.FullName

            foreach ($sub in $subfile) {

                if ($sub.Extension -in $ext_array) {
                    ConvertFile($sub.FullName)
                }
                else {
                    if ($delete_files -eq 1) {
                        Write-Host 'Warn:' $sub.name "- not present in the extention array - removing..."
                        Remove-Item  -LiteralPath $sub.FullName
                    }
                }

            }
        }
        else {

            if ($file.Extension -in $ext_array) {
                ConvertFile($file.FullName)
            }
            else {
                if ($delete_files -eq 1) {
                    Write-Host 'Warn:' $file.name "- not present in the extention array - removing..."
                    Remove-Item  -LiteralPath $file.FullName
                }

            }

        }
    }
}

#if directory empty and exists, remove
if ($delete_parent_folder -eq 1) {

    if (((Test-Path -Path "$($inputObj.full_path)\*") -eq $False) -AND (Test-Path -Path "$($inputObj.full_path)") -eq $True) {
        Write-Host "Info: Directory empty, removing folder - $($inputObj.full_path)"
        Remove-Item -LiteralPath $inputObj.full_path
    } 

    else {
        Write-Host "Warn: Parent folder not empty, skipping removal"
    }   

}

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');