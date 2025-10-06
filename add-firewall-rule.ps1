# Add Windows Firewall Rule for Socket.IO Server
# This allows your phone to connect to the server on port 3001

# Run this in PowerShell AS ADMINISTRATOR:
netsh advfirewall firewall add rule name="Node.js Socket.IO Server Port 3001" dir=in action=allow protocol=TCP localport=3001

# To verify the rule was added:
# netsh advfirewall firewall show rule name="Node.js Socket.IO Server Port 3001"

# To remove the rule later:
# netsh advfirewall firewall delete rule name="Node.js Socket.IO Server Port 3001"
