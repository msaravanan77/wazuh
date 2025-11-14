# Wazuh on WSL2 - Quick Start Guide

## Access Wazuh Dashboard from Windows Browser

This guide is specifically for running Wazuh in WSL2 and accessing it from your Windows host browser.

**Your Setup**:
- WSL2 Ubuntu 22.04 running on Windows
- WSL IP: `172.28.10.162` (yours may be different)
- Goal: Access dashboard from Windows browser at `https://172.28.10.162:443`

---

## Quick Reference

**From Windows Browser**:
```
Dashboard: https://172.28.10.162:443
API:       https://172.28.10.162:55000
Username:  admin
Password:  SecretPassword
```

**Find Your WSL IP** (run in WSL terminal):
```bash
ip addr show eth0 | grep "inet " | awk '{print $2}' | cut -d/ -f1
```

---

## Step-by-Step Setup

### Step 1: Install Docker in WSL2

```bash
# Update packages
sudo apt update
sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group (avoid sudo)
sudo usermod -aG docker $USER

# Start Docker service
sudo service docker start

# Verify Docker is running
docker --version
sudo service docker status
```

**Important**: After adding user to docker group, close and reopen WSL terminal.

### Step 2: Install Docker Compose

```bash
# Download Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
```

### Step 3: Clone Wazuh Docker Repository

```bash
# Navigate to home directory
cd ~

# Clone official Wazuh Docker repo
git clone https://github.com/wazuh/wazuh-docker.git -b v4.7.2

# Enter directory
cd wazuh-docker/single-node
```

### Step 4: Generate SSL Certificates

**CRITICAL**: Wazuh requires SSL certificates to work.

```bash
# Generate certificates using official tool
docker-compose -f generate-indexer-certs.yml run --rm generator

# Verify certificates were created
ls -lh config/wazuh_indexer_ssl_certs/
```

You should see files like:
- `root-ca.pem`
- `wazuh.manager.pem`
- `wazuh.indexer.pem`
- `wazuh.dashboard.pem`

### Step 5: Update Port Bindings for WSL2 Access

**Option A: Quick Edit** (if using official repo)

```bash
# Edit docker-compose.yml
nano docker-compose.yml

# Find the "ports:" sections and change them:

# BEFORE:
ports:
  - "443:5601"

# AFTER:
ports:
  - "0.0.0.0:443:5601"

# Do this for all services:
# - wazuh.indexer: "0.0.0.0:9200:9200"
# - wazuh.manager: "0.0.0.0:1514:1514", "0.0.0.0:55000:55000", etc.
# - wazuh.dashboard: "0.0.0.0:443:5601"

# Save: Ctrl+O, Enter, Ctrl+X
```

**Option B: Use My Pre-configured File** (recommended)

```bash
# If you cloned my wazuh repo with the updated docker-compose
cd /home/user/wazuh
docker-compose -f docker-compose-complete-ecosystem.yml up -d
```

### Step 6: Start Wazuh Stack

```bash
# Make sure Docker is running
sudo service docker start

# Start all Wazuh services
docker-compose up -d

# This will download images (~5GB) and start containers
# First run takes 5-10 minutes
```

### Step 7: Verify Containers are Running

```bash
# Check status
docker-compose ps

# Expected output:
# NAME               STATUS         PORTS
# wazuh.indexer      Up (healthy)   0.0.0.0:9200->9200/tcp
# wazuh.manager      Up (healthy)   0.0.0.0:1514->1514/tcp, 0.0.0.0:55000->55000/tcp
# wazuh.dashboard    Up (healthy)   0.0.0.0:443->5601/tcp

# Check logs if any issues
docker-compose logs -f wazuh.dashboard
```

### Step 8: Configure Windows Firewall

**Important**: Windows Firewall blocks incoming connections by default.

**Option A: PowerShell (Recommended)**

Open **PowerShell as Administrator** on Windows and run:

