# GCS to Fantasygrounds
This is an output template, script and extension that allows importing GCS characters from GCS to Fantasygrounds.
Due to the limitations of the Fantasyground lua sandbox, the data must be in place during load.

There are certain anomalies due to other limitations of the format. Doublequotes (``"``) will not display properly if present in item names, and ampersands (``&``) may not either. These can be easily corrected in Fantasygrounds itself. The script populates the 'Protection' sub-tab of the combat tab with nonzero DR values from GCS, don't expect it to give the DR of each item, since GCS doesn't differentiate, the script can't either.

## Simple usage guide
Open GCS and select the ``GCStoFG_template.lua`` as your output template in GCS preferences (``CTRL+,``). Save as .lua, and name the file ``lua-import.lua`` . Place this file in the ``scripts`` directory of the ``GURPS_lua_importer`` extension, replacing the old file. Then launch Fantasy Grounds, making sure that said extension is activated for your campaign. Then enter ``/importcharlua 1`` into chat. If successful, you will recieve a message, and the character will be in the list. Repeat this process for every character.

## Advanced Usage for other coders
_A small app is on the way to make this method quick, easy, and accessible for everyone._

Use ``lua-export.lua`` as the output template, and copy-paste the contents inside the ``return { }`` curlybraces of the ``docharacters()`` function at the end of the ``lua-import.lua`` file in the extension's scripts directory. Make sure to leave a comma after the final ``}`` of each one since it's within a table.
Then use ``/importcharlua`` and the numberof the character in the list to import.