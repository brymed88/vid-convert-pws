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
                $fileName = cleanName $fileName
            }

            findFiles(Join-Path -Path $path -ChildPath $fileName)
        }
        else {
            if ($file.Extension -in $Settings.extension_array) {
                if ($Settings.clean_FileName -eq $true) {
                    $fileName = cleanName $fileName
                }

                $convert = ConvertFile($fileName.FullName)

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


    
 
    
findFiles($inputObj.full_path)


#if directory empty and exists, remove
if ($Settings.delete_parentFolder -eq $true) {

    if (((Test-Path -Path "$($inputObj.full_path)\*") -eq $False) -AND (Test-Path -Path "$($inputObj.full_path)") -eq $True) {
        displayMessage "Info: Removing parent folder - $($inputObj.full_path)"
        deleteFile $inputObj.full_path
    } 
    else {
        displayMessage "Warn: Parent folder not empty, skipping removal..."
    }   

}

dispayMessage -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');