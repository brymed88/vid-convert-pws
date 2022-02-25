# vid-convert-pws

<h1>Summary</h1>

<p>Included is two powershell scripts. One that will convert multiple video file formats to mp4 and h264 codec. The second that will convert / compress a current video file. I developed these scripts to automatically convert video files and upload them to a raspberryPI server that is running Plex Media Server software. The reason for conversion is that the raspberryPi, while powerful lacks the processing power to transcode movies on the fly. By converting to the h264 format there is no need to transcode the video when watching movies on most modern day smart TV's.
</p>

<hr/>

<h2>Prerequisites:</h2>



<p>Set the global variables notated in the convert.ps1 file. </p>

<p>Note: If using SFTP transfer an ssh key needs to be created. A decent article on how to accomplish this can be found on WINscp at <a href="https://winscp.net/eng/docs/guide_public_key">https://winscp.net/eng/docs/guide_public_key</a>. Once created the script needs to be updated to include your unique string. Lastly alter the variable "enable_transfer" from 0 to 1 to enable SFTP within the script.</p>

download the WinSCP .net Assembly from https://winscp.net/eng/downloads.php#additional

navigate to winscp.exe within the extracted folder and run

<hr />

POWERSHELL USAGE:

The convert.ps1 script can easily be ran from the powershell window by entering the below command.

Change the below values

* Save path - location where video is stored ie "/home/user/Downloads"
* Torrent label - Torrent label ie shows, movies etc..
    Note: Label that is used in the FTP transfer file path. For example if label is "Shows" the ftp transfer would save to /remoteip/folder/Shows. If videos are not categorized this way on your system leave quotes empty ""
* Full save path - full save path for video file ie "/home/user/Downloads/mountain men". If the video is not under a subfolder, this value would be "/home/user/Downloads/mountain men.avi"

powershell.exe -ExecutionPolicy Bypass -File C:\Users\bryce\Dev\projects\vid-convert-pws\convert.ps1 "C:\Users\bryce\Videos\TOR\temp" "Shows" "C:\Users\bryce\Videos\TOR\temp\Legacies.S04E02.720p.HDTV.x264-SYNCOPY\"

-----------------------------------------------------

The compress.ps1 script can be ran from a powershell window by entering the below command.

powershell.exe -ExecutionPolicy Bypass -File C:\Users\bryce\Dev\projects\vid-convert-pws\compress.ps1 "File location of original file" "Where to save compressed file"

----------------------------------------------------------------------------------------------------------------

qBITTORRENT USAGE:

%D - Save Path
%L - Torrent Label
%R - Full Save Path - includes folder torrent is in

Within qBittorrent Under Settings->Downloads-> Run External Program On Torrent Completion, paste the below snippet

Note: In the below example "C:\Users\bryce\Dev\projects\vid-convert-pws\vid-convert.ps1" is the location of this script on my file system. Depending on the git clone location, this will need to be adjusted.

powershell.exe -ExecutionPolicy Bypass -File C:\Users\bryce\Dev\projects\vid-convert-pws\convert.ps1 "C:\Users\bryce\Videos\TOR\temp" "Shows" "C:\Users\bryce\Videos\TOR\temp\Legacies.S04E02.720p.HDTV.x264-SYNCOPY\"

After torrent finishes downloading qBittorrent will kick off the vid-convert.ps1 script and process the video conversion.

----------------------------------------------------------------------------------------------------------------

Summary:

Thank you for checking out my project and feel free to submit comments/improvement ideas!