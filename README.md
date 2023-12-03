# NetBase
NetBase or Network Baseline is a Powershell script to make a baseline of network connections.
## How it works?
Netbase will create a baseline of the processes establishing a TCP connection with the remote IP address and remote port.
The format of the csv file is :

"Remote IP","Remote Port","Path","timestamp"
## How to use?
`.\NetBase.ps1 -b` to create a baseline or update the current one.

`.\NetBase.ps1 -l C:\path\` to choose the location of the csv files.

`.\NetBase.ps1 -t` to add a timestamp.

# To do and ideas
Add an option to append suspect.csv to baseline.csv. For now you can copy manually.

Add the API of AbuseIPDB and block malicious IPs in the firewall
