## Author:Brycen Medart
## URL:https://treantlabs.com
## Version: 2.0
## License: MIT License

. $PSScriptRoot\utils.ps1
$Settings = Get-Content "$($PSScriptRoot)\settings.json" | Out-String | ConvertFrom-Json

# INCOMING VARIABLES FOR FULL PATH AND CATEGORY
$inputObj = (
    @{
        category  = $Args[0] # CORRESPONDS TO SAVE FOLDER ON SMTP SERVER
        full_path = $Args[1] # PATH OF LOCAL FILE
    }
)



Write-Host @"

Author: Brycen Medart 
URL: https://treantlabs.com
Version: 2.0
License: MIT License
-----------------------------

"@

function findFiles ($path) {
    $files = Get-ChildItem -LiteralPath $path
    foreach ($file in $files) {
        $fileName = $file

        #IF DIRECTORY LOOP UNTIL ALL FILES FOUND
        if ((Test-Path -LiteralPath "$($file.FullName)" -PathType Container) -eq $true) {
            if ($Settings.clean_PathName -eq $true) {
                $fileName = cleanName $fileName.FullName
            }

            findFiles($fileName)
        }
        else {
            if ($file.Extension -in $Settings.extension_array) {
                if ($Settings.clean_FileName -eq $true) {
                    $fileName = cleanName $fileName.FullName
                }

                $convert = ConvertFile($fileName)

                if ($Settings.sftp_transfer -eq $true) {
                    
                    transferFile $convert $inputObj.category
                    
                    if ($Session.delete_transferredFile -eq $true) {
                        deleteFile($convert)
                    }
                }
            }  
            else {
                if ($Settings.delete_nonMovieFiles -eq $true) {

                    displayMessage "Warn: Not in ext array, removing - $($file)"
                    deleteFile $file.FullName
                }
            }
        }
    }
}


$initialPath = "$($inputObj.full_path)".Replace('\/$', '')  

if ($Settings.clean_PathName -eq $true -And (Test-Path -LiteralPath $initialPath -PathType Container) -eq $true) {
    $initialPath = cleanName $initialPath
}
    
findFiles($initialPath)

#if directory empty and exists, remove
if ($Settings.delete_parentFolder -eq $true) {

    if (((Test-Path -Path "$($initialPath)\*") -eq $False) -AND (Test-Path -Path $initialPath) -eq $True) {
        displayMessage "Info: Removing parent folder - $($initialPath)"
        deleteFile $initialPath
    } 
    else {
        displayMessage "Warn: Parent folder not empty, skipping removal..."
    }   

}
displayMessage "Conversion process complete!"

displayMessage "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');