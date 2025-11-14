# Wazuh Complete Ecosystem - Docker Setup Guide

## Complete XDR/EDR Platform on Your Laptop

This guide will help you set up the **ENTIRE Wazuh ecosystem** locally using Docker, including:
- ✅ Wazuh Manager (Central Processing)
- ✅ Wazuh Indexer (Data Storage)
- ✅ Wazuh Dashboard (Web UI)
- ✅ Wazuh Agents (Linux endpoint)
- ✅ Attack Simulator (for testing)

**Time to setup**: 30-45 minutes
**Difficulty**: Beginner-friendly

---

## Prerequisites

### System Requirements

**Minimum** (Basic testing):
- RAM: 8 GB
- CPU: 4 cores
- Disk: 50 GB free
- OS: Linux, macOS, or Windows with WSL2

**Recommended** (Comfortable experience):
- RAM: 16 GB
- CPU: 8 cores
- Disk: 100 GB free (SSD preferred)

### Software Requirements

1. **Docker** (20.10.0+)
2. **Docker Compose** (2.0.0+)
3. **Git** (optional, for cloning)

---

## Installation Methods

Choose ONE method below:

### Method 1: Quick Setup (Automated) - RECOMMENDED

This uses Wazuh's official single-node deployment.

```bash
# Clone official Wazuh Docker repository
git clone https://github.com/wazuh/wazuh-docker.git -b v4.7.2
cd wazuh-docker/single-node

# Generate SSL certificates (REQUIRED!)
docker-compose -f generate-indexer-certs.yml run --rm generator

# Start the stack
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f wazuh.manager
```

**Access**:
- Dashboard: https://localhost (or https://localhost:443)
- Username: `admin`
- Password: `SecretPassword`
- API: https://localhost:55000

**Default credentials**:
```
Dashboard UI:
  User: admin
  Pass: SecretPassword

Wazuh API:
  User: wazuh-wui
  Pass: MyS3cr37P450r.*-
```

---

### Method 2: Manual Setup (From Scratch)

If you want to understand every component:

#### Step 1: Create Project Directory

```bash
mkdir wazuh-ecosystem
cd wazuh-ecosystem

# Create directory structure
mkdir -p config/wazuh_indexer_ssl_certs
mkdir -p config/wazuh_dashboard
mkdir -p config/wazuh_cluster
```

#### Step 2: Generate SSL Certificates

Wazuh requires SSL certificates for secure communication.

**Option A: Use Wazuh Certificate Generator**

```bash
# Download certificate generator
curl -so wazuh-certs-tool.sh https://packages.wazuh.com/4.7/wazuh-certs-tool.sh
curl -so config.yml https://packages.wazuh.com/4.7/config.yml

# Edit config.yml with your hostnames (or use defaults)
# For local testing, defaults work fine

# Generate certificates
bash wazuh-certs-tool.sh -A

# Extract certificates
tar -xf wazuh-certificates.tar

# Move to correct location
mv wazuh-certificates/* config/wazuh_indexer_ssl_certs/
```

**Option B: Quick Self-Signed Certificates (Testing Only)**

```bash
cd config/wazuh_indexer_ssl_certs

# Generate CA
openssl req -x509 -newkey rsa:2048 -keyout root-ca-key.pem -out root-ca.pem -days 365 -nodes -subj "/C=US/ST=CA/L=San Jose/O=Wazuh/CN=root-ca"

# Generate Manager certificate
openssl req -newkey rsa:2048 -keyout wazuh.manager-key.pem -out wazuh.manager.csr -nodes -subj "/C=US/ST=CA/L=San Jose/O=Wazuh/CN=wazuh.manager"
openssl x509 -req -in wazuh.manager.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -out wazuh.manager.pem -days 365

# Generate Indexer certificate
openssl req -newkey rsa:2048 -keyout wazuh.indexer-key.pem -out wazuh.indexer.csr -nodes -subj "/C=US/ST=CA/L=San Jose/O=Wazuh/CN=wazuh.indexer"
openssl x509 -req -in wazuh.indexer.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -out wazuh.indexer.pem -days 365

# Generate Dashboard certificate
openssl req -newkey rsa:2048 -keyout wazuh.dashboard-key.pem -out wazuh.dashboard.csr -nodes -subj "/C=US/ST=CA/L=San Jose/O=Wazuh/CN=wazuh.dashboard"
openssl x509 -req -in wazuh.dashboard.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -out wazuh.dashboard.pem -days 365

# Generate Admin certificate (for security plugin)
openssl req -newkey rsa:2048 -keyout admin-key.pem -out admin.csr -nodes -subj "/C=US/ST=CA/L=San Jose/O=Wazuh/CN=admin"
openssl x509 -req -in admin.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -out admin.pem -days 365

# Copy root CA for manager (if needed)
cp root-ca.pem root-ca-manager.pem

# Clean up CSR files
rm *.csr

cd ../..
```