```powershell
# Allow HTTPS (port 443) for dashboard
New-NetFirewallRule -DisplayName "WSL Wazuh Dashboard" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow

# Allow Wazuh API (port 55000)
New-NetFirewallRule -DisplayName "WSL Wazuh API" -Direction Inbound -LocalPort 55000 -Protocol TCP -Action Allow

# Allow agent communication (port 1514)
New-NetFirewallRule -DisplayName "WSL Wazuh Agent" -Direction Inbound -LocalPort 1514 -Protocol TCP -Action Allow

# Verify rules were created
Get-NetFirewallRule -DisplayName "WSL Wazuh*"
```

**Option B: Windows Defender Firewall GUI**

1. Press `Win + R`, type `wf.msc`, press Enter
2. Click **Inbound Rules** → **New Rule**
3. Rule Type: **Port**
4. Protocol: **TCP**
5. Specific local ports: `443, 55000, 1514`
6. Action: **Allow the connection**
7. Profile: Check **all** (Domain, Private, Public)
8. Name: `WSL Wazuh Ports`
9. Click **Finish**

### Step 9: Get Your WSL IP Address

In WSL terminal:

```bash
# Get WSL IP
WSL_IP=$(ip addr show eth0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
echo "Your WSL IP is: $WSL_IP"

# Example output: 172.28.10.162
```

**Save this IP address** - you'll use it to access Wazuh from Windows.

### Step 10: Access from Windows Browser

1. **Open your browser** (Chrome, Edge, Firefox) **on Windows**

2. **Navigate to**: `https://172.28.10.162:443`
   - Replace `172.28.10.162` with YOUR WSL IP

3. **Accept SSL warning**:
   - Click "Advanced" → "Proceed to 172.28.10.162 (unsafe)"
   - This is expected because we're using self-signed certificates

4. **Login**:
   - Username: `admin`
   - Password: `SecretPassword`

5. **You should see the Wazuh Dashboard!** 🎉

---

## Troubleshooting

### Issue 1: "Can't reach this page" in Windows browser

**Symptoms**: Browser shows "This site can't be reached" or times out.

**Solutions**:

**A. Verify containers are running**:
```bash
# In WSL
docker-compose ps

# All services should show "Up" status
# If any show "Exited", check logs:
docker-compose logs wazuh.dashboard
```

**B. Verify ports are listening**:
```bash
# In WSL
sudo netstat -tulpn | grep -E '443|55000|1514'

# Should show:
# tcp 0.0.0.0:443 LISTEN
# tcp 0.0.0.0:55000 LISTEN
# tcp 0.0.0.0:1514 LISTEN
```

**C. Verify WSL IP is correct**:
```bash
# In WSL
ip addr show eth0

# Find "inet" line, e.g.:
# inet 172.28.10.162/20 brd 172.28.15.255 scope global eth0
```

**D. Test from WSL first**:
```bash
# In WSL
curl -k https://localhost:443

# Should return HTML (Wazuh dashboard page)
```

**E. Check Windows firewall**:
```powershell
# In PowerShell (Admin)
Get-NetFirewallRule -DisplayName "WSL Wazuh*" | Select-Object DisplayName, Enabled, Direction

# All should show "Enabled: True"
```

**F. Temporarily disable Windows Firewall** (for testing only):
```powershell
# PowerShell (Admin)
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Try accessing dashboard
# If it works, firewall was the issue - re-enable and add proper rules

# Re-enable firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
```

### Issue 2: "Connection refused" error

**Cause**: Ports not bound to 0.0.0.0 in docker-compose.yml

**Solution**:
```bash
# Edit docker-compose.yml
nano docker-compose.yml

# Change all ports from:
ports:
  - "443:5601"

# To:
ports:
  - "0.0.0.0:443:5601"

# Restart containers
docker-compose down
docker-compose up -d
```

### Issue 3: Dashboard shows blank page or errors

**Symptoms**: Dashboard loads but shows errors or blank screen

**Solutions**:

**A. Wait for initialization** (first startup takes 2-3 minutes):
```bash
# Watch logs
docker-compose logs -f wazuh.dashboard

# Wait for:
# "Server running at https://0.0.0.0:5601"
```

**B. Check Indexer is healthy**:
```bash
# In WSL
curl -k -u admin:SecretPassword https://localhost:9200/_cluster/health?pretty

# Should show:
# "status": "green" or "yellow" (green is best)
```

**C. Restart services**:
```bash
docker-compose restart wazuh.dashboard
```

