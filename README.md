# netsukikko
script and mpv addon for downloading japanese subs from kitsunekko


video (clickable):  
[![](https://img.youtube.com/vi/6ezuoT7vHHc/hq1.jpg)](https://www.youtube.com/watch?v=6ezuoT7vHHc "netsukikko")

## Usage:
### As cli tool:
`./netsukikko.sh "[NAME] Of - Episode 24 [2020].mkv"`

or

`./netsukikko.sh "Anime Episode"`

#### Windows:
You need to install curl, 7-zip and msys2. Easiest way is to install it with scoop (https://scoop.sh): 
##### Installing scoop:
```
# Open Powershell from Start Menu and print next two lines:
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
iwr -useb get.scoop.sh | iex
```
##### Installing apps:
```
scoop install msys2 
scoop install curl
scoop install 7zip
```
##### Download `netsukikko.sh`
And place in any folder. **If you want to use mpv addon, edit path to `netsukikko.sh` in `netsukikko-win.lua`**

### As mpv addon:
Copy `netsukikko.lua` or `netsukikko-win.lua` into your mpv addon directory. Press `Ctrl+A` when you watch anime episode to download subs automatically.