#### Step 3: Create Configuration Files

**config/wazuh_cluster/wazuh_manager.conf**:

```xml
<!--
  Wazuh Manager Configuration
  For complete documentation: https://documentation.wazuh.com
-->

<ossec_config>
  <global>
    <jsonout_output>yes</jsonout_output>
    <alerts_log>yes</alerts_log>
    <logall>no</logall>
    <logall_json>no</logall_json>
    <email_notification>no</email_notification>
    <smtp_server>smtp.example.wazuh.com</smtp_server>
    <email_from>wazuh@example.wazuh.com</email_from>
    <email_to>recipient@example.wazuh.com</email_to>
    <email_maxperhour>12</email_maxperhour>
    <email_log_source>alerts.log</email_log_source>
  </global>

  <alerts>
    <log_alert_level>3</log_alert_level>
    <email_alert_level>12</email_alert_level>
  </alerts>

  <!-- Remote agent registration -->
  <auth>
    <disabled>no</disabled>
    <port>1515</port>
    <use_source_ip>no</use_source_ip>
    <purge>yes</purge>
    <use_password>yes</use_password>
    <ciphers>HIGH:!ADH:!EXP:!MD5:!RC4:!3DES:!CAMELLIA:@STRENGTH</ciphers>
    <!-- <ssl_agent_ca></ssl_agent_ca> -->
    <ssl_verify_host>no</ssl_verify_host>
    <ssl_manager_cert>/var/ossec/etc/sslmanager.cert</ssl_manager_cert>
    <ssl_manager_key>/var/ossec/etc/sslmanager.key</ssl_manager_key>
    <ssl_auto_negotiate>no</ssl_auto_negotiate>
  </auth>

  <remote>
    <connection>secure</connection>
    <port>1514</port>
    <protocol>tcp</protocol>
    <queue_size>131072</queue_size>
  </remote>

  <!-- Policy monitoring -->
  <syscheck>
    <disabled>no</disabled>
    <frequency>43200</frequency>
    <scan_on_start>yes</scan_on_start>

    <!-- File/directories to monitor -->
    <directories>/etc,/usr/bin,/usr/sbin</directories>
    <directories>/bin,/sbin,/boot</directories>

    <!-- Files/directories to ignore -->
    <ignore>/etc/mtab</ignore>
    <ignore>/etc/hosts.deny</ignore>
    <ignore>/etc/mail/statistics</ignore>
    <ignore>/etc/random-seed</ignore>
    <ignore>/etc/random.seed</ignore>
    <ignore>/etc/adjtime</ignore>
    <ignore>/etc/httpd/logs</ignore>
    <ignore>/etc/utmpx</ignore>
    <ignore>/etc/wtmpx</ignore>
    <ignore>/etc/cups/certs</ignore>
    <ignore>/etc/dumpdates</ignore>
    <ignore>/etc/svc/volatile</ignore>
  </syscheck>

  <!-- Rootcheck - Policy and auditing -->
  <rootcheck>
    <disabled>no</disabled>
    <check_files>yes</check_files>
    <check_trojans>yes</check_trojans>
    <check_dev>yes</check_dev>
    <check_sys>yes</check_sys>
    <check_pids>yes</check_pids>
    <check_ports>yes</check_ports>
    <check_if>yes</check_if>

    <!-- Frequency -->
    <frequency>43200</frequency>

    <rootkit_files>/var/ossec/etc/rootcheck/rootkit_files.txt</rootkit_files>
    <rootkit_trojans>/var/ossec/etc/rootcheck/rootkit_trojans.txt</rootkit_trojans>

    <skip_nfs>yes</skip_nfs>
  </rootcheck>

  <wodle name="open-scap">
    <disabled>yes</disabled>
    <timeout>1800</timeout>
    <interval>1d</interval>
    <scan-on-start>yes</scan-on-start>
  </wodle>

  <wodle name="cis-cat">
    <disabled>yes</disabled>
    <timeout>1800</timeout>
    <interval>1d</interval>
    <scan-on-start>yes</scan-on-start>
  </wodle>

  <!-- System inventory -->
  <wodle name="syscollector">
    <disabled>no</disabled>
    <interval>1h</interval>
    <scan_on_start>yes</scan_on_start>
    <hardware>yes</hardware>
    <os>yes</os>
    <network>yes</network>
    <packages>yes</packages>
    <ports all="no">yes</ports>
    <processes>yes</processes>
  </wodle>

  <!-- Vulnerability Detector -->
  <vulnerability-detector>
    <enabled>yes</enabled>
    <interval>5m</interval>
    <min_full_scan_interval>6h</min_full_scan_interval>
    <run_on_start>yes</run_on_start>

    <!-- Ubuntu OS vulnerabilities -->
    <provider name="canonical">
      <enabled>yes</enabled>
      <os>trusty</os>
      <os>xenial</os>
      <os>bionic</os>
      <os>focal</os>
      <os>jammy</os>
      <update_interval>1h</update_interval>
    </provider>

    <!-- RedHat OS vulnerabilities -->
    <provider name="redhat">
      <enabled>yes</enabled>
      <update_interval>1h</update_interval>
    </provider>

    <!-- Debian OS vulnerabilities -->
    <provider name="debian">
      <enabled>yes</enabled>
      <os>stretch</os>
      <os>buster</os>
      <os>bullseye</os>
      <update_interval>1h</update_interval>
    </provider>
  </vulnerability-detector>

  <!-- File integrity monitoring -->
  <sca>
    <enabled>yes</enabled>
    <scan_on_start>yes</scan_on_start>
    <interval>12h</interval>
    <skip_nfs>yes</skip_nfs>
  </sca>

  <!-- Active response -->
  <global>
    <white_list>127.0.0.1</white_list>
    <white_list>^localhost.localdomain$</white_list>
  </global>

  <command>
    <name>disable-account</name>
    <executable>disable-account</executable>
    <timeout_allowed>yes</timeout_allowed>
  </command>

  <command>
    <name>restart-wazuh</name>
    <executable>restart-wazuh</executable>
  </command>

  <command>
    <name>firewall-drop</name>
    <executable>firewall-drop</executable>
    <timeout_allowed>yes</timeout_allowed>
  </command>

  <command>
    <name>host-deny</name>
    <executable>host-deny</executable>
    <timeout_allowed>yes</timeout_allowed>
  </command>

  <command>
    <name>route-null</name>
    <executable>route-null</executable>
    <timeout_allowed>yes</timeout_allowed>
  </command>

  <command>
    <name>win_route-null</name>
    <executable>route-null.exe</executable>
    <timeout_allowed>yes</timeout_allowed>
  </command>

  <command>
    <name>netsh</name>
    <executable>netsh.exe</executable>
    <timeout_allowed>yes</timeout_allowed>
  </command>

  <!-- Active response for SSH attacks -->
  <active-response>
    <command>firewall-drop</command>
    <location>local</location>
    <rules_id>5710,5711,5712</rules_id>
    <timeout>180</timeout>
  </active-response>

  <!-- Active response for repeated login failures -->
  <active-response>
    <disabled>no</disabled>
    <command>firewall-drop</command>
    <location>local</location>
    <rules_id>5503</rules_id>
    <timeout>600</timeout>
  </active-response>

  <!-- Log analysis -->
  <localfile>
    <log_format>command</log_format>
    <command>df -P</command>
    <frequency>360</frequency>
  </localfile>

  <localfile>
    <log_format>full_command</log_format>
    <command>netstat -tulpn | sed 's/\([[:alnum:]]\+\)\ \+[[:digit:]]\+\ \+[[:digit:]]\+\ \+\(.*\):\([[:digit:]]*\)\ \+\([0-9\.\:\*]\+\).\+\ \([[:digit:]]*\/[[:alnum:]\-]*\).*/\1 \2 == \3 == \4 \5/' | sort -k 4 -g | sed 's/ == \(.*\) ==/:\1/' | sed 1,2d</command>
    <alias>netstat listening ports</alias>
    <frequency>360</frequency>
  </localfile>

  <localfile>
    <log_format>full_command</log_format>
    <command>last -n 20</command>
    <frequency>360</frequency>
  </localfile>

  <!-- Integrate with external tools -->
  <integration>
    <name>slack</name>
    <hook_url>https://hooks.slack.com/services/...</hook_url>
    <level>10</level>
    <alert_format>json</alert_format>
  </integration>

</ossec_config>
```

