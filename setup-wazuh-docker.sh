#!/bin/bash
set -e

echo "=================================="
echo "Wazuh Docker Setup Script"
echo "=================================="
echo ""
echo "This script will:"
echo "1. Create necessary directory structure"
echo "2. Generate SSL certificates"
echo "3. Create configuration files"
echo ""

# Create directory structure
echo "[1/4] Creating directory structure..."
mkdir -p config/wazuh_indexer_ssl_certs
mkdir -p config/wazuh_indexer
mkdir -p config/wazuh_dashboard
mkdir -p config/wazuh_cluster

echo "✓ Directories created"

# Generate SSL Certificates
echo ""
echo "[2/4] Generating SSL certificates..."
cd config/wazuh_indexer_ssl_certs

echo "  → Generating Root CA..."
openssl req -x509 -newkey rsa:2048 -keyout root-ca-key.pem -out root-ca.pem -days 365 -nodes \
  -subj "/C=US/ST=CA/L=San Jose/O=Wazuh/CN=root-ca" 2>/dev/null

echo "  → Generating Manager certificate..."
openssl req -newkey rsa:2048 -keyout wazuh.manager-key.pem -out wazuh.manager.csr -nodes \
  -subj "/C=US/ST=CA/L=San Jose/O=Wazuh/CN=wazuh.manager" 2>/dev/null
openssl x509 -req -in wazuh.manager.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial \
  -out wazuh.manager.pem -days 365 2>/dev/null

echo "  → Generating Indexer certificate..."
openssl req -newkey rsa:2048 -keyout wazuh.indexer-key.pem -out wazuh.indexer.csr -nodes \
  -subj "/C=US/ST=CA/L=San Jose/O=Wazuh/CN=wazuh.indexer" 2>/dev/null
openssl x509 -req -in wazuh.indexer.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial \
  -out wazuh.indexer.pem -days 365 2>/dev/null

echo "  → Generating Dashboard certificate..."
openssl req -newkey rsa:2048 -keyout wazuh.dashboard-key.pem -out wazuh.dashboard.csr -nodes \
  -subj "/C=US/ST=CA/L=San Jose/O=Wazuh/CN=wazuh.dashboard" 2>/dev/null
openssl x509 -req -in wazuh.dashboard.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial \
  -out wazuh.dashboard.pem -days 365 2>/dev/null

echo "  → Generating Admin certificate..."
openssl req -newkey rsa:2048 -keyout admin-key.pem -out admin.csr -nodes \
  -subj "/C=US/ST=CA/L=San Jose/O=Wazuh/CN=admin" 2>/dev/null
openssl x509 -req -in admin.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial \
  -out admin.pem -days 365 2>/dev/null

# Copy root CA for manager
cp root-ca.pem root-ca-manager.pem

# Clean up CSR files
rm -f *.csr *.srl

cd ../..

echo "✓ SSL certificates generated"

# Create wazuh_indexer/wazuh.indexer.yml
echo ""
echo "[3/4] Creating configuration files..."

cat > config/wazuh_indexer/wazuh.indexer.yml << 'EOF'
network.host: "0.0.0.0"
node.name: "wazuh.indexer"
cluster.name: "wazuh-cluster"
cluster.initial_master_nodes:
  - "wazuh.indexer"
plugins.security.ssl.http.pemcert_filepath: /usr/share/wazuh-indexer/certs/wazuh.indexer.pem
plugins.security.ssl.http.pemkey_filepath: /usr/share/wazuh-indexer/certs/wazuh.indexer-key.pem
plugins.security.ssl.http.pemtrustedcas_filepath: /usr/share/wazuh-indexer/certs/root-ca.pem
plugins.security.ssl.transport.pemcert_filepath: /usr/share/wazuh-indexer/certs/wazuh.indexer.pem
plugins.security.ssl.transport.pemkey_filepath: /usr/share/wazuh-indexer/certs/wazuh.indexer-key.pem
plugins.security.ssl.transport.pemtrustedcas_filepath: /usr/share/wazuh-indexer/certs/root-ca.pem
plugins.security.ssl.http.enabled: true
plugins.security.ssl.transport.enforce_hostname_verification: false
plugins.security.ssl.transport.resolve_hostname: false
plugins.security.authcz.admin_dn:
  - "CN=admin,O=Wazuh,L=San Jose,ST=CA,C=US"
plugins.security.check_snapshot_restore_write_privileges: true
plugins.security.enable_snapshot_restore_privilege: true
plugins.security.nodes_dn:
  - "CN=wazuh.indexer,O=Wazuh,L=San Jose,ST=CA,C=US"
plugins.security.restapi.roles_enabled:
  - "all_access"
  - "security_rest_api_access"
plugins.security.allow_default_init_securityindex: true
EOF

