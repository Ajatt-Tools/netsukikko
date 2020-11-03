-- Don't forget to replace netsukikko.sh in os.execute line with real path
-- You can download netsukikko.sh in scripts folder for example
-- Pls remember, win version is Work-In-Progress!

local utils = require('mp.utils')
function remote_subtitle()
     current_file =  mp.get_property("path");
     os.execute(" mingw64 netsukikko.sh \""..current_file.."\" \"-mpv\"");
     mp.commandv("rescan_external_files", "reselect")
end;
mp.add_key_binding("Ctrl+a", "auto_load_subs", remote_subtitle)