**config/wazuh_dashboard/opensearch_dashboards.yml**:

```yaml
server.host: 0.0.0.0
server.port: 5601
opensearch.hosts: https://wazuh.indexer:9200
opensearch.ssl.verificationMode: certificate
opensearch.username: kibanaserver
opensearch.password: kibanaserver
opensearch.requestHeadersWhitelist: ["securitytenant","Authorization"]
opensearch_security.multitenancy.enabled: false
opensearch_security.readonly_mode.roles: ["kibana_read_only"]
server.ssl.enabled: true
server.ssl.key: "/usr/share/wazuh-dashboard/certs/wazuh-dashboard-key.pem"
server.ssl.certificate: "/usr/share/wazuh-dashboard/certs/wazuh-dashboard.pem"
opensearch.ssl.certificateAuthorities: ["/usr/share/wazuh-dashboard/certs/root-ca.pem"]
uiSettings.overrides.defaultRoute: "/app/wazuh"
opensearch_security.cookie.secure: true
```

**config/wazuh_dashboard/wazuh.yml**:

```yaml
hosts:
  - production:
      url: https://wazuh.manager
      port: 55000
      username: wazuh-wui
      password: MyS3cr37P450r.*-
      run_as: false
```

#### Step 4: Use the Docker Compose File

Use the `docker-compose-complete-ecosystem.yml` file I created earlier, or download the official one.

