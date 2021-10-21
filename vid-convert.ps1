## Author:Brycen Medart
## URL:https://treantlabs.com
## Version: 1.0
## License: MIT License

##--------------
# Argument Variables - Do not change unless use case is understood
##--------------------

#Variables for path, category and full file path arguments

$path = $Args[0]
$cat = $Args[1]
$fpath = $Args[2]

#Array of Movie ext types
$ext_array = @(".avi", ".flv", ".mkv", ".mov", ".mp4", ".wmv",".srt",".en.srt")

##-------------
#Global change variables - Change to configure for your environment.
##--------------------

#Remove converted local file after transfer 0=no 1=yes
$del_file = 1

#Video File Save Folder, alter to save converted movies to new location.
$saveFolder = "/home/brymed/Videos/temp"

#Remote Server Information For SFTP Transfer. Alter these values to match your environment.
$enable_transfer = 1
$rem_ip = "192.168.1.121"
$rem_username = "pi"
$rem_saveFolder = "/media/PIPLEX"



#Loop through files in fpath location and send to convert_file function for processing

$files = Get-ChildItem -File "$fpath"
foreach ($f in $files) {
    #File is movie
    if ($f.Extension -in $ext_array) {
        Write-Host $f
        #convert_file "$i"
    }
    else{
        #delete file
    }
    
}

#If the movie path does not equal the save folder path delete movie folder
if ("$fpath" -ne "$saveFolder") {
    Write-Host "$fpath, $savefolder"
    #rmdir "$m_fpath"
}

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');