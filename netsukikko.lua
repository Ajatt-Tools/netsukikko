local utils = require('mp.utils')
netsu = utils.join_path(os.getenv("HOME"), ".local/bin/shit/netsukikko.sh")

function remote_subtitle()
     current_file =  mp.get_property("path");
     os.execute(" bash "..netsu.." \""..current_file.."\" ");
     mp.commandv("rescan_external_files", "reselect")
end;
mp.add_key_binding("b", "auto_load_subs", remote_subtitle)