#### Step 5: Start the Stack

```bash
# Start all services
docker-compose -f docker-compose-complete-ecosystem.yml up -d

# Check status
docker-compose -f docker-compose-complete-ecosystem.yml ps

# View logs
docker-compose -f docker-compose-complete-ecosystem.yml logs -f
```

---

## Verification & Testing

### Step 1: Check All Containers are Running

```bash
docker-compose ps

# Expected output:
# NAME                  STATUS              PORTS
# wazuh.indexer         Up (healthy)        9200/tcp
# wazuh.manager         Up (healthy)        1514/tcp, 1515/tcp, 55000/tcp
# wazuh.dashboard       Up (healthy)        443/tcp
# wazuh.agent.linux     Up                  -
```

### Step 2: Access the Dashboard

1. Open browser: **https://localhost** (or https://localhost:443)
2. Accept self-signed certificate warning
3. Login:
   - Username: `admin`
   - Password: `SecretPassword`

**First-time setup**:
- Dashboard may take 2-3 minutes to fully initialize
- You'll see Wazuh welcome screen
- Initial dashboards will be empty (no data yet)

### Step 3: Verify Agent Connection

```bash
# Check agent status from manager
docker exec wazuh.manager /var/ossec/bin/agent_control -l

# Expected output:
# Wazuh agent_control:
# Available agents:
#    ID: 001, Name: systemA-linux, IP: 172.x.x.x, Status: Active
```

### Step 4: Generate Test Alerts

**Option A: Use Attack Simulator**

The `attack.simulator` container automatically generates simulated attacks.

```bash
# Check simulator logs
docker logs attack.simulator

# You should see:
# Simulated SSH failed login attempt...
# Simulated web attack...
```

**Option B: Manual Test from Agent**

