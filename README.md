# vid-convert-pws

<h1>Summary</h1>

<p>The purpose of this product was to create a powershell script for converting multiple video file formats to mp4 and h264 codec. I developed these scripts to automatically convert video files and upload them to a raspberryPI server that is running Plex Media Server software. The reason for conversion is that the raspberryPi while powerful, lacks the processing power to transcode movies on the fly. By converting to the h264 format there is no need to transcode the video when watching movies on most modern day smart TV's.
</p>

<hr/>

<h2>Prerequisites:</h2>



<p>Set the global variables notated in the convert.ps1 file. </p>

<p>Note: If using SFTP transfer an ssh key needs to be created. A guide on how to accomplish this can be found at <a href="https://winscp.net/eng/docs/guide_public_key">https://winscp.net/eng/docs/guide_public_key</a>. Once created the script needs to be updated to include your ssh key file location and your ssh fingerprint. Lastly alter the variable "enable_transfer" from 0 to 1 to enable SFTP within the script.</p>

download the WinSCP .net Assembly from https://winscp.net/eng/downloads.php#additional

<hr />

<h2>POWERSHELL USAGE</h2>
<p>
The convert.ps1 script can easily be ran from the powershell window by entering the below command.
</p>
<p>
Change the below values
</p>
<ul>
<li>Label - ie.. shows, movies etc..</li>
    Note: Label is used in the FTP transfer file path. For example if label is "Shows" the ftp transfer would save to /remoteip/folder/Shows. If videos are not categorized this way on your system leave quotes empty ""

<li>Full save path - full save path for video file ie "/home/user/Downloads/mountain_men". If the video is not under a subfolder, this value would be "/home/user/Downloads/mountain_men.avi"</li>
</ul>
<pre>
<code>
powershell.exe -ExecutionPolicy Bypass -File C:\Users\bryce\Dev\projects\vid-convert-pws\convert.ps1 "Shows" "C:\Users\bryce\Videos\tmp\mountain_men"
</code>
</pre>
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