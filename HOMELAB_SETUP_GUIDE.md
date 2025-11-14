# Wazuh Development Homelab Setup Guide

## Introduction

This guide provides a **practical, battle-tested approach** to setting up a complete Wazuh development environment. Based on analyzing the codebase, here's what you need to know about contributing to Wazuh effectively.

---

## Table of Contents

1. [Prerequisites & Hardware Requirements](#prerequisites--hardware-requirements)
2. [Architecture Decision: Local vs Cloud](#architecture-decision-local-vs-cloud)
3. [Recommended Setup: Hybrid Approach](#recommended-setup-hybrid-approach)
4. [Step-by-Step Implementation](#step-by-step-implementation)
5. [Development Workflow](#development-workflow)
6. [Testing Scenarios](#testing-scenarios)
7. [Common Contributor Workflows](#common-contributor-workflows)
8. [Cost Analysis](#cost-analysis)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites & Hardware Requirements

### Minimum Local Hardware
- **CPU**: 4 cores (8 threads recommended for building)
- **RAM**: 16GB minimum (32GB recommended)
- **Storage**: 100GB SSD free space
- **OS**: Linux (Ubuntu 22.04 LTS recommended) or macOS

### Software Prerequisites
```bash
# Development tools
sudo apt update
sudo apt install -y git build-essential cmake gcc g++ \
    python3 python3-pip python3-venv \
    libssl-dev libpcre2-dev zlib1g-dev \
    sqlite3 libsqlite3-dev \
    libbz2-dev libarchive-dev \
    curl wget jq vim

# Container runtime (choose one)
# Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# OR Podman (rootless alternative)
sudo apt install -y podman podman-compose
```

---

## Architecture Decision: Local vs Cloud

### Option 1: Fully Local Setup
**Pros:**
- No ongoing costs
- Full control
- Fast iteration
- Works offline

**Cons:**
- Requires powerful local hardware
- Limited scalability testing
- Cannot test distributed deployments easily

### Option 2: Cloud-Only Setup
**Pros:**
- Scalable resources
- Test distributed architectures
- Multi-platform testing (Windows, different Linux distros)
- Realistic network latency

**Cons:**
- Ongoing costs ($50-200/month)
- Requires internet connection
- Slower development iteration

### Option 3: Hybrid (RECOMMENDED)
**Pros:**
- Best of both worlds
- Cost-effective ($10-50/month)
- Fast local development
- Cloud for integration testing

**Cons:**
- Slightly more complex setup

---

## Recommended Setup: Hybrid Approach

### Local Development Environment
Your local machine handles:
1. **Source code editing** (VS Code, Vim, etc.)
2. **Compilation** (faster feedback loop)
3. **Unit testing**
4. **Single-agent testing** (manager + 1 agent on same host)
5. **Code analysis** (linters, static analysis)

### Cloud Testing Environment (AWS/GCP/Azure)
Cloud instances handle:
1. **Multi-agent scenarios** (10-100+ agents)
2. **Cross-platform testing** (Windows, CentOS, Ubuntu, macOS)
3. **Performance testing**
4. **Network isolation testing**
5. **Integration testing**
6. **Cluster mode testing**

---

## Step-by-Step Implementation

### Phase 1: Local Development Setup (Day 1)

#### 1.1 Clone and Build Wazuh

```bash
# Clone repository (you already have this)
cd ~/
git clone https://github.com/wazuh/wazuh.git
cd wazuh

# Checkout your development branch
git checkout -b your-feature-branch

# Install build dependencies
cd src
make deps

# Build agent (fastest to build, good for learning)
make TARGET=agent

# Build manager (more complex)
make TARGET=server

# This creates binaries in:
# ~/wazuh/src/ (various executables)
```

#### 1.2 Install Pre-built Wazuh for Quick Start

While you're learning, install official packages alongside your source build:

```bash
# Install Wazuh repository
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee -a /etc/apt/sources.list.d/wazuh.list
sudo apt update

# Install manager components
sudo apt install -y wazuh-manager

# Install agent (on same or different machine)
sudo apt install -y wazuh-agent
```

#### 1.3 Docker Compose for Full Stack (Easiest Start)

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  wazuh-manager:
    image: wazuh/wazuh-manager:latest
    hostname: wazuh-manager
    ports:
      - "1514:1514"    # Agent communication
      - "1515:1515"    # Agent enrollment
      - "514:514/udp"  # Syslog
      - "55000:55000"  # API
    environment:
      - INDEXER_URL=https://wazuh-indexer:9200
      - INDEXER_USERNAME=admin
      - INDEXER_PASSWORD=SecretPassword
      - FILEBEAT_SSL_VERIFICATION_MODE=none
      - SSL_CERTIFICATE_AUTHORITIES=/etc/ssl/root-ca.pem
      - SSL_CERTIFICATE=/etc/ssl/filebeat.pem
      - SSL_KEY=/etc/ssl/filebeat.key
    volumes:
      - wazuh_api_configuration:/var/ossec/api/configuration
      - wazuh_etc:/var/ossec/etc
      - wazuh_logs:/var/ossec/logs
      - wazuh_queue:/var/ossec/queue
      - wazuh_var_multigroups:/var/ossec/var/multigroups
      - wazuh_integrations:/var/ossec/integrations
      - wazuh_active_response:/var/ossec/active-response/bin
      - wazuh_agentless:/var/ossec/agentless
      - wazuh_wodles:/var/ossec/wodles
      - ./src:/wazuh-src  # Mount your source code for development

  wazuh-indexer:
    image: wazuh/wazuh-indexer:latest
    hostname: wazuh-indexer
    ports:
      - "9200:9200"
    environment:
      - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m"
      - discovery.type=single-node
    volumes:
      - wazuh-indexer-data:/var/lib/wazuh-indexer

  wazuh-dashboard:
    image: wazuh/wazuh-dashboard:latest
    hostname: wazuh-dashboard
    ports:
      - "443:5601"
    environment:
      - INDEXER_USERNAME=admin
      - INDEXER_PASSWORD=SecretPassword
      - WAZUH_API_URL=https://wazuh-manager
      - API_USERNAME=wazuh-wui
      - API_PASSWORD=MyS3cr37P450r.*-
    depends_on:
      - wazuh-indexer
    volumes:
      - wazuh-dashboard-config:/usr/share/wazuh-dashboard/data/wazuh/config
      - wazuh-dashboard-custom:/usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom

volumes:
  wazuh_api_configuration:
  wazuh_etc:
  wazuh_logs:
  wazuh_queue:
  wazuh_var_multigroups:
  wazuh_integrations:
  wazuh_active_response:
  wazuh_agentless:
  wazuh_wodles:
  wazuh-indexer-data:
  wazuh-dashboard-config:
  wazuh-dashboard-custom:
```

Start the stack:
```bash
docker-compose up -d

# Access dashboard at https://localhost:443
# Username: admin
# Password: SecretPassword
```

---

### Phase 2: Agent Development Workflow (Days 2-7)

Since you're interested in **Agent/EDR**, here's the focused workflow:

#### 2.1 Set Up Agent Development Environment

```bash
# Build agent from source
cd ~/wazuh/src
make TARGET=agent

# Install to custom location for testing
sudo make TARGET=agent PREFIX=/opt/wazuh-dev install

# Or create a development script
cat > ~/run-dev-agent.sh << 'EOF'
#!/bin/bash
# Stop production agent if running
sudo systemctl stop wazuh-agent

# Run your development agent
sudo /opt/wazuh-dev/bin/wazuh-agentd \
    -c /opt/wazuh-dev/etc/ossec.conf \
    -f  # Foreground mode for debugging
EOF
chmod +x ~/run-dev-agent.sh
```

#### 2.2 Configure Development Agent

Edit `/opt/wazuh-dev/etc/ossec.conf`:

```xml
<ossec_config>
  <client>
    <server>
      <address>127.0.0.1</address>  <!-- Local manager -->
      <port>1514</port>
      <protocol>tcp</protocol>
    </server>
    <config-profile>ubuntu, ubuntu22, ubuntu22.04</config-profile>
    <notify_time>10</notify_time>
    <time-reconnect>60</time-reconnect>
    <auto_restart>yes</auto_restart>
    <crypto_method>aes</crypto_method>
  </client>

  <!-- FIM Configuration -->
  <syscheck>
    <disabled>no</disabled>
    <frequency>300</frequency>
    <directories check_all="yes" realtime="yes">/tmp/test-fim</directories>
    <directories check_all="yes" whodata="yes">/tmp/test-whodata</directories>
  </syscheck>

  <!-- Log Collection -->
  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/auth.log</location>
  </localfile>

  <!-- SCA -->
  <sca>
    <enabled>yes</enabled>
    <scan_on_start>yes</scan_on_start>
    <interval>12h</interval>
  </sca>

  <!-- Syscollector -->
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
</ossec_config>
```

#### 2.3 Development Loop

```bash
# 1. Make code changes
vim ~/wazuh/src/client-agent/agentd.c

# 2. Rebuild
cd ~/wazuh/src
make TARGET=agent

# 3. Install
sudo make TARGET=agent PREFIX=/opt/wazuh-dev install

# 4. Test
sudo /opt/wazuh-dev/bin/wazuh-agentd -c /opt/wazuh-dev/etc/ossec.conf -f

# 5. Debug with GDB
sudo gdb --args /opt/wazuh-dev/bin/wazuh-agentd -c /opt/wazuh-dev/etc/ossec.conf -f
```

#### 2.4 Add Logging for Debugging

Add debug logs to your code:

```c
// In any C file
#include "shared.h"

// Add debug logging
mdebug1("Agent buffer state: i=%d, j=%d, size=%d", i, j, buffer_size);
mdebug2("Processing message: %s", message);
minfo("Agent connected to manager successfully");
mwarn("Buffer reached WARNING level: %d%%", usage_percent);
merror("Failed to connect to manager: %s", strerror(errno));
```

Logs appear in:
- `/opt/wazuh-dev/logs/ossec.log` (main log)
- `/opt/wazuh-dev/logs/internal.log` (debug logs if `analysisd.debug` > 0)

Enable debug mode in `/opt/wazuh-dev/etc/local_internal_options.conf`:
```
# Debug level (0-2)
agent.debug=2
syscheck.debug=2
logcollector.debug=2
```

---

### Phase 3: Manager & Engine Development (Days 8-14)

#### 3.1 Build Manager Components

```bash
cd ~/wazuh/src

# Build all server components
make TARGET=server

# Individual components
make -C remoted    # Manager receiver
make -C analysisd  # Legacy analysis engine
make -C wazuh_db   # WazuhDB

# NEW: Build modern C++ engine
cd ~/wazuh/src/engine
mkdir build && cd build
cmake ..
make -j$(nproc)
```

#### 3.2 Run Manager in Development Mode

```bash
# Stop production manager
sudo systemctl stop wazuh-manager

# Run individual daemons for debugging
sudo /var/ossec/bin/wazuh-remoted -f  # Foreground
sudo /var/ossec/bin/wazuh-db -f
sudo /var/ossec/bin/wazuh-engine -f

# Or use wazuh-control
sudo /var/ossec/bin/wazuh-control start
sudo /var/ossec/bin/wazuh-control status
```

#### 3.3 Engine Development (C++)

The new engine is Protocol Buffers based:

```bash
cd ~/wazuh/src/engine

# Generate protobuf code
cd source/proto
./generate.sh

# Build with tests
cd ../build
cmake -DENGINE_BUILD_TEST=ON ..
make -j$(nproc)

# Run unit tests
ctest --output-on-failure

# Run engine
sudo ./bin/wazuh-engine --config /var/ossec/etc/wazuh-engine.yml
```

---

### Phase 4: Cloud Testing Environment (Optional but Recommended)

#### 4.1 AWS EC2 Setup (Cost-Effective)

**Architecture:**
```
┌─────────────────────────────────────────────────┐
│ AWS Account                                     │
│                                                  │
│  ┌──────────────────┐                           │
│  │ Wazuh Manager    │                           │
│  │ t3.medium        │ ← Central brain           │
│  │ Ubuntu 22.04     │                           │
│  │ $30/month        │                           │
│  └──────────────────┘                           │
│           ↑                                      │
│           │ Port 1514                            │
│           │                                      │
│  ┌────────┴─────────┬──────────┬──────────┐    │
│  │                  │          │          │    │
│  │ t3.micro        │ t3.micro │ t3.micro │    │
│  │ (Linux agent)   │ (Win)    │ (CentOS) │    │
│  │ $4/mo           │ $4/mo    │ $4/mo    │    │
│  └──────────────────┴──────────┴──────────┘    │
│                                                  │
│  Use spot instances for 70% cost savings!       │
└─────────────────────────────────────────────────┘
```

**Terraform Setup:**

Create `terraform/main.tf`:

```hcl
provider "aws" {
  region = "us-east-1"
}

# Security group
resource "aws_security_group" "wazuh" {
  name        = "wazuh-lab"
  description = "Wazuh development lab"

  # Agent communication
  ingress {
    from_port   = 1514
    to_port     = 1515
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # API
  ingress {
    from_port   = 55000
    to_port     = 55000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Dashboard
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]  # Restrict to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Wazuh Manager
resource "aws_instance" "wazuh_manager" {
  ami           = "ami-0c55b159cbfafe1f0"  # Ubuntu 22.04
  instance_type = "t3.medium"
  key_name      = aws_key_pair.wazuh.key_name

  vpc_security_group_ids = [aws_security_group.wazuh.id]

  root_block_device {
    volume_size = 50
  }

  tags = {
    Name = "wazuh-manager-dev"
  }

  user_data = <<-EOF
              #!/bin/bash
              curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
              echo "deb https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list
              apt update
              apt install -y wazuh-manager wazuh-indexer wazuh-dashboard
              systemctl enable wazuh-manager wazuh-indexer wazuh-dashboard
              systemctl start wazuh-manager wazuh-indexer wazuh-dashboard
              EOF
}

# Linux Agent
resource "aws_instance" "linux_agent" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.wazuh.key_name

  vpc_security_group_ids = [aws_security_group.wazuh.id]

  tags = {
    Name = "wazuh-linux-agent"
  }

  user_data = <<-EOF
              #!/bin/bash
              curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
              echo "deb https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list
              apt update
              apt install -y wazuh-agent
              EOF
}

output "manager_ip" {
  value = aws_instance.wazuh_manager.public_ip
}

output "agent_ip" {
  value = aws_instance.linux_agent.public_ip
}
```

Deploy:
```bash
cd terraform
terraform init
terraform plan
terraform apply

# Destroy when done to save money
terraform destroy
```

#### 4.2 Cost Optimization

**Spot Instances (70% cheaper):**
```hcl
resource "aws_instance" "wazuh_manager" {
  # ... other config ...

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.05"  # Set max hourly price
    }
  }
}
```

**Auto-shutdown at night:**
```bash
# Add to manager crontab
0 22 * * * sudo shutdown -h now  # Shutdown at 10 PM
# Use AWS Lambda to start in morning
```

**Monthly Cost Estimate:**
- Manager (t3.medium spot): ~$10/month
- 3 Agents (t3.micro spot): ~$3/month
- Storage (50GB): ~$5/month
- **Total: ~$18/month**

---

### Phase 5: Multi-Platform Testing

#### 5.1 Vagrant for Local Multi-OS Testing

Create `Vagrantfile`:

```ruby
Vagrant.configure("2") do |config|
  # Ubuntu Agent
  config.vm.define "ubuntu_agent" do |ubuntu|
    ubuntu.vm.box = "ubuntu/jammy64"
    ubuntu.vm.hostname = "ubuntu-agent"
    ubuntu.vm.network "private_network", ip: "192.168.56.101"
    ubuntu.vm.provision "shell", inline: <<-SHELL
      curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
      echo "deb https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list
      apt update && apt install -y wazuh-agent
    SHELL
  end

  # CentOS Agent
  config.vm.define "centos_agent" do |centos|
    centos.vm.box = "centos/8"
    centos.vm.hostname = "centos-agent"
    centos.vm.network "private_network", ip: "192.168.56.102"
    centos.vm.provision "shell", inline: <<-SHELL
      rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH
      cat > /etc/yum.repos.d/wazuh.repo << EOF
[wazuh]
gpgcheck=1
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
enabled=1
name=EL-\$releasever - Wazuh
baseurl=https://packages.wazuh.com/4.x/yum/
protect=1
EOF
      yum install -y wazuh-agent
    SHELL
  end

  # Windows Agent (requires Windows box)
  config.vm.define "windows_agent" do |windows|
    windows.vm.box = "gusztavvargadr/windows-10"
    windows.vm.hostname = "windows-agent"
    windows.vm.network "private_network", ip: "192.168.56.103"
    windows.vm.provision "shell", inline: <<-SHELL
      Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.7.0-1.msi -OutFile wazuh-agent.msi
      Start-Process msiexec.exe -ArgumentList '/i wazuh-agent.msi /q WAZUH_MANAGER="192.168.56.1"' -Wait
    SHELL
  end
end
```

Start VMs:
```bash
vagrant up ubuntu_agent
vagrant up centos_agent
# vagrant up windows_agent  # Only if you have a Windows license
```

---

## Development Workflow

### Typical Day of Agent Development

```bash
# Morning: Pull latest changes
cd ~/wazuh
git pull origin master
git merge master  # into your feature branch

# Review what you're working on
# Example: Adding new FIM attribute tracking

# 1. Find the relevant code
cd src/syscheckd/src
grep -r "fim_file" .

# 2. Make changes
vim src/syscheckd/src/syscheck.c

# 3. Add unit test
vim src/syscheckd/tests/test_syscheck.c

# 4. Build
cd ~/wazuh/src
make TARGET=agent

# 5. Run unit tests
cd tests
make test-syscheckd

# 6. Install to dev environment
sudo make TARGET=agent PREFIX=/opt/wazuh-dev install

# 7. Test manually
sudo /opt/wazuh-dev/bin/wazuh-agentd -f -c /opt/wazuh-dev/etc/ossec.conf

# Trigger FIM event
mkdir /tmp/test-fim
touch /tmp/test-fim/testfile

# Watch logs
tail -f /opt/wazuh-dev/logs/ossec.log

# 8. Debug if needed
sudo gdb --args /opt/wazuh-dev/bin/wazuh-agentd -f -c /opt/wazuh-dev/etc/ossec.conf
(gdb) break syscheck.c:123
(gdb) run
(gdb) backtrace

# 9. Clean build if needed
make clean
make TARGET=agent

# 10. Commit
git add src/syscheckd/
git commit -m "feat: Add extended attribute tracking to FIM"
git push origin your-feature-branch
```

---

## Testing Scenarios

### Scenario 1: Test FIM Module

```bash
# Configure FIM
cat >> /opt/wazuh-dev/etc/ossec.conf << EOF
<syscheck>
  <directories check_all="yes" realtime="yes" report_changes="yes">/tmp/fim-test</directories>
</syscheck>
EOF

# Create test directory
mkdir /tmp/fim-test

# Restart agent
sudo systemctl restart wazuh-agent

# Generate events
echo "test" > /tmp/fim-test/file1.txt
chmod 777 /tmp/fim-test/file1.txt
rm /tmp/fim-test/file1.txt

# Check alerts
sudo cat /var/ossec/logs/alerts/alerts.log | grep fim-test
```

### Scenario 2: Test Buffer Anti-Flooding

```bash
# Generate massive events
for i in {1..10000}; do
  echo "test" > /tmp/fim-test/file$i.txt
done

# Watch buffer state
tail -f /var/ossec/logs/ossec.log | grep -i "buffer\|flood"

# Expected: Agent should enter WARNING → FULL → FLOOD states
# and send alerts to manager
```

### Scenario 3: Test Manager Disconnection Resilience

```bash
# Stop manager
sudo systemctl stop wazuh-manager

# Generate events on agent
for i in {1..100}; do
  echo "Event during outage $i" >> /var/log/syslog
  sleep 1
done

# Check agent buffer
sudo grep -i "buffer" /var/ossec/logs/ossec.log

# Restart manager
sudo systemctl start wazuh-manager

# Agent should reconnect and replay buffered events
```

### Scenario 4: Test Cross-Platform (Vagrant)

```bash
# Start all agents
vagrant up

# SSH to each and check agent status
vagrant ssh ubuntu_agent -c "sudo systemctl status wazuh-agent"
vagrant ssh centos_agent -c "sudo systemctl status wazuh-agent"

# Check manager sees all agents
sudo /var/ossec/bin/agent_control -l
```

---

## Common Contributor Workflows

### Workflow 1: Fix a Bug

```bash
# 1. Find the issue in GitHub
# Example: Issue #12345 - "Agent crashes on large files"

# 2. Create branch
git checkout -b fix/12345-agent-crash-large-files

# 3. Reproduce locally
# (Setup test case that triggers the crash)

# 4. Debug
sudo gdb --args /var/ossec/bin/wazuh-agentd -f
(gdb) run
# ... crash occurs ...
(gdb) backtrace

# 5. Fix the code
vim src/syscheckd/src/run_check.c

# 6. Test fix
make TARGET=agent && sudo make install
# ... verify crash is gone ...

# 7. Add regression test
vim src/tests/test_syscheck.c

# 8. Commit
git commit -m "fix: Prevent crash on files larger than 2GB (#12345)"

# 9. Push and create PR
git push origin fix/12345-agent-crash-large-files
# Create PR on GitHub
```

### Workflow 2: Add New Feature

```bash
# Example: Add support for tracking file SELinux context

# 1. Design
# - Modify fim_file structure to include selinux_context
# - Add function to read SELinux context
# - Update JSON output format

# 2. Implement
vim src/syscheckd/include/syscheck.h  # Add field
vim src/syscheckd/src/syscheck.c      # Implement logic

# 3. Test
make TARGET=agent && sudo make install
# Test on SELinux-enabled system (Fedora, CentOS)

# 4. Document
vim CHANGELOG.md
vim docs/user-manual/capabilities/file-integrity/advanced.rst

# 5. Submit PR
```

### Workflow 3: Performance Optimization

```bash
# Example: Optimize FIM database queries

# 1. Benchmark current performance
time sudo /var/ossec/bin/wazuh-agentd -t  # Test mode

# 2. Profile with perf
sudo perf record -g /var/ossec/bin/wazuh-agentd -t
sudo perf report

# 3. Identify bottleneck
# (e.g., slow SQL queries in syscheck_db.c)

# 4. Optimize
vim src/syscheckd/src/db/syscheck_db.c
# Add index, optimize query

# 5. Re-benchmark
time sudo /var/ossec/bin/wazuh-agentd -t

# 6. Commit with performance metrics
git commit -m "perf: Optimize FIM DB queries (30% faster)"
```

---

## Cost Analysis

### Option 1: Fully Local
- **Cost**: $0/month (hardware you already have)
- **Time to setup**: 1-2 days
- **Limitations**: Single-platform, limited scalability testing

### Option 2: Docker Compose (Local)
- **Cost**: $0/month
- **Time to setup**: 1 hour
- **Limitations**: All containers on same host

### Option 3: AWS Minimal (Hybrid)
- **Manager**: t3.medium spot (~$10/mo)
- **2 Linux agents**: t3.micro spot (~$2/mo each)
- **Storage**: 50GB (~$5/mo)
- **Total**: ~$19/month
- **Time to setup**: 2-3 hours

### Option 4: AWS Full Development
- **Manager**: t3.large spot (~$20/mo)
- **5 agents** (Linux, Windows, CentOS): (~$20/mo)
- **RDS for testing**: (~$15/mo)
- **Total**: ~$55/month
- **Time to setup**: 1 day

### Recommendation
**Start with Option 2 (Docker Compose) for learning**, then move to **Option 3 (AWS Minimal) when you need multi-platform testing**.

---

## How Other Contributors Work

Based on analyzing the Wazuh contribution patterns:

### Common Setup
1. **Local development**: Ubuntu 22.04 or macOS
2. **IDE**: VS Code with C/C++ extensions, or Vim/Neovim
3. **Testing**: Docker Compose for quick tests, AWS/GCP for integration
4. **CI/CD**: GitHub Actions (automatic on PR)

### Development Cycle
1. **Issue selection**: Pick from GitHub issues labeled "good first issue"
2. **Local implementation**: Make changes, unit test
3. **Docker testing**: Test with `docker-compose up`
4. **Cloud integration**: Deploy to AWS/GCP for multi-agent testing
5. **PR submission**: Create PR, wait for CI/CD green checks
6. **Code review**: Address reviewer feedback
7. **Merge**: Maintainers merge after approval

### Communication Channels
- **GitHub Issues**: Bug reports, feature requests
- **GitHub Discussions**: Q&A, design discussions
- **Slack**: Real-time chat (join via wazuh.com)
- **Mailing List**: Long-form technical discussions

---

## Troubleshooting

### Issue: Build Fails

```bash
# Clean build
make clean
rm -rf build/

# Install missing dependencies
sudo apt install -y $(cat src/Makefile | grep "apt install" | cut -d' ' -f4-)

# Retry
make TARGET=agent
```

### Issue: Agent Won't Connect to Manager

```bash
# Check network connectivity
telnet MANAGER_IP 1514

# Check agent keys
sudo cat /var/ossec/etc/client.keys

# Check manager keys
sudo cat /var/ossec/etc/client.keys  # On manager

# Re-register agent
sudo /var/ossec/bin/agent-auth -m MANAGER_IP

# Restart
sudo systemctl restart wazuh-agent
```

### Issue: No Events Appearing

```bash
# Check agent logs
sudo tail -f /var/ossec/logs/ossec.log

# Check manager logs
sudo tail -f /var/ossec/logs/ossec.log  # On manager

# Verify FIM directories exist
ls -la /tmp/test-fim

# Test event generation
echo "test" >> /var/log/syslog

# Check logcollector is running
sudo ps aux | grep logcollector
```

### Issue: High Memory Usage

```bash
# Check buffer size
sudo grep -i "buffer" /var/ossec/etc/internal_options.conf

# Reduce buffer
echo "agent.buffer_capacity=1000" >> /var/ossec/etc/local_internal_options.conf

# Restart
sudo systemctl restart wazuh-agent
```

---

## Next Steps for Learning

### Week 1-2: Understand the Basics
- [ ] Setup local Docker Compose environment
- [ ] Install agent and manager from packages
- [ ] Trigger FIM, logcollector, syscollector events
- [ ] Read logs, understand event flow
- [ ] Browse `/var/ossec/etc/ossec.conf`

### Week 3-4: Compile from Source
- [ ] Build agent from source
- [ ] Build manager from source
- [ ] Replace production binaries with dev versions
- [ ] Make trivial code change (add debug log)
- [ ] Rebuild and test

### Month 2: Deep Dive into Agent
- [ ] Read `src/client-agent/agentd.c` line by line
- [ ] Understand buffer system (`buffer.c`)
- [ ] Study FIM module (`src/syscheckd/`)
- [ ] Trace message flow: Module → MQ → Agent → Manager
- [ ] Add instrumentation logging throughout

### Month 3: Contribute
- [ ] Find "good first issue" on GitHub
- [ ] Implement fix or feature
- [ ] Write tests
- [ ] Submit PR
- [ ] Address code review feedback

### Month 4+: Advanced Topics
- [ ] Study new C++ engine (`src/engine/`)
- [ ] Understand Protocol Buffers
- [ ] Implement rule/decoder
- [ ] Performance optimization
- [ ] Cross-platform compatibility (Windows)

---

## Conclusion

**Recommended Starting Point:**

1. **Day 1**: Setup Docker Compose locally (1 hour)
2. **Days 2-3**: Compile agent from source, replace Docker agent with your build
3. **Week 1**: Understand event flow by adding debug logs everywhere
4. **Week 2**: Make small code change (e.g., add new FIM attribute)
5. **Week 3**: Setup AWS minimal environment for multi-platform testing
6. **Week 4**: Submit first PR for a simple bug fix

**You do NOT need expensive hardware or cloud resources to start.** Docker Compose on your laptop is enough for 90% of development work. Only when you need to test distributed scenarios (100+ agents, clustering, cross-platform) should you spin up cloud resources.

**Most important**: Start coding! The Wazuh codebase is well-structured and the community is welcoming. Pick a module (recommend starting with agent/FIM), read the code, make changes, and test locally.

Good luck with your Wazuh journey! 🚀