```bash
# Enter agent container
docker exec -it wazuh.agent.linux bash

# Simulate failed SSH login
echo "$(date) sshd[12345]: Failed password for invalid user admin from 192.168.1.100 port 12345 ssh2" >> /var/log/auth.log

# Simulate file modification
touch /tmp/test_file.txt
echo "test content" > /tmp/test_file.txt

# Simulate malware download (fake, safe)
curl -o /tmp/malware.exe http://example.com/fake-malware

# Exit container
exit
```

### Step 5: Verify Alerts in Dashboard

1. Go to Dashboard: **https://localhost**
2. Navigate to: **Security Events** → **Events**
3. You should see:
   - SSH brute force attempts (Rule 5710)
   - File modifications (Rule 550)
   - Web attacks (Rule 31103)
   - Vulnerability detections

### Step 6: Test API

```bash
# Get API token
TOKEN=$(curl -u wazuh-wui:MyS3cr37P450r.*- -k -X POST "https://localhost:55000/security/user/authenticate?raw=true")

# List agents
curl -k -X GET "https://localhost:55000/agents?pretty=true" -H "Authorization: Bearer $TOKEN"

# Get manager status
curl -k -X GET "https://localhost:55000/manager/status?pretty=true" -H "Authorization: Bearer $TOKEN"
```

---

## Understanding the Components

### Component Interaction Flow

```
┌──────────────────────────────────────────────────────────┐
│                  YOUR DOCKER ENVIRONMENT                  │
└──────────────────────────────────────────────────────────┘

[wazuh.agent.linux] Container
   │ Collects events from:
   │ • File changes (/etc, /tmp, etc.)
   │ • Log files (/var/log/*)
   │ • System inventory (packages, processes)
   │ • Docker socket (container events)
   │
   │ Filters & Buffers locally
   │ Encrypts data (AES)
   ↓
   TCP Port 1514 (encrypted)
   ↓
[wazuh.manager] Container
   │ wazuh-remoted: Receives & decrypts
   │ wazuh-engine: Applies rules & decoders
   │   ├─ Decodes log format
   │   ├─ Matches attack patterns (5,000+ rules)
   │   ├─ Enriches with GeoIP, MITRE ATT&CK
   │   └─ Generates alerts
   │ Filebeat: Forwards alerts
   ↓
   HTTPS Port 9200
   ↓
[wazuh.indexer] Container
   │ OpenSearch: Stores & indexes
   │   ├─ wazuh-alerts-* (alerts)
   │   ├─ wazuh-archives-* (all events)
   │   ├─ wazuh-monitoring-* (agent status)
   │
   ↓ Queries via HTTPS
   ↓
[wazuh.dashboard] Container
   │ Visualizes in Web UI (Port 443)
   │   ├─ Real-time alerts dashboard
   │   ├─ MITRE ATT&CK heatmap
   │   ├─ Compliance reports (PCI, GDPR)
   │   ├─ Agent inventory
   │   └─ File integrity monitoring
```

### Data Flow Example: SSH Brute Force Attack

```
1. AGENT (wazuh.agent.linux):
   └─ Reads /var/log/auth.log
   └─ Detects: "Failed password for admin from 192.168.1.100"
   └─ Buffers event
   └─ Encrypts & sends to manager

2. MANAGER (wazuh.manager):
   └─ wazuh-remoted receives encrypted message
   └─ Decrypts
   └─ wazuh-engine processes:
      ├─ Decoder: sshd decoder extracts fields
      │   {user: "admin", src_ip: "192.168.1.100", action: "failed"}
      │
      ├─ Rule 5710: "SSH brute force"
      │   IF (failed_login_count > 8 in 120 seconds)
      │   THEN alert_level = 10
      │
      ├─ Enrichment:
      │   └─ GeoIP: 192.168.1.100 → US, California
      │   └─ MITRE: T1110.001 (Password Guessing)
      │
      └─ Generate Alert:
          {
            "rule_id": 5710,
            "level": 10,
            "description": "Possible SSH brute force",
            "src_ip": "192.168.1.100",
            "location": "systemA-linux",
            "mitre_technique": "T1110.001"
          }

3. INDEXER (wazuh.indexer):
   └─ Receives alert from Filebeat
   └─ Indexes in wazuh-alerts-4.x-2024.11.14
   └─ Makes searchable

4. DASHBOARD (wazuh.dashboard):
   └─ Queries indexer every 5 seconds
   └─ Displays alert in real-time
   └─ Updates MITRE ATT&CK heatmap
   └─ Increments "SSH Attacks" counter
```