### Issue 4: WSL IP keeps changing

**Problem**: Your WSL IP (e.g., 172.28.10.162) changes every time you restart Windows.

**Solution A: Set static IP in WSL** (advanced)

Create `/etc/wsl.conf` in WSL:
```bash
sudo nano /etc/wsl.conf
```

Add:
```ini
[network]
generateResolvConf = false
```

Create `.wslconfig` in Windows user directory (`C:\Users\YourName\.wslconfig`):
```ini
[wsl2]
networkingMode=mirrored
```

**Solution B: Use dynamic DNS** (easier)

Just check your IP each time:
```bash
# Add to ~/.bashrc for easy access
echo 'alias myip="ip addr show eth0 | grep \"inet \" | awk '\''{print \$2}'\'' | cut -d/ -f1"' >> ~/.bashrc
source ~/.bashrc

# Now just run:
myip
```

**Solution C: Use Windows hosts file** (simplest)

Edit `C:\Windows\System32\drivers\etc\hosts` (as Administrator):
```
172.28.10.162   wazuh.local
```

Then access: `https://wazuh.local:443`

**Note**: Update IP if it changes after reboot.

### Issue 5: Certificate errors

**Symptoms**: Browser shows "Your connection is not private" and won't let you proceed.

**Solution**:
- Click "Advanced" → "Proceed to [IP] (unsafe)"
- OR generate proper certificates (see production setup guide)

For learning/testing, self-signed certificates are fine.

### Issue 6: Docker service not starting in WSL

```bash
# Check Docker status
sudo service docker status

# If stopped, start it
sudo service docker start

# If fails with "iptables" errors:
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

# Restart Docker
sudo service docker restart
```

### Issue 7: Out of memory / containers keep restarting

**Symptoms**: Containers show "Restarting" status or crash with OOM errors.

**Solution - Increase WSL2 memory**:

Create `C:\Users\YourName\.wslconfig`:
```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
```

Restart WSL:
```powershell
# In PowerShell
wsl --shutdown
wsl
```

---

## Testing the Setup

### Test 1: Access Dashboard

**From Windows browser**:
```
https://172.28.10.162:443
```

**Expected**: Wazuh login page

### Test 2: Test API

**From Windows PowerShell**:
```powershell
# Ignore SSL certificate errors for testing
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$uri = "https://172.28.10.162:55000"

# Get API token
$cred = "wazuh-wui:MyS3cr37P450r.*-"
$base64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($cred))
$headers = @{"Authorization"="Basic $base64"}

Invoke-RestMethod -Uri "$uri/?pretty=true" -Headers $headers -SkipCertificateCheck
```

**Expected**: JSON response with Wazuh version info

### Test 3: Check Agent Status

**From WSL**:
```bash
docker exec wazuh.manager /var/ossec/bin/agent_control -l
```

**Expected**: List of connected agents (initially empty or just local agent)

---

## Adding Agents from Other Windows Machines

Once Wazuh is running in WSL, you can add agents from:
- Other Windows PCs
- Linux servers
- Your host Windows machine

**Install agent on Windows host**:

```powershell
# Download Wazuh agent installer
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.7.2-1.msi -OutFile wazuh-agent.msi

# Install with your WSL IP as manager
Start-Process msiexec.exe -ArgumentList "/i wazuh-agent.msi /q WAZUH_MANAGER=`"172.28.10.162`" WAZUH_AGENT_NAME=`"WindowsHost`"" -Wait

# Start service
Start-Service -Name wazuh
```

**Verify agent connected**:
```bash
# In WSL
docker exec wazuh.manager /var/ossec/bin/agent_control -l
```

---

## Performance Tips for WSL2

### Optimize Docker Resource Usage

Edit `docker-compose.yml` to reduce memory:

```yaml
wazuh.indexer:
  environment:
    - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m"  # Reduce from 1g
```

### Optimize WSL2 Resources

Edit `C:\Users\YourName\.wslconfig`:

```ini
[wsl2]
memory=8GB          # Adjust based on your RAM
processors=4        # Number of CPU cores
swap=2GB           # Swap space
localhostForwarding=true  # Important for port forwarding
```

### Clean Up Docker Resources

```bash
# Remove unused images
docker system prune -a

