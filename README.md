# dot1x-port-config-script
A Perl script that takes output from "show int status" and generates a 802.1X switch port configuration for each relevant port.

This script was created for situation where an enterprise's access layer devices are segmented across many different VLANs - e.g. a printer vlan, vtc vlan, etc. When going to a 802.1X-enabled network, some companies were in need to set the critical authorization vlan to the previously statically assigned vlan. This was a pain with manually doing so, and would take a lot of time when ports were not easily configured in large ranges. 

To help speed up the process, I created a script where people could grab output from "show interface status" and plug it into this Perl script. It will ignore blank lines, header lines, and trunk ports. It will then take each listed port and generate a per-port configuration that can be pasted into the switch. If you need a specific port to be excluded, just delete that row from the output and run the script. 

Many ask why I didn't just use CLI-scraping and connect to the switch to pull the output and possibly apply it, as well. The simple answer is because the specific case I created for did not want that, so I didn't go the extra mile. Feel free to add it in if you'd like. 

Note: please update the switch port configuration template in the script to reflect it to your own.

-R
