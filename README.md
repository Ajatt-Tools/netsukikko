# netsukikko
script and mpv addon for downloading japanese subs from kitsunekko

[![Matrix](https://img.shields.io/badge/Japanese_study_room-join-green.svg)](https://app.element.io/#/room/#djt:g33k.se)

video (clickable):  
[![](https://img.youtube.com/vi/6ezuoT7vHHc/hq1.jpg)](https://www.youtube.com/watch?v=6ezuoT7vHHc "netsukikko")

## Usage:
### As cli tool:
`./netsukikko.sh "[NAME] Of - Episode 24 [2020].mkv"`

or

`./netsukikko.sh "Anime Episode"`

#### Windows:
You need to install curl and busybox. Easiest way is to install it with scoop (https://scoop.sh): 
##### Installing scoop:
```
# Open Powershell from Start Menu and print next two lines:
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
iwr -useb get.scoop.sh | iex
```
##### Installing apps:
```
scoop install busybox 
scoop install curl
```

### As mpv addon:
Copy `netsukikko.lua` into your mpv addon directory. Press `Ctrl+A` when you watch anime episode to download subs automatically.
