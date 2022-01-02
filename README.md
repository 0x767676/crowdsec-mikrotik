# crowdsec-mikrotik
Propagating CrowdSec's decisions to firewalls


# Installing the blocklists on RouterOS
0. Host the `.rsc` generated by the script somewhere your MikroTik can fetch it
1. Set up the script:
```
/system script 
add name="dl-cs-blocklist" source={/tool fetch url="<YOUR-URL>/list.rsc" mode=https}
add name="imp-cs-blocklist" source {/ip firewall address-list remove [find where list="cs-block"]; /import file-name=cs-block.rsc}
```
2. Schedule the script to run at an interval:
```
/system scheduler 
add interval=5m name="fetch-cs-blocklist" start-date=Jan/01/2022 start-time=01:01:01 on-event=dl-cs-blocklist
add interval=5m name="import-cs-blocklist" start-date=Jan/01/2022 start-time=02:02:02 on-event=imp-cs-blocklist
```

# Installing the blocklists on other Firewalls
Use the `.txt` file generated.
* [FortiOS (6.2.0+)](https://docs.fortinet.com/document/fortigate/6.2.0/new-features/625349/external-block-list-threat-feed-policy): Security Fabric > Fabric Connectors > Threat Feeds > IP Address
* [PfSense (PfBlockerNG)](https://protectli.com/kb/how-to-setup-pfblockerng/)
* Other: you can probably import IP lists somehow :) 
