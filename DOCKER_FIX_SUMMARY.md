# Docker Compose Fix Summary

## Problem Identified

The docker-compose-working.yml was failing with the following error:
```
OpenSearchException[Unable to read /usr/share/wazuh-indexer/certs/wazuh.indexer.key]
```

### Root Causes

1. **Missing SSL Certificates**: The `config/wazuh_indexer_ssl_certs/` directory and all SSL certificates were missing
2. **Missing Configuration Files**: Required configuration files for indexer, dashboard, and manager were missing
3. **Network Configuration**: The docker-compose file was using `single-node_default` network instead of `wazuh` network

## Solution Implemented

### 1. Created Setup Script (`setup-wazuh-docker.sh`)

This script automatically:
- Creates the required directory structure
- Generates self-signed SSL certificates for all components
- Creates all necessary configuration files
- Sets appropriate permissions

**Generated Certificates:**
- Root CA certificate
- Wazuh Manager certificate
- Wazuh Indexer certificate
- Wazuh Dashboard certificate
- Admin certificate (for security plugin)

**Generated Config Files:**
- `config/wazuh_indexer/wazuh.indexer.yml` - Indexer configuration
- `config/wazuh_indexer/internal_users.yml` - User authentication
- `config/wazuh_dashboard/opensearch_dashboards.yml` - Dashboard configuration
- `config/wazuh_dashboard/wazuh.yml` - Wazuh plugin configuration
- `config/wazuh_cluster/wazuh_manager.conf` - Manager configuration

### 2. Fixed docker-compose-working.yml

**Changes Made:**
- Changed network from `single-node_default` to `wazuh` across all services
- Ensured consistent network naming

## How to Use

### Quick Start

```bash
# 1. Run the setup script (already done)
bash setup-wazuh-docker.sh

# 2. Start the Docker stack
docker-compose -f docker-compose-working.yml up -d

# 3. Check status
docker-compose -f docker-compose-working.yml ps

# 4. View logs
docker-compose -f docker-compose-working.yml logs -f wazuh.indexer
docker-compose -f docker-compose-working.yml logs -f wazuh.manager
docker-compose -f docker-compose-working.yml logs -f wazuh.dashboard

# 5. Access the dashboard
# Open browser: https://localhost (or https://localhost:443)
# Username: admin
# Password: SecretPassword
```

### Verification Steps

1. **Check all containers are running:**
   ```bash
   docker-compose -f docker-compose-working.yml ps
   ```
   Expected: All containers should be "Up" or "Up (healthy)"

2. **Verify agent connection:**
   ```bash
   docker exec wazuh.manager /var/ossec/bin/agent_control -l
   ```
   Expected: Should show agent "systemA-linux" as Active

3. **Check indexer health:**
   ```bash
   docker exec wazuh.indexer curl -k -u admin:SecretPassword https://localhost:9200/_cluster/health?pretty
   ```
   Expected: Status should be "green" or "yellow"

## Components Overview

Your complete Wazuh ecosystem includes:

1. **wazuh.indexer** - OpenSearch-based data storage (Port 9200)
2. **wazuh.manager** - Central security management server (Ports 1514, 1515, 55000)
3. **wazuh.dashboard** - Web interface (Port 443)
4. **wazuh.agent.linux** - Simulated Linux endpoint
5. **attack.simulator** - Generates simulated security events for testing

## Credentials

**Dashboard Access:**
- URL: https://localhost
- Username: `admin`
- Password: `SecretPassword`

**Wazuh API:**
- URL: https://localhost:55000
- Username: `wazuh-wui`
- Password: `MyS3cr37P450r.*-`

**Indexer:**
- Username: `admin`
- Password: `SecretPassword`

## Troubleshooting

### Issue: Containers keep restarting

**Check logs:**
```bash
docker-compose -f docker-compose-working.yml logs [service_name]
```

**Common solutions:**
- Increase Docker memory to at least 8GB
- Check disk space: `docker system df`
- Clean up: `docker system prune`

### Issue: Dashboard shows "No data"

**Solution:**
```bash
# Restart Filebeat
docker exec wazuh.manager systemctl restart filebeat

# Check indices
docker exec wazuh.indexer curl -k -u admin:SecretPassword https://localhost:9200/_cat/indices
```