# Remove unused volumes (WARNING: deletes data!)
docker volume prune
```

---

## Starting/Stopping Wazuh

### Start Wazuh

```bash
# In WSL, navigate to directory
cd ~/wazuh-docker/single-node

# Start Docker service (if not running)
sudo service docker start

# Start Wazuh
docker-compose up -d

# Check status
docker-compose ps
```

### Stop Wazuh

```bash
# Stop all containers (keeps data)
docker-compose stop

# OR completely remove containers (keeps data in volumes)
docker-compose down

# OR remove everything including data
docker-compose down -v  # WARNING: Deletes all data!
```

### Auto-start Docker on WSL startup

Add to `~/.bashrc`:
```bash
# Auto-start Docker
if service docker status 2>&1 | grep -q "is not running"; then
    sudo service docker start
fi
```

---

## Accessing from Mobile/Other Devices

**On your local network** (same WiFi):

1. **Find Windows host IP** (not WSL IP):
   ```powershell
   # In PowerShell
   ipconfig | findstr IPv4
   ```

2. **Setup port forwarding** (Windows → WSL):
   ```powershell
   # PowerShell (Admin)
   $WSL_IP = "172.28.10.162"  # Your WSL IP
   $WINDOWS_IP = "192.168.1.10"  # Your Windows WiFi IP

   # Forward port 443
   netsh interface portproxy add v4tov4 listenport=443 listenaddress=$WINDOWS_IP connectport=443 connectaddress=$WSL_IP

   # Forward port 55000
   netsh interface portproxy add v4tov4 listenport=55000 listenaddress=$WINDOWS_IP connectport=55000 connectaddress=$WSL_IP

   # Verify
   netsh interface portproxy show all
   ```

3. **Access from mobile**:
   ```
   https://192.168.1.10:443
   ```

**Remove port forwarding**:
```powershell
netsh interface portproxy delete v4tov4 listenport=443 listenaddress=192.168.1.10
netsh interface portproxy delete v4tov4 listenport=55000 listenaddress=192.168.1.10
```

---

## Quick Commands Reference

```bash
# Find WSL IP
ip addr show eth0 | grep "inet " | awk '{print $2}' | cut -d/ -f1

# Start Docker
sudo service docker start

# Start Wazuh
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f [service_name]

# Stop Wazuh
docker-compose stop

# Restart specific service
docker-compose restart wazuh.dashboard

# Enter container
docker exec -it wazuh.manager bash

# Check agent status
docker exec wazuh.manager /var/ossec/bin/agent_control -l

# Test connectivity
curl -k https://localhost:443
```

---

## Summary

**Your Wazuh Setup**:
```
┌────────────────────────────────────┐
│     Windows Host (192.168.1.10)   │
│                                     │
│  Browser: https://172.28.10.162    │
│                                     │
│  ┌──────────────────────────────┐  │
│  │  WSL2 Ubuntu (172.28.10.162) │  │
│  │                               │  │
│  │  Docker Containers:           │  │
│  │  • wazuh.indexer   :9200     │  │
│  │  • wazuh.manager   :55000    │  │
│  │  • wazuh.dashboard :443      │  │
│  └──────────────────────────────┘  │
└────────────────────────────────────┘
```

**Access Points**:
- Dashboard: `https://172.28.10.162:443`
- API: `https://172.28.10.162:55000`
- Username: `admin`
- Password: `SecretPassword`

**Next Steps**:
1. Explore the dashboard
2. Generate test alerts
3. Add more agents
4. Create custom rules
5. Integrate with external tools

---

## Additional Resources

**Official Wazuh Docker Docs**:
- https://documentation.wazuh.com/current/deployment-options/docker/index.html

**WSL2 Networking**:
- https://learn.microsoft.com/en-us/windows/wsl/networking

**Community Support**:
- Wazuh Slack: https://wazuh.com/community/join-us-on-slack/
- GitHub Discussions: https://github.com/wazuh/wazuh/discussions

---

**End of WSL2 Quick Start Guide**

You're now ready to run Wazuh in WSL2 and access it from Windows! 🚀
