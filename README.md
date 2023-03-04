# vid-convert-pws

<h1>Summary</h1>

<p>The purpose of this product was to create a powershell script for converting multiple video file formats to mp4 and h264 codec. I developed these scripts to automatically convert video files and upload them to a raspberryPI server that is running Plex Media Server software. The reason for conversion is that the raspberryPi while powerful, lacks the processing power to transcode movies on the fly. By converting to the h264 format there is no need to transcode the video when watching movies on most modern day smart TV's.
</p>

<hr/>
 
<h2>Prerequisites:</h2>

<p>Set the global variables notated in the convert.ps1 file.</p>

<p>Download ffmpeg from <a href="https://ffmpeg.org/download.html">https://ffmpeg.org/download.html</a>. I would recommend getting one of the compiled versions shown on the above page. Once downloaded move to a permanent location on your system and update the convert.sh file variables to point to this location.</p>

<p>Note: If using SFTP transfer an ssh key needs to be created. A guide on how to accomplish this can be found at <a href="https://winscp.net/eng/docs/guide_public_key">https://winscp.net/eng/docs/guide_public_key</a>. Once created the script needs to be updated to include your ssh key file location and your ssh fingerprint. Lastly alter the variable "enable_transfer" from 0 to 1 to enable SFTP within the script.</p>

download the WinSCP .net Assembly from https://winscp.net/eng/downloads.php#additional

<hr />

<h2>Usage</h2>
<p>
The convert.ps1 script can easily be ran from the powershell window or by another program by entering the below command.
</p>
<p>
Change the below values
</p>
<ul>

<li>File Location - Location of the convert.ps1 file</li>

<li>Label - ie.. shows, movies etc..</li>Label is used in the Sftp transfer file path. For example if label is "Shows" the sftp transfer would save to /remoteip/folder/Shows. If your videos are not categorized this way leave quotes empty ""

<li>Full save path - full save path for video file on your system will be different than mine. This script is setup to take either a folder containing video files or the direct path to a video file.</li>

</ul>

<pre>
<code>
powershell.exe -ExecutionPolicy Bypass -File C:\Users\youruser\vid-convert-pws\convert.ps1 "Shows" "C:\Users\youruser\videofile"
</code>
</pre>

<hr/>