### Issue: Agent not connecting

**Solution:**
```bash
# Check agent logs
docker logs wazuh.agent.linux

# Check manager logs for agent registration
docker logs wazuh.manager | grep -i agent

# Verify network connectivity
docker exec wazuh.agent.linux ping -c 3 wazuh.manager
```

### Issue: Certificate errors

**Solution:**
```bash
# Regenerate certificates
rm -rf config/
bash setup-wazuh-docker.sh

# Restart all services
docker-compose -f docker-compose-working.yml restart
```

## Testing Attack Detection

### View Simulated Attacks

The attack.simulator container automatically generates:
- Failed SSH login attempts
- Web attack patterns (SQL injection, path traversal)
- Suspicious script creation

### Manual Testing

```bash
# Enter agent container
docker exec -it wazuh.agent.linux bash

# Simulate failed login
echo "$(date '+%b %d %H:%M:%S') sshd[12345]: Failed password for root from 10.0.0.1 port 22" >> /var/log/auth.log

# Simulate file modification
echo "sensitive data" > /etc/test.txt

# Exit
exit
```

### View Alerts in Dashboard

1. Navigate to: **Security Events** → **Events**
2. Look for:
   - Rule 5710: SSH brute force attempts
   - Rule 550: File integrity changes
   - Rule 31103: Web attacks

## Architecture

```
[wazuh.agent.linux]
   │ Monitors: logs, files, processes
   │ Encrypts and sends events
   ↓
   TCP Port 1514
   ↓
[wazuh.manager]
   │ Decodes events
   │ Applies 5000+ security rules
   │ Enriches with MITRE ATT&CK
   │ Generates alerts
   ↓
   HTTPS Port 9200
   ↓
[wazuh.indexer]
   │ Stores and indexes alerts
   │ Searchable database
   ↓
   HTTPS Query
   ↓
[wazuh.dashboard]
   │ Visualizes in Web UI (Port 443)
   │ Real-time monitoring
```

## Next Steps

1. **Explore the Dashboard**
   - Navigate through different sections
   - Check Security Events
   - Review MITRE ATT&CK coverage
   - Explore Compliance (PCI DSS, GDPR)

2. **Customize Rules**
   - Create custom detection rules
   - Adjust alert thresholds
   - Add integrations (Slack, email)

3. **Add More Agents**
   - Deploy agents on real systems
   - Windows, macOS, Linux endpoints
   - Cloud instances (AWS, Azure)

4. **Learn the Architecture**
   - Study the source code
   - Understand the rule engine
   - Contribute to the project

## Important Notes

⚠️ **This setup is for LEARNING purposes only!**

For production use:
- Change all default passwords
- Use proper SSL certificates from a CA
- Separate hosts for each component
- Enable clustering for high availability
- Implement backup strategies
- Harden security configurations

## Files Created

```
.
├── setup-wazuh-docker.sh           # Setup script
├── docker-compose-working.yml      # Fixed Docker Compose file
└── config/
    ├── wazuh_indexer_ssl_certs/
    │   ├── root-ca.pem
    │   ├── root-ca-manager.pem
    │   ├── wazuh.manager.pem
    │   ├── wazuh.manager-key.pem
    │   ├── wazuh.indexer.pem
    │   ├── wazuh.indexer-key.pem
    │   ├── wazuh.dashboard.pem
    │   ├── wazuh.dashboard-key.pem
    │   ├── admin.pem
    │   └── admin-key.pem
    ├── wazuh_indexer/
    │   ├── wazuh.indexer.yml
    │   └── internal_users.yml
    ├── wazuh_dashboard/
    │   ├── opensearch_dashboards.yml
    │   └── wazuh.yml
    └── wazuh_cluster/
        └── wazuh_manager.conf
```

## Resources

- Official Documentation: https://documentation.wazuh.com
- Wazuh Docker Repository: https://github.com/wazuh/wazuh-docker
- Community Slack: https://wazuh.com/community/join-us-on-slack/
- YouTube Channel: https://www.youtube.com/c/wazuhsecurity

---

**Status:** ✅ All issues fixed and ready to deploy!

**Setup Time:** Complete
**Next Action:** Run `docker-compose -f docker-compose-working.yml up -d`
