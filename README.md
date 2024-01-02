# Boxes v1.0
Rainmeter skin designed as a series of little windows. It's not designed to be super user friendly, there are no built in config pages. You will have to edit the .ini/.inc files to get everything working the way you want it. I did design the skins so that the majority of the code is hidden in .inc files that don't need altered and the skins themselves have anything that would need to be edited.

Demo
xxxxxx

**Features**
- Skins
  - App Box
    - Launches apps, folders, skins, shortcut files, etc
    - Sweet rainbow effect
    - Python script included to automate set up. There is a CSV file where you can input rows with the app/shortcut name, link, icon, then you can run the script and it will read the CSV file, create a copy of the template App Box, then plug in the values. Makes it MUCH quicker to set up a ton of boxes, otherwise you'll have to manually copy the App Box folder, rename it, and edit the .ini file to get it pointed to your apps.
  - Idle Box
    - A special launcher box that immediatly goes into idle mode
    - Idle box that is displayed when in idle mode
      - Idle mode cuts down on CPU usage. It closes all boxes, minimizes windows, and centers this one big box that doesn't do anything except exit idle mode when you click it. This exists because when a ton of photo and streaming boxes are loaded this uses like 5-15% CPU on my 5900x. Looks awesome but I don't want it running all the time...
    - See note below under Other Features
  - Monitor Box
    - Customized versions of some very popular hardware monitoring skins gutting to almost beyond recognition
    - CPU, GPU, Network, RAM, Disks
  - Photo Box
    - Point it to a folder with pictures and it will show them as a slideshow with a fade effect
  - Stream Box
    - Uses powershell scripts to scrape data for streaming services. The scripts launch when the skin is loaded and then once every 24 hours or so. They clear all existing images then download the newest ones, so if one of your boxes stops working it will just be a blank. This is my daily driver so I will probably load updates if the APIs change. You will have to register for access to the sites APIs and then input your keys to get them to work. Kind of a hassle but it's pretty cool once you have them set up. See instructions in the API .inc files in the @Resources\Stream Box folder.
    - Disney, Hulu, MAX, Netflix, Peacock, Prime
      - Displays new release TV and Movies from the movie database (https://www.themoviedb.org/)
    - Spotify
      - Displays new music releases directly from Spotify
    - Tumblr
      - Displays your dashboard. Not the greatest implementation, this was the last thing I worked on and I was just done by then, maybe I'll fix it one day. Only works due to another cool project on github: https://github.com/Joshkunz/tumblr2rss. Go to https://tumblr2rss.obstack.net/ to turn your dashboard into a RSS feed then input the URL into the .inc file
    - Jellyfin/NyNoise
      - Can point to local libraries to show media  
  - Time Box
    - Customized version of same very popular hardware monitoring clock skin also gutting to almost beyond recognition
  - Weather Box
    - Customized version of same very popular hardware monitoring weather skin also gutting to almost beyond recognition
    - Customized weather icons
  - Windows Box
    - Sits over the windows button to hijack start button clicks,  brings all of your loaded skins to the top. Finnicky...
- Other Features
  - In the @Resources folder there is a "AHK Scripts" folder that contains 3 scripts that I have set up to launch at startup. They require AutoHotKey (https://www.autohotkey.com/)
    - ChangeRainmeterLayoutDetectResolution
      - This script detects resolution changes and automatically loads the appropriate layout.
      - Two layouts are included along with helper wallpapers to get a clean evenly-spaced look. There is a layout for 1080p and one for 1440p. You can tweak the script if you use other resolutions, should be pretty easy to figure out.
    - RemapWindowsKey
      - Hijacks the Windows key and instead of popping up the windows menu it brings all of your loaded skins to the top. Hitting it again moves them back to the desktop.
    - ShowIdleBoxWhenIdle
      - Detects when there has been no activity for 10 minutes and puts the skins into idle mode as described above
