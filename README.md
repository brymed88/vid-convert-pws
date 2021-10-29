# vid-convert-pws

Intro:

This is a powershell script that will convert multiple video file formats to mp4 and h264 codec. I developed this script to automatically convert video files and upload them to a raspberryPI server that is running Plex Media Server software. The reason for conversion is that the raspberryPi, while powerful lacks the processing power to transcode movies on the fly. By converting to the h264 format there is no need to transcode the video when watching movies on most modern day smart TV's.

----------------------------------------------------------------------------------------------------------------

Prerequisites:

Set the global variables notated in the vid-convert.ps1 file. These variables will tell the script where your saved movies files should be located and whether or not you want to utilize an SFTP transfer after conversion.

Note: If using SFTP transfer an ssh key needs to be created. A decent article on how to accomplish this can be found on WINscp at https://winscp.net/eng/docs/guide_public_key. Once created the script needs to be updated to include your unique string. Lastly alter the variable "enable_transfer" from 0 to 1 to enable SFTP within the script.

-----------------------------------------------------------------------------------------------------------------

POWERSHELL USAGE:

This script can easily be ran from the powershell window by entering the below command.

Change the below values

* Save path - location where video is stored ie "/home/user/Downloads"
* Torrent label - Torrent label ie shows, movies etc..
    Note: Label that is used in the FTP transfer file path. For example if label is "Shows" the ftp transfer would save to /remoteip/folder/Shows. If videos are not categorized this way on your system leave quotes empty ""
* Full save path - full save path for video file ie "/home/user/Downloads/mountain men". If the video is not under a subfolder, this value would be "/home/user/Downloads/mountain men.avi"

powershell.exe -ExecutionPolicy Bypass -File C:\Users\bryce\Dev\projects\vid-convert-pws\vid-convert.ps1 "C:\Users\bryce\Videos\TOR\temp" "Shows" "C:\Users\bryce\Videos\TOR\temp\Legacies.S04E02.720p.HDTV.x264-SYNCOPY\"

----------------------------------------------------------------------------------------------------------------

qBITTORRENT USAGE:

%D - Save Path
%L - Torrent Label
%R - Full Save Path - includes folder torrent is in

Within qBittorrent Under Settings->Downloads-> Run External Program On Torrent Completion, paste the below snippet

Note: In the below example "C:\Users\bryce\Dev\projects\vid-convert-pws\vid-convert.ps1" is the location of this script on my file system. Depending on the git clone location, this will need to be adjusted.

powershell.exe -ExecutionPolicy Bypass -File C:\Users\bryce\Dev\projects\vid-convert-pws\vid-convert.ps1 "C:\Users\bryce\Videos\TOR\temp" "Shows" "C:\Users\bryce\Videos\TOR\temp\Legacies.S04E02.720p.HDTV.x264-SYNCOPY\"

After torrent finishes downloading qBittorrent will kick off the vid-convert.ps1 script and process the video conversion.

----------------------------------------------------------------------------------------------------------------

Summary:

Thank you for checking out my project and feel free to submit comments/improvement ideas!