Why this is important:
Most of our on prem clients intend to keep their servers. Our company has more room to expand its clients in using our Arcus platform. There is generally alot of confustion on how to connect to our cloud servers and what the difference between legacy and Arcus servers. This will not be guide to setting up SFT but rather how to use it along with its caveats explained.

Notes:
-We have information of how to set up SFT here:
https://confluence.globalscape.com/display/PS/Import+EFT+to+Arcus
-Here is our RDG portal for our clients:
https://rdg.cloud.globalscape.com/RDWeb/Pages/en-US/login.aspx
-Here is my simple script with an evironment already set:


What we will go over:
-Setting the environment
-Looking for a server
-What a bastion is
-How to connect to Arcus from your vpn at home
-Where to put the script
-What commands are available in the script
-How to navigate the script


Setting the environment

In order to connect to the servers you normally will have to enter this command:
$env:HTTPS_PROXY = 'http://10.0.0.14:8080'

This will set the proxy so the traffic can actually be routed to the servers. This is automatically declared when you use my script so you will never manually have to do this.

Looking for a server

You are able to use the following command to list the servers:

sft list-servers

This will display a long list of servers. After you get used to it, you normally will be able to find what you are looking for pretty quickly. If you know what the host name of the server is, or you have an idea of what string of letters will return the server you are looking for, you can pipe the output of sft list-servers to find string. Like this:
sft list-servers | findstr -i <string>

The main problem with this is that most of the legacy servers have odd hostnames that have nothing to do with the company. this is where our Excel spread sheet might come in handy. This contains most of the legacy servers.
R:\jbranan\Cloud Servers.xlsx

What is a bastion?

A bastion allows our company to keep tract of the tasks completed on our clients servers. This provides some legal protection should something go wrong, and also provide accountablity. Logging into a server via a bastion is not optional for Arcus and it is not an option for legacy. When you do a SFT list servers, these servers normally have "bast" in the name.

Connection to Arcus servers via a VPN

When at home you will need to use the following format:
sft rdp --via sft --via (bastion) (server)

Note: This should only be used when you are WFH and need to log into an Arcus cloud server.

What location should I put the script?

You will want to put the WHOLE folder in your documents folder for powershell to reconize it. The path should be like this:
%userprofile%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
C:\Users\jbranan\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

If you don't know where this is just hit WindowsKey + R, type %userprofile% and hit enter. This will show you where your home path is.

What commands are avaiable in the script?

list- Displays a list of the servers, legacy, MIX or Arcus.
search- Allows you to specify a string to search the list of servers. You may pass a string parameter. ex. 'search supp02'
rdgw- Connects to the RDGW server. This is normally used for password resets for clients.
legacy- Cloud servers that are not used in conjuction with a bastion. We are winding down support for them.
arcus- Our current cloud offering. Requires a bastion to login.

How to Navigate the script

You generally want to start with the search command and search for the name or a short string.

For expample, search com or one so that the command can return the host name. A search for "com" in this case will not return a server but a search for "one" will.:
Company one's cloud server hostname: cone0003
Company one's cloud server bastion hostname: conebast0001
 
In order to cancel a command hit ctrl + C. This will allow you to back out of a command and use a different one. For instance, say you connected the previous day to a cloud server and have hostname already. You can proceed with the legacy command and skip the list and search commands. 