---

## Common Use Cases & Examples

### Use Case 1: File Integrity Monitoring

**Scenario**: Monitor critical system files for unauthorized changes

```bash
# Enter agent container
docker exec -it wazuh.agent.linux bash

# Create monitored directory
mkdir -p /etc/myapp
echo "config=production" > /etc/myapp/config.conf

# Modify agent configuration to monitor this directory
# (In production, this is done via manager API)
echo '<directories realtime="yes">/etc/myapp</directories>' >> /var/ossec/etc/ossec.conf

# Restart agent
/var/ossec/bin/wazuh-control restart

# Simulate unauthorized modification
sleep 10
echo "config=hacked" > /etc/myapp/config.conf

# Exit container
exit
```

**Result in Dashboard**:
- Alert: "Integrity checksum changed" (Rule 550)
- Shows: Old hash vs New hash
- Who/What process made the change (if Whodata enabled)

### Use Case 2: Rootkit Detection

```bash
# Enter agent container
docker exec -it wazuh.agent.linux bash

# Simulate rootkit artifacts
mkdir -p /dev/.hidden
echo "malicious script" > /dev/.hidden/backdoor.sh
chmod +x /dev/.hidden/backdoor.sh

# Rootcheck will detect on next scan (runs every 12 hours by default)
# Force immediate scan:
/var/ossec/bin/rootcheck_control -u 001

exit
```

**Result**:
- Alert: "Rootkit detected" (Rule 510)
- Details: Hidden directory in /dev/

### Use Case 3: Vulnerability Detection

```bash
# Install vulnerable package in agent
docker exec -it wazuh.agent.linux bash

apt-get update
apt-get install -y apache2=2.4.41-4ubuntu3  # Known vulnerable version

exit
```

**Result** (after ~5 minutes):
- Alert: "CVE-2021-XXXX detected in apache2"
- Severity: Critical
- Remediation: Upgrade to apache2 >= 2.4.46

### Use Case 4: Compliance Monitoring (CIS Benchmark)

```bash
# Agents automatically run SCA policies
# Check compliance status in Dashboard:
# Security Configuration Assessment → Agents → Select agent

# Example checks:
# - Ensure password complexity is enforced
# - Ensure firewall is enabled
# - Ensure unnecessary services are disabled
```

**Result**:
- Compliance score: 85/100
- Failed checks highlighted
- Remediation steps provided

---

## Customization & Advanced Configuration

### Add More Agents

**Linux Agent**:

```bash
# On target host (outside Docker)
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list
apt-get update
apt-get install -y wazuh-agent

# Configure manager address
echo "WAZUH_MANAGER='<your-docker-host-ip>'" >> /var/ossec/etc/ossec.conf

# Start agent
systemctl enable wazuh-agent
systemctl start wazuh-agent
```

**Windows Agent**:

```powershell
# Download installer
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.7.2-1.msi -OutFile wazuh-agent.msi

# Install with manager address
Start-Process msiexec.exe -ArgumentList '/i wazuh-agent.msi /q WAZUH_MANAGER="<your-docker-host-ip>"' -Wait

# Start service
Start-Service -Name wazuh
```

### Custom Rules

Create custom detection rules:

```bash
# Enter manager container
docker exec -it wazuh.manager bash

# Create custom rule file
cat > /var/ossec/etc/rules/local_rules.xml << 'EOF'
<group name="local,syslog,">
  <!-- Custom rule: Detect sudo to root -->
  <rule id="100001" level="5">
    <if_sid>5401</if_sid>
    <match>sudo: </match>
    <user>root</user>
    <description>User $(user) escalated to root</description>
    <mitre>
      <id>T1548.003</id>
    </mitre>
  </rule>

  <!-- Custom rule: Detect cryptocurrency mining -->
  <rule id="100002" level="12">
    <if_sid>500</if_sid>
    <match>xmrig|ethminer|cgminer</match>
    <description>Cryptocurrency miner detected</description>
    <mitre>
      <id>T1496</id>
    </mitre>
  </rule>
</group>
EOF

# Restart manager to apply
/var/ossec/bin/wazuh-control restart

exit
```