# Create internal_users.yml
cat > config/wazuh_indexer/internal_users.yml << 'EOF'
---
_meta:
  type: "internalusers"
  config_version: 2

admin:
  hash: "$2y$12$K/SpwjtB.wOHJ/Nc6GVRDuc1h0rM1DfvziFRNPtk27P.c4yDr9njO"
  reserved: true
  backend_roles:
  - "admin"
  description: "Admin user"

kibanaserver:
  hash: "$2a$12$4AcgAt3xwOWadA5s5blL6ev39OXDNhmOesEoo33eZtrq2N0YrU3H."
  reserved: true
  description: "Kibanaserver user"
EOF

# Create opensearch_dashboards.yml
cat > config/wazuh_dashboard/opensearch_dashboards.yml << 'EOF'
server.host: "0.0.0.0"
server.port: 5601
opensearch.hosts: ["https://wazuh.indexer:9200"]
opensearch.ssl.verificationMode: certificate
opensearch.username: "kibanaserver"
opensearch.password: "kibanaserver"
opensearch.requestHeadersWhitelist: ["securitytenant","Authorization"]
opensearch_security.multitenancy.enabled: false
opensearch_security.readonly_mode.roles: ["kibana_read_only"]
server.ssl.enabled: true
server.ssl.key: "/usr/share/wazuh-dashboard/certs/wazuh-dashboard-key.pem"
server.ssl.certificate: "/usr/share/wazuh-dashboard/certs/wazuh-dashboard.pem"
opensearch.ssl.certificateAuthorities: ["/usr/share/wazuh-dashboard/certs/root-ca.pem"]
uiSettings.overrides.defaultRoute: "/app/wazuh"
opensearch_security.cookie.secure: true
EOF

# Create wazuh.yml for dashboard
cat > config/wazuh_dashboard/wazuh.yml << 'EOF'
hosts:
  - production:
      url: https://wazuh.manager
      port: 55000
      username: wazuh-wui
      password: "MyS3cr37P450r.*-"
      run_as: false
EOF

# Create wazuh_manager.conf
cat > config/wazuh_cluster/wazuh_manager.conf << 'EOF'
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
  </global>

  <alerts>
    <log_alert_level>3</log_alert_level>
  </alerts>

  <!-- Remote agent registration -->
  <auth>
    <disabled>no</disabled>
    <port>1515</port>
    <use_source_ip>no</use_source_ip>
    <purge>yes</purge>
    <use_password>no</use_password>
    <ssl_verify_host>no</ssl_verify_host>
    <ssl_auto_negotiate>no</ssl_auto_negotiate>
  </auth>

  <remote>
    <connection>secure</connection>
    <port>1514</port>
    <protocol>tcp</protocol>
    <queue_size>131072</queue_size>
  </remote>

  <!-- File integrity monitoring -->
  <syscheck>
    <disabled>no</disabled>
    <frequency>43200</frequency>
    <scan_on_start>yes</scan_on_start>
    <directories>/etc,/usr/bin,/usr/sbin</directories>
    <directories>/bin,/sbin,/boot</directories>
  </syscheck>

  <!-- Rootcheck -->
  <rootcheck>
    <disabled>no</disabled>
    <frequency>43200</frequency>
  </rootcheck>

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

    <provider name="canonical">
      <enabled>yes</enabled>
      <os>trusty</os>
      <os>xenial</os>
      <os>bionic</os>
      <os>focal</os>
      <os>jammy</os>
      <update_interval>1h</update_interval>
    </provider>
  </vulnerability-detector>

  <!-- Security Configuration Assessment -->
  <sca>
    <enabled>yes</enabled>
    <scan_on_start>yes</scan_on_start>
    <interval>12h</interval>
    <skip_nfs>yes</skip_nfs>
  </sca>
</ossec_config>
EOF

echo "✓ Configuration files created"

echo ""
echo "[4/4] Setting permissions..."
chmod 600 config/wazuh_indexer_ssl_certs/*.pem
chmod 644 config/wazuh_indexer_ssl_certs/root-ca.pem config/wazuh_indexer_ssl_certs/root-ca-manager.pem
chmod 644 config/wazuh_indexer_ssl_certs/*.pem | grep -v key
echo "✓ Permissions set"

echo ""
echo "=================================="
echo "✓ Setup Complete!"
echo "=================================="
echo ""
echo "Next steps:"
echo "1. Start the stack:"
echo "   docker-compose -f docker-compose-working.yml up -d"
echo ""
echo "2. Check status:"
echo "   docker-compose -f docker-compose-working.yml ps"
echo ""
echo "3. Access dashboard:"
echo "   https://localhost (or https://localhost:443)"
echo "   Username: admin"
echo "   Password: SecretPassword"
echo ""
echo "4. View logs:"
echo "   docker-compose -f docker-compose-working.yml logs -f"
echo ""
