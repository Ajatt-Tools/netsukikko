local utils = require('mp.utils')
netsu = utils.join_path(os.getenv("HOME"), ".local/bin/shit/netsukikko.sh")

function remote_subtitle()
     current_file =  mp.get_property("path");
<<<<<<< HEAD
     os.execute(" bash "..netsu.." \""..current_file.."\" \"-mpv\" ");
=======
     os.execute(" bash "..netsu.." \""..current_file.."\" \"-mpv\" && notify-send \"Subs found and downloaded\" || notify-send \"No subs for your anime on Kitsunekko\"");
>>>>>>> cd4b66a... updated
     mp.commandv("rescan_external_files", "reselect")
end;
mp.add_key_binding("Ctrl+a", "auto_load_subs", remote_subtitle)