### Integrate with External Tools

**Slack Integration**:

```bash
# Edit manager config
docker exec -it wazuh.manager bash

# Add to /var/ossec/etc/ossec.conf
cat >> /var/ossec/etc/ossec.conf << 'EOF'
<integration>
  <name>slack</name>
  <hook_url>https://hooks.slack.com/services/YOUR/WEBHOOK/URL</hook_url>
  <level>10</level>
  <alert_format>json</alert_format>
</integration>
EOF

/var/ossec/bin/wazuh-control restart
exit
```

**Email Alerts**:

```xml
<!-- In /var/ossec/etc/ossec.conf -->
<global>
  <email_notification>yes</email_notification>
  <smtp_server>smtp.gmail.com</smtp_server>
  <email_from>wazuh@yourdomain.com</email_from>
  <email_to>admin@yourdomain.com</email_to>
</global>
```

---

## Troubleshooting

### Issue 1: Containers Not Starting

```bash
# Check Docker resources
docker system df
docker system prune  # Free up space

# Check RAM
free -h

# Increase Docker memory (Docker Desktop)
# Settings → Resources → Memory → 8GB+
```

### Issue 2: Dashboard Shows "No data"

```bash
# Check Filebeat is running
docker exec wazuh.manager systemctl status filebeat

# Check Indexer connectivity
docker exec wazuh.manager curl -k https://wazuh.indexer:9200

# Restart Filebeat
docker exec wazuh.manager systemctl restart filebeat

# Check indices
docker exec wazuh.indexer curl -k -u admin:SecretPassword https://localhost:9200/_cat/indices
```

### Issue 3: Agent Not Connecting

```bash
# Check agent status
docker logs wazuh.agent.linux

# Check manager logs
docker logs wazuh.manager | grep -i agent

# Verify network
docker exec wazuh.agent.linux ping wazuh.manager

# Check enrollment password
docker exec wazuh.manager cat /var/ossec/etc/authd.pass
```

### Issue 4: High Resource Usage

```bash
# Check resource usage
docker stats

# Reduce indexer memory
# Edit docker-compose.yml:
# OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m

# Disable vulnerability detector (temporary)
# In ossec.conf: <vulnerability-detector><enabled>no</enabled>
```

### Issue 5: Certificate Errors

```bash
# Regenerate certificates
cd config/wazuh_indexer_ssl_certs
# Follow Step 2: Generate SSL Certificates again

# Restart all services
docker-compose restart
```

---

## Performance Tuning

### For 8GB RAM System

```yaml
# docker-compose.yml adjustments
wazuh.indexer:
  environment:
    - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m"  # Reduce from 1g

wazuh.manager:
  # Add resource limits
  mem_limit: 2g
  cpus: 2
```

### For 16GB+ RAM System

```yaml
wazuh.indexer:
  environment:
    - "OPENSEARCH_JAVA_OPTS=-Xms2g -Xmx2g"  # Increase

wazuh.manager:
  mem_limit: 4g
  cpus: 4
```

---

## Production Considerations

### ⚠️ This Setup is for LEARNING ONLY

**For production, you MUST**:

1. **Change all passwords**:
   ```yaml
   INDEXER_PASSWORD: "StrongRandomPassword123!"
   API_PASSWORD: "AnotherStrongPassword456!"
   ```

