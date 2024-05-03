## Author:Brycen Medart
## URL:https://treantlabs.com
## Version: 2.0
## License: MIT License

$Settings = Get-Content "$($PSScriptRoot)\settings.json" | Out-String | ConvertFrom-Json

# CLEAN PATHNAME / FILENAME FROM CHARACTERS THAT CAN CAUSE ISSUES
function cleanName($path) {
    $file = Get-Item -LiteralPath "$($path)"

    $baseDir = Split-Path -Parent $file

    $cleanedName = $file.Name -replace '[^0-9a-zA-Z-.]+', ''

    if ($file.Name -notlike $cleanedName) {
        Rename-Item -LiteralPath $file.FullName -NewName $cleanedName
        
        return  Join-Path -Path $baseDir -ChildPath $cleanedName
    }

    return $file.FullName
}

#REMOVE FILE
function deleteFile($path) {
    Remove-Item  -LiteralPath $path
}

#DISPLAY MESSAGE WITH LINE ABOVE
function displayMessage($message) {
    Write-Host @"

$($message) 
"@
    return
}

#CONVERT VIDEO FILE
function ConvertFile($path) {
    $file = Get-Item -LiteralPath $path
   
    if ($file.Extension -ne ".srt" -And $file.Extension -ne ".en.srt") {

        # Assign Video/Audio codecs to variables
        $ffprobe = Get-Command -CommandType Application -Name "$($Settings.ffmpeg_location)\ffprobe.exe" -ErrorAction SilentlyContinue
        $ffprobe = $ffprobe.Source
        $ffmpeg = Get-Command -CommandType Application -Name "$($Settings.ffmpeg_location)\ffmpeg.exe" -ErrorAction SilentlyContinue
        $ffmpeg = $ffmpeg.Source

        # Convert to reduce file size no matter the extension
        displayMessage "Info: Converting - $($file.Name)"

        $tmp_file = "$($file.DirectoryName)\tmp.$($file.BaseName).mp4"

        # Convert file using ffmpeg and argument variables
        # Format: video codec: H264

        & $ffmpeg -v quiet -stats -i $file.FullName -c:v libx264 -preset $($Settings.preset) -crf $($Settings.crf_quality) -c:a $($Settings.desired_acodec) $tmp_file
 
        displayMessage "Info: File Conversion complete!"
        
        if ($Settings.delete_file -eq $true) {
            # Delete original file after conversion
            deleteFile $file.FullName
        }
        else {
            # Rename original file after conversion
            Rename-item -LiteralPath $file.FullName -NewName "old.$($file.Name)"
        }
   
        # Rename converted file to the original file name that is now deleted/renamed
        Rename-Item -LiteralPath $tmp_file -NewName "$($file.BaseName).mp4"

        return "$($file.DirectoryName)\$($file.BaseName).mp4"
    }
    else {
        # Rename srt file with .en extension
        if ($file.Name -notmatch "en.srt") {
            Rename-Item -LiteralPath $file -NewName "$($file.BaseName).en.srt"
            return "$($file.DirectoryName)\$($file.BaseName).en.srt"
        }

        return $file.FullName
        
    }

}

#TRANSFER FILE TO REMOTE SERVER
function transferFile($path, $category) {

    $file = Get-Item -LiteralPath $path

    try {
        # Load WinSCP .NET assembly
        Add-Type -Path "$($Settings.winscp_location)\WinSCPnet.dll"
        displayMessage "Info: Transferring $($file.Name) to remote"
    
        # Set up session options
        $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
            Protocol              = [WinSCP.Protocol]::Sftp
            HostName              = $Settings.remote_address
            UserName              = $Settings.remote_user
            Password              = $Settings.remote_password
            SshHostKeyFingerprint = $Settings.ssh_fingerprint
        }
 
        $session = New-Object WinSCP.Session
 
        try {
            # Connect
            $session.Open($sessionOptions)
 
            # Upload files
            $transferOptions = New-Object WinSCP.TransferOptions
            $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
 
            $transferResult =
            $session.PutFiles("$($file.FullName)", "$($Settings.remote_folder)/$($category)/", $False, $transferOptions)
 
            # Throw on any error
            $transferResult.Check()
 
            # Print results
            foreach ($transfer in $transferResult.Transfers) {
                displayMessage "Info: Upload succeeded"
                
                return $fileToTransfer
            }
        }
        finally {
            # Disconnect, clean up
            $session.Dispose()
        }
    }
    catch {
        displayMessage "Error: $($_.Exception.Message)"
        exit 1
    }
}