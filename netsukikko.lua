local utils = require('mp.utils')
function remote_subtitle()
     current_file =  mp.get_property("path");
     os.execute(" curl https://raw.githubusercontent.com/Ajatt-Tools/netsukikko/main/netsukikko.sh | bash -s \""..current_file.."\" \"-mpv\" && notify-send \"Subs found and downloaded\" || notify-send \"No subs for your anime on Kitsunekko\"");
     mp.commandv("rescan_external_files", "reselect")
end;
mp.add_key_binding("Ctrl+a", "auto_load_subs", remote_subtitle)