2. **Use proper SSL certificates** (not self-signed):
   - Purchase from CA (DigiCert, Let's Encrypt)
   - Or use internal PKI

3. **Separate hosts**:
   - Manager: 4 CPU, 8GB RAM, 100GB disk
   - Indexer: 8 CPU, 16GB RAM, 500GB SSD
   - Dashboard: 2 CPU, 4GB RAM, 50GB disk

4. **Enable clustering**:
   - Multiple managers (HA)
   - Multiple indexer nodes (sharding)

5. **Implement backup**:
   - Indexer snapshots
   - Manager configuration backup
   - Agent key backup

6. **Set up monitoring**:
   - Prometheus + Grafana
   - Alert on disk space, CPU, memory

7. **Harden security**:
   - Firewall rules (only ports 1514, 1515, 443, 55000)
   - SELinux/AppArmor policies
   - Disable root login
   - Enable 2FA for dashboard

---

## Cleanup & Removal

### Stop All Services

```bash
docker-compose -f docker-compose-complete-ecosystem.yml down
```

### Remove All Data (Volumes)

```bash
# WARNING: This deletes ALL collected data!
docker-compose -f docker-compose-complete-ecosystem.yml down -v

# Verify volumes deleted
docker volume ls | grep wazuh
```

### Complete Cleanup

```bash
# Stop and remove everything
docker-compose down -v

# Remove images
docker rmi wazuh/wazuh-manager:4.7.2
docker rmi wazuh/wazuh-indexer:4.7.2
docker rmi wazuh/wazuh-dashboard:4.7.2
docker rmi wazuh/wazuh-agent:4.7.2

# Clean up Docker system
docker system prune -a --volumes
```

---

## Next Steps

### Learning Path

1. **Week 1**: Setup & Explore
   - Deploy this Docker setup
   - Generate test alerts
   - Explore dashboard
   - Read official docs

2. **Week 2**: Customization
   - Create custom rules
   - Add more agents (Windows, macOS)
   - Configure integrations (Slack, email)
   - Test compliance policies

3. **Week 3**: Advanced Features
   - Active response configuration
   - Vulnerability scanning
   - Cloud integration (AWS, Azure)
   - API automation

4. **Week 4**: Architecture Deep Dive
   - Read source code (agent, manager)
   - Understand rule engine
   - Modify components
   - Build custom modules

### Resources

**Official Documentation**:
- https://documentation.wazuh.com
- https://github.com/wazuh/wazuh
- https://github.com/wazuh/wazuh-docker

**Community**:
- Slack: https://wazuh.com/community/join-us-on-slack/
- Forum: https://groups.google.com/g/wazuh
- GitHub Discussions: https://github.com/wazuh/wazuh/discussions

**Training**:
- Wazuh Fundamentals (Free): https://wazuh.com/training/
- YouTube Channel: https://www.youtube.com/c/wazuhsecurity

---

## Summary

You now have:
- ✅ Complete XDR/EDR platform running locally
- ✅ Understanding of each component's role
- ✅ Ability to generate and analyze security alerts
- ✅ Hands-on experience with enterprise security tools
- ✅ Foundation for contributing to Wazuh project

**Total setup time**: 30-45 minutes
**Learning value**: Equivalent to $5,000+ commercial XDR course

**Your ecosystem includes**:
- Event collection (agents)
- Processing & analysis (manager + engine)
- Storage & indexing (OpenSearch)
- Visualization (dashboard)
- Attack simulation (for testing)

This is a **real production-grade security platform** running on your laptop! 🚀

---

## Appendix: Quick Command Reference

```bash
# Start ecosystem
docker-compose up -d

# Stop ecosystem
docker-compose down

# View logs
docker-compose logs -f [service_name]

# Enter container
docker exec -it [container_name] bash

# Check agent status
docker exec wazuh.manager /var/ossec/bin/agent_control -l

# Restart manager
docker exec wazuh.manager /var/ossec/bin/wazuh-control restart

# Check rules
docker exec wazuh.manager ls -lh /var/ossec/ruleset/rules/

# Test rule
docker exec wazuh.manager /var/ossec/bin/wazuh-logtest

# Check indexer health
docker exec wazuh.indexer curl -k -u admin:SecretPassword https://localhost:9200/_cluster/health?pretty

# Backup configuration
docker cp wazuh.manager:/var/ossec/etc/ossec.conf ./backup-ossec.conf

# Monitor resource usage
docker stats
```

---

**End of Guide**

Questions? Check official docs or ask in Wazuh community Slack!
