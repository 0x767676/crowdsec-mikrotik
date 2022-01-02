#!/bin/bash
# WARNING:
# This script is insanely dirty, but works.
### CONFIG
# Disable this if you do not have a MikroTik firewall and thus, couldn't care less about generating the .rsc
_I_HAVE_A_MIKROTIK="YES"
# Path to blocklist (raw ips, for PfSense, FortiGate, etc)
_BLOCKLIST="/opt/crowdsec/cs-blocklist.txt"
# Path to MikroTik-compatible rsc
_RSCFILE="/opt/crowdsec/cs-block.rsc"
### END CONFIG

### OTHER VARS - shouldn't have to touch anything at all below here
_DATE=$(date '+%Y%m%d-%H:%M:%S')
_ACTION="$1"
_IP="$2"
_DURATION="$3" # I don't care about this, CS handles it
_REASON="$4" # same
_JSONOBJECT="$5" # same here
### END OTHER VARS

### FUNCTIONS
# Block IP: Add a CrowdSec BAN decision to the list. 
_blockIP () {
echo "Blocking $_IP"
echo $_IP >> $_BLOCKLIST
}

# Unblock IP: Remove a CrowdSec UNBAN/DELETE decision from the list.
_unblockIP () {
echo "Removing $_IP"
sed -i "/$_IP/d" $_BLOCKLIST
}

# Generate MikroTik RSC
# TODO: Use the Mikrotik API instead, but eh, this works fine if we have multiple devices downloading the list
_genMikroTik () {
 _TMPRSC="/tmp/cs-block.rsc"
 _RAW=$_BLOCKLIST
 echo "# $DATE" >> $_TMPRSC
 echo "/ip firewall address-list" >> $_TMPRSC
 while IFS= read -r line
  do
   echo "add list=cs-block address=$line" >> $_TMPRSC
  done < "$_RAW"
 mv $_TMPRSC $_RSCFILE
}

# Close your eyes and brace for an incoming depression when seeing this ugly (but alas, working!) code.
# should add some else cases, but eh, 
if [[ $_ACTION == "add" ]]; then
 _blockIP
  if [[ $_I_HAVE_A_MIKROTIK == "YES" ]]; then
   _genMikroTik
  fi
 exit 0

elif [[ $_ACTION == "del" ]]; then
 _unblockIP
 if [[ $_I_HAVE_A_MIKROTIK == "YES" ]]; then
  _genMikroTik
 fi
 exit 0
 
else
 echo "ohno something went terribly wrong"
 exit 127
fi
