# Wazuh Commercial Licensing & Legal Guide
## Complete Analysis for Enterprise Rebranding and Commercial Distribution

**Document Version**: 1.0
**Date**: 2024
**Purpose**: Legal analysis for creating commercial enterprise product based on Wazuh
**Target Audience**: Business owners planning to rebrand and sell Wazuh-based solutions

---

## ⚠️ CRITICAL LEGAL DISCLAIMER

**THIS DOCUMENT IS FOR INFORMATIONAL PURPOSES ONLY AND DOES NOT CONSTITUTE LEGAL ADVICE.**

- Consult a qualified intellectual property attorney before proceeding
- Laws vary by jurisdiction
- This analysis is based on Wazuh codebase as of 2024
- Your specific use case may have unique legal considerations

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Wazuh Licensing Structure](#wazuh-licensing-structure)
3. [Can You Rebrand and Sell Wazuh?](#can-you-rebrand-and-sell-wazuh)
4. [Your Legal Obligations](#your-legal-obligations)
5. [Proprietary Code Integration](#proprietary-code-integration)
6. [Business Models That Work](#business-models-that-work)
7. [Business Models That DON'T Work](#business-models-that-dont-work)
8. [Trademark Considerations](#trademark-considerations)
9. [Step-by-Step Compliance Checklist](#step-by-step-compliance-checklist)
10. [Real-World Examples](#real-world-examples)
11. [Risk Assessment](#risk-assessment)
12. [Legal Enforcement History](#legal-enforcement-history)
13. [Recommended Business Structure](#recommended-business-structure)
14. [FAQ](#faq)

---

## Executive Summary

### Quick Answers to Your Questions

**Q1: Can I rebrand Wazuh and sell it under my brand name?**
✅ **YES**, but with significant restrictions (source code must remain open)

**Q2: Do I need to develop from scratch?**
❌ **NO**, you can use Wazuh as-is or modified

**Q3: Can I keep my proprietary code closed source?**
⚠️ **PARTIALLY** - Only if properly separated (see Architecture Patterns section)

**Q4: Can I make money?**
✅ **YES** - GPL/AGPL allow commercial use and charging fees

**Q5: Will I be forced to release my source code?**
⚠️ **DEPENDS** - Only code that links/integrates with Wazuh

### The Bottom Line

**You CAN create a commercial enterprise product using Wazuh, BUT:**

1. ✅ You can charge money for support, services, hosting
2. ✅ You can rebrand (rename, change logos)
3. ✅ You can add proprietary features (with correct architecture)
4. ❌ You CANNOT close-source Wazuh code itself
5. ❌ You CANNOT prevent customers from redistributing your product
6. ❌ You CANNOT use "Wazuh" trademark without permission

---

## Wazuh Licensing Structure

### Dual License Model

Wazuh uses **TWO different licenses** in the same codebase:

#### 1. GNU General Public License v2 (GPLv2)
**Applies to**: Core Wazuh components (agent, manager, most modules)

**Location**: `/home/user/wazuh/LICENSE`

**Key Points**:
```
- Copyright (C) 2015-2024, Wazuh Inc.
- Based on OSSEC (Trend Micro, GPLv2)
- Covers: Agent, Manager, Remoted, Logcollector, FIM, etc.
```

**What GPLv2 Allows**:
- ✅ Commercial use
- ✅ Modification
- ✅ Distribution
- ✅ Private use
- ✅ Patent use (implied)

**What GPLv2 Requires**:
- ⚠️ License and copyright notice
- ⚠️ State changes
- ⚠️ Disclose source code
- ⚠️ Same license (copyleft)

#### 2. GNU Affero General Public License v3 (AGPLv3)
**Applies to**: New Analysis Engine (C++)

**Location**: `/home/user/wazuh/src/engine/LICENSE-engine`

**Key Points**:
```
- Copyright (C) 2023, Wazuh Inc.
- Covers: src/engine/ directory
- Modern C++ architecture
```

**Critical AGPL Difference**:
```
AGPLv3 Section 13 (NETWORK USE = DISTRIBUTION):

"If you modify the Program, your modified version must prominently
offer all users interacting with it remotely through a computer
network an opportunity to receive the Corresponding Source"
```

**This means**: If you run a modified Wazuh Engine as a SaaS/cloud service, you MUST provide source code to **all users** who interact with it over the network.

---

## Can You Rebrand and Sell Wazuh?

### ✅ What You CAN Do (100% Legal)

#### 1. **Rebrand and Sell**
```
✅ Change product name: "Wazuh" → "YourBrand Security Platform"
✅ Replace all logos, branding, UI elements
✅ Charge money for the software
✅ Sell support contracts
✅ Sell consulting services
✅ Sell training
✅ Sell managed services
✅ Bundle with proprietary tools
```

**Example**:
```
Product: "SecureOps XDR Platform"
Price: $50,000/year enterprise license
Includes: Software + Support + Consulting
Based on: Wazuh (must disclose)
```

#### 2. **Modify the Code**
```
✅ Add new features
✅ Remove unwanted features
✅ Change default configurations
✅ Optimize performance
✅ Fix bugs
✅ Add integrations
```

#### 3. **Commercial Distribution**
```
✅ Sell to enterprise customers
✅ Create installer packages
✅ Distribute binaries
✅ Host on your servers
✅ Provide as SaaS (with AGPL compliance)
```

### ❌ What You CANNOT Do (Illegal/License Violation)

#### 1. **Close Source Wazuh Code**
```
❌ Distribute Wazuh binaries without source code
❌ Make Wazuh code proprietary
❌ Remove GPL/AGPL license
❌ Prevent customers from viewing source
❌ Add restrictive EULAs that contradict GPL
```

**Example of Violation**:
```
"You may not reverse engineer this software"
→ ILLEGAL: GPL explicitly allows this

"You may not redistribute this software"
→ ILLEGAL: GPL grants redistribution rights

"Source code is proprietary"
→ ILLEGAL: GPL requires source disclosure
```

#### 2. **Use Wazuh Trademark**
```
❌ Call your product "Wazuh Enterprise Edition"
❌ Use Wazuh logo without permission
❌ Imply official Wazuh endorsement
❌ Domain names: wazuh-enterprise.com, etc.
```

**Legal Risk**: Trademark infringement lawsuit from Wazuh Inc.

#### 3. **Prevent Customer Rights**
```
❌ Prevent customers from redistributing
❌ Prevent customers from modifying
❌ Prevent customers from viewing source
❌ Require NDAs for Wazuh code
❌ Claim ownership of Wazuh code
```

---

## Your Legal Obligations

### Mandatory Compliance Requirements

#### 1. **Source Code Disclosure** (GPLv2 Section 3)

**You MUST provide source code to anyone you give binaries to.**

**Three Options**:

**Option A: Bundle Source with Binary**
```
Distribution Package:
├── yourproduct-installer.exe (binary)
├── yourproduct-source.tar.gz (complete source)
└── LICENSE (GPL/AGPL text)
```

**Option B: Written Offer**
```
Include with product:

"The source code for this software is available upon
request. Contact support@yourcompany.com to receive
a complete copy of the source code for a fee not
exceeding our cost of distribution."

Valid for: 3 years
Fee: Cannot exceed actual cost (USB drive, shipping)
```

**Option C: Network Download**
```
Provide URL in documentation:
"Source code: https://yourcompany.com/downloads/source"

Requirements:
- Must be publicly accessible
- No registration required
- No fee for download
- Same version as distributed binary
- Complete build instructions included
```

#### 2. **License and Copyright Notice** (GPLv2 Section 1)

**You MUST include**:

```
yourproduct/LICENSE:
---
[Your Company Name] Security Platform
Copyright (C) 2024 [Your Company]

This product incorporates Wazuh, which is:
Copyright (C) 2015-2024 Wazuh Inc.

This program is free software; you can redistribute it
and/or modify it under the terms of the GNU General
Public License (version 2) as published by the Free
Software Foundation.

[Full GPLv2 text]
[Full AGPLv3 text for engine]
```

**In Product UI**:
```
Settings → About → License Information

"This product is based on Wazuh (https://wazuh.com)
Licensed under GPLv2 and AGPLv3
Source code: https://yourcompany.com/source"
```

#### 3. **State Changes** (GPLv2 Section 2a)

**You MUST document modifications**:

```
Modified Files (add to each file header):
---
/* Original file: wazuh/src/client-agent/agentd.c
 * Modified by: YourCompany, 2024
 * Changes: Added custom authentication module
 */
```

**Create CHANGES.txt**:
```
Modifications to Wazuh:
- Added proprietary authentication module (see auth/)
- Modified FIM to support custom attributes
- Removed Rootcheck module
- Updated UI branding
```

#### 4. **AGPL Network Compliance** (AGPLv3 Section 13)

**If you offer Wazuh Engine as SaaS/Cloud**:

```
REQUIREMENT: Provide source download link in the web UI

Example Implementation:
---
Dashboard Footer:
"Download Source Code" → https://yourcompany.com/source

OR

API Endpoint:
GET /api/source-code → Returns download link
```

**This applies even if**:
- You only modify 1 line
- You run it internally (if users access remotely)
- You charge for the service

---

## Proprietary Code Integration

### 🔴 CRITICAL: The "Derivative Work" Problem

**GPL Definition of Derivative Work** (from LICENSE lines 24-31):
```
A work is considered "derivative" if it:
• Integrates source code/data files from Wazuh
• Includes Wazuh copyrighted material
• Links to a library or executes a program that does any of the above
```

**What this means**:
- If your code **links** to Wazuh → Must be GPL
- If your code **calls** Wazuh functions → Must be GPL
- If your code is **distributed with** Wazuh → Depends on coupling

### ✅ Safe Proprietary Integration Patterns

#### Pattern 1: Plugin via IPC (SAFEST)

```
Architecture:
┌─────────────────────┐
│ Wazuh Core (GPLv2) │ ← GPL code
└──────────┬──────────┘
           │ Unix Socket / TCP / HTTP API
           │ (Process boundary)
┌──────────▼──────────┐
│ Your Plugin        │ ← Can be proprietary!
│ (Separate process) │
└────────────────────┘

Communication: REST API, JSON-RPC, Protocol Buffers
License: Your plugin can be closed-source
```

**Example**:
```python
# proprietary_plugin.py (YOUR CLOSED SOURCE CODE)
# This is a SEPARATE PROCESS, not linked to Wazuh

import requests

def send_alert_to_proprietary_siem(alert):
    # Your proprietary logic
    secret_algorithm = your_proprietary_function(alert)

    # Send via network to external service
    requests.post("https://your-siem.com/api", json=secret_algorithm)

# Listen to Wazuh via API
while True:
    alerts = requests.get("http://wazuh-manager:55000/alerts")
    for alert in alerts:
        send_alert_to_proprietary_siem(alert)
```

**Why this works**:
- Separate process = not a derivative work
- Communication via standard protocols (HTTP, TCP)
- No linking to Wazuh libraries
- FSF confirms this is acceptable

#### Pattern 2: Aggregate Distribution

```
Product Bundle:
├── wazuh/ (GPLv2) ← Source code provided
├── your-proprietary-tool/ (Closed) ← Your code
└── installer.sh ← Installs both

LICENSE.txt:
---
This package contains:
1. Wazuh (GPLv2) - see wazuh/LICENSE
2. YourProduct (Proprietary) - see EULA.txt

These are separate, independent works.
```

**GPL Section 2, paragraph 7**:
```
"mere aggregation of another work not based on the
Program with the Program on a volume of a storage or
distribution medium does not bring the other work
under the scope of this License"
```

**Requirements**:
- ✅ Separate directories
- ✅ Separate licensing
- ✅ Can be used independently
- ✅ No source code integration

#### Pattern 3: Client-Server Architecture

```
┌──────────────────────┐
│ Wazuh Server (GPL)  │ ← Open source
│ (Backend)           │
└──────────┬───────────┘
           │ HTTPS API
┌──────────▼───────────┐
│ Your Web UI         │ ← Can be proprietary!
│ (Separate codebase) │
└─────────────────────┘

Technology: React, Angular, Vue (your choice)
License: Your choice (even closed source)
```

**Why this works**:
- Web UI is a separate program
- Communicates via public API
- Not a derivative work

### ❌ Unsafe Patterns (FORCES GPL)

#### Pattern A: Direct Linking (REQUIRES GPL)

```c
// your_agent.c - MUST BE GPL!

#include "wazuh/headers/shared.h"  // ← GPL header
#include "wazuh/agentd.h"          // ← GPL header

int main() {
    // Calling Wazuh functions directly
    init_agent();  // ← GPL function

    // YOUR CODE IS NOW A DERIVATIVE WORK
    your_proprietary_function();  // ← Must be GPL!

    return 0;
}

// Compiled binary links to: libwazuh.so
// ENTIRE PROGRAM MUST BE GPL
```

**Why this fails**:
- Direct linking = derivative work
- Must release source code
- Cannot be proprietary

#### Pattern B: Shared Library (REQUIRES GPL)

```
Your App → links to → libwazuh.so (GPL)

Result: Your App MUST be GPL
```

**Exception**: System libraries (glibc, OpenSSL) are exempt, but Wazuh is NOT a system library.

#### Pattern C: Modified Agent (REQUIRES GPL)

```c
// Modified: src/client-agent/agentd.c
// Added your code to Wazuh source

void your_custom_feature() {
    // Your code here
    // Uses Wazuh data structures
    // Calls Wazuh functions
}

// THIS ENTIRE FILE MUST BE GPL
// You CANNOT keep this proprietary
```

### 🟢 Recommended Architecture for Commercial Product

```
┌─────────────────────────────────────────────────────────────┐
│                    YOUR ENTERPRISE PRODUCT                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────┐         ┌──────────────────┐          │
│  │ Wazuh Core      │◄───────►│ Your Proprietary │          │
│  │ (GPLv2/AGPLv3) │   API   │ Management Layer │          │
│  │                 │         │ (Closed Source)  │          │
│  │ • Agent         │         │                  │          │
│  │ • Manager       │         │ • Custom UI      │          │
│  │ • Engine        │         │ • Billing        │          │
│  └────────┬────────┘         │ • RBAC           │          │
│           │                  │ • Integrations   │          │
│           │                  └──────────────────┘          │
│           │                                                  │
│  ┌────────▼────────┐         ┌──────────────────┐          │
│  │ Wazuh Indexer   │         │ Your Proprietary │          │
│  │ (OpenSearch)    │◄───────►│ Analytics Engine │          │
│  │ (Apache 2.0)    │   API   │ (Closed Source)  │          │
│  └─────────────────┘         └──────────────────┘          │
│                                                               │
└─────────────────────────────────────────────────────────────┘

Key:
► API Communication (REST, gRPC, etc.)
□ Open Source (provide source)
□ Closed Source (your proprietary code)
```

**Components**:

1. **Wazuh Core** (GPLv2/AGPLv3)
   - Source: Available at yourcompany.com/source
   - Modifications: Documented in CHANGES.txt
   - Distribution: Binaries + Source

2. **Your Management Layer** (Proprietary)
   - License: Your EULA
   - Technology: Python/Go/Java/Node.js
   - Communication: REST API to Wazuh
   - Features:
     - Multi-tenancy
     - Advanced RBAC
     - Billing/licensing
     - Custom reporting
     - Integrations (Jira, ServiceNow, etc.)

3. **Your Analytics Engine** (Proprietary)
   - License: Your EULA
   - Technology: Python/Spark/Custom ML
   - Input: Reads from Indexer via API
   - Features:
     - Proprietary ML models
     - Custom threat detection
     - Behavioral analytics
     - Risk scoring

4. **Custom UI** (Proprietary)
   - License: Your EULA
   - Technology: React/Angular/Vue
   - Talks to: Your API + Wazuh API

**This architecture allows**:
- ✅ 70-80% proprietary code
- ✅ Competitive differentiation
- ✅ Full GPL compliance
- ✅ Easy updates (pull Wazuh upstream)

---

## Business Models That Work

### Model 1: Open Core (Red Hat Model)

```
FREE Tier:
- Standard Wazuh (unmodified)
- Community support
- Basic documentation

PAID Tier ($50k-$500k/year):
- Wazuh + Proprietary features (separate processes)
- Enterprise support (SLA)
- Professional services
- Advanced UI
- Compliance reporting
- Integrations
```

**Legal Structure**:
- Wazuh: GPLv2/AGPLv3 (source provided)
- Your features: Proprietary (separate architecture)
- Bundle: Aggregate distribution

**Examples**: Red Hat Enterprise Linux, GitLab

### Model 2: SaaS/Managed Service

```
Product: "YourBrand Security Cloud"
Price: $10/agent/month
Offering:
- Hosted Wazuh infrastructure
- 24/7 monitoring
- Automatic updates
- Custom integrations
- White-label dashboard
```

**Legal Requirements**:
- ✅ Provide source code download link (AGPLv3)
- ✅ Allow customers to self-host if they want
- ✅ Cannot prevent redistribution

**Revenue Model**: Convenience, hosting, support, integrations

**Examples**: AWS (uses Linux), GitLab SaaS

### Model 3: Support & Services

```
Product: Free Wazuh distribution
Revenue:
- Enterprise support: $25k-$100k/year
- Implementation services: $200/hour
- Custom development: $150-$300/hour
- Training: $5k/person/course
- Certification: $2k/exam
```

**Legal**: 100% compliant (selling services, not software)

**Examples**: Red Hat, SUSE, Canonical

### Model 4: Dual Licensing (Requires Copyright)

```
⚠️ WARNING: Only works if YOU own copyright

Standard License: GPLv2 (free)
Commercial License: Proprietary ($$$)
```

**Requirements**:
- You must own ALL code (or have contributor agreements)
- Wazuh Inc. owns Wazuh copyright → You CANNOT dual-license

**Not applicable** unless you rewrite from scratch or get agreement from Wazuh Inc.

### Model 5: Proprietary Extensions

```
Base: Wazuh (free, GPLv2)
Extensions (proprietary, via API):
- Advanced threat detection
- Compliance automation
- Ticketing integration
- Custom dashboards
- ML/AI analytics

Price: $20k-$200k/year for extensions
```

**Legal**: Extensions are separate programs (IPC architecture)

---

## Business Models That DON'T Work

### ❌ Model A: Proprietary Fork

```
Plan:
1. Fork Wazuh
2. Make modifications
3. Close source code
4. Sell as proprietary

RESULT: LICENSE VIOLATION
Risk: Lawsuit from Wazuh Inc.
Penalty: Injunction, damages, attorney fees
```

**Why it fails**: GPLv2 Section 2(b) requires derivative works to be GPL

### ❌ Model B: Restrictive EULA

```
Your EULA:
"You may not:
- Reverse engineer
- Redistribute
- Modify
- Use for competitive purposes"

RESULT: CONFLICTS WITH GPL
Risk: GPL automatically terminates (Section 4)
```

**Why it fails**: GPL grants these rights; you cannot revoke them

### ❌ Model C: Tivoization (Hardware Lock-in)

```
Plan:
1. Embed Wazuh in hardware appliance
2. Cryptographically sign binaries
3. Prevent customer modifications
4. Sell appliance for $50k

With GPLv2: LEGAL (but unethical)
With AGPLv3: ILLEGAL (Section 11: Installation Information)
```

**AGPLv3 Section 11**: Must provide information to install modified versions

### ❌ Model D: Trademark Confusion

```
Product Name: "Wazuh Enterprise Edition"
Domain: wazuh-enterprise.com
Claim: "Official Wazuh partner"

RESULT: TRADEMARK INFRINGEMENT
Risk: Lawsuit from Wazuh Inc.
```

**Why it fails**: "Wazuh" is a registered trademark

---

## Trademark Considerations

### Wazuh Trademarks (Owned by Wazuh Inc.)

**Protected**:
- ® "Wazuh" (word mark)
- ® Wazuh logo
- Trade dress (look and feel)

**Prohibited Uses**:
```
❌ "Wazuh Pro"
❌ "Wazuh Enterprise"
❌ "Wazuh Plus"
❌ "Powered by Wazuh" (without permission)
❌ "Wazuh-compatible" (implies endorsement)
❌ Using Wazuh logo in marketing
❌ Domain: wazuh-anything.com
```

**Permitted Uses** (Nominative Fair Use):
```
✅ "Compatible with Wazuh"
✅ "Based on Wazuh technology"
✅ "Built on Wazuh"
✅ In documentation: "integrates with Wazuh"
✅ Factual statements: "uses Wazuh agent"
```

### Your Brand Strategy

**Create your own brand**:
```
Product: "SecureOps XDR Platform"
Tagline: "Enterprise security monitoring solution"
Fine print: "Incorporates Wazuh open-source technology"

Legal: ✅ No trademark issues
       ✅ Clear differentiation
```

**Acceptable disclosure**:
```
Website footer:
"SecureOps XDR Platform incorporates Wazuh, an open-source
security monitoring solution. Wazuh is a trademark of Wazuh Inc.
SecureOps is not affiliated with or endorsed by Wazuh Inc."
```

---

## Step-by-Step Compliance Checklist

### Phase 1: Planning

- [ ] Consult IP attorney familiar with GPL
- [ ] Review your business model against GPL requirements
- [ ] Design architecture (IPC-based for proprietary features)
- [ ] Create brand identity (avoid Wazuh trademark)
- [ ] Budget for compliance (source code hosting, documentation)

### Phase 2: Development

- [ ] Fork Wazuh repository OR use as-is
- [ ] Document ALL modifications (CHANGES.txt)
- [ ] Add copyright notices to modified files
- [ ] Keep Wazuh code separate from proprietary code
- [ ] Use API/IPC for proprietary integrations
- [ ] Implement source code download mechanism

### Phase 3: Legal Documentation

- [ ] Create LICENSE file (include GPLv2 + AGPLv3)
- [ ] Create NOTICE file (list all open-source components)
- [ ] Create CHANGES.txt (document modifications)
- [ ] Draft EULA for proprietary components (if any)
- [ ] Create source code distribution plan
- [ ] Prepare written offer for source code

### Phase 4: Product Packaging

- [ ] Include LICENSE in installer
- [ ] Add "About" section in UI with license info
- [ ] Provide source code download link
- [ ] Bundle source code OR provide written offer
- [ ] Test source code builds successfully
- [ ] Document build process

### Phase 5: Distribution

- [ ] Setup source code hosting (GitHub, GitLab, own server)
- [ ] Ensure source matches distributed binaries
- [ ] Make source publicly accessible (no login required)
- [ ] Monitor customer requests for source code
- [ ] Update source code when releasing updates

### Phase 6: Ongoing Compliance

- [ ] Track Wazuh updates (security patches)
- [ ] Maintain source code repository
- [ ] Update documentation
- [ ] Respond to GPL requests within 3 days
- [ ] Annual compliance audit

---

## Real-World Examples

### ✅ COMPLIANT: AlienVault OSSIM

**Model**: Open-source SIEM (based on OSSEC, like Wazuh)

**Strategy**:
- Free: OSSIM (open source)
- Paid: USM (proprietary features)
- Architecture: OSSIM (GPL) + proprietary extensions

**Revenue**: $50M+ annually

**Compliance**: ✅ Source code available, clear licensing

### ✅ COMPLIANT: Red Hat Enterprise Linux

**Model**: Based on Fedora (open source)

**Strategy**:
- Free: Fedora, CentOS Stream
- Paid: RHEL ($350-$1,300/year/server)
- Value: Support, certification, stability

**Revenue**: $3.4 billion annually

**Compliance**: ✅ Full GPL compliance, source available

### ✅ COMPLIANT: GitLab

**Model**: Open core

**Strategy**:
- Free: GitLab CE (open source, MIT)
- Paid: GitLab EE ($19-$99/user/month)
- Architecture: CE (open) + EE features (proprietary)

**Revenue**: $150M+ annually

**Compliance**: ✅ Clear separation, source available

### ❌ NON-COMPLIANT: Numerous GPL Violators

**Companies sued for GPL violation**:
- Best Buy (BusyBox case)
- Samsung (Linux kernel case)
- Cisco (GPL violations, settled)
- Fortinet (ongoing litigation)

**Typical penalties**:
- Injunction (stop selling)
- Release source code
- Pay damages
- Pay attorney fees ($500k-$2M+)
- Public admission

---

## Risk Assessment

### Legal Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| GPL violation lawsuit | Medium-High if non-compliant | Severe ($$$, injunction) | Full compliance |
| Trademark infringement | High if using "Wazuh" | High (lawsuit, damages) | Create own brand |
| Customer redistributes | High (GPL allows it) | Low (expected) | Compete on service |
| Competitor forks your work | Medium | Medium | Proprietary differentiation |
| Wazuh Inc. competition | Low | Medium | Different market segment |

### Financial Risks

**Compliance Costs**:
- Source code hosting: $100-$500/month
- Legal review: $5,000-$25,000 (one-time)
- Documentation: $10,000-$50,000
- Ongoing compliance: $2,000-$10,000/year

**Non-Compliance Costs**:
- Lawsuit defense: $100,000-$500,000
- Settlement: $50,000-$5,000,000
- Lost revenue (injunction): Potentially total
- Reputation damage: Severe

**ROI**: Compliance is 10-100x cheaper than violation

---

## Recommended Business Structure

### Option 1: Pure Service Model (SAFEST)

```
Company: YourBrand Security Services, LLC

Products:
1. Wazuh (free download)
   - Unmodified or minor modifications
   - Source code provided
   - GPLv2/AGPLv3 license

2. Managed Wazuh Service ($10-50/agent/month)
   - Hosting
   - Configuration
   - Monitoring
   - Updates
   - Support

3. Professional Services
   - Implementation: $25k-$200k
   - Custom development: $150-$300/hour
   - Training: $5k/person
   - Support: $25k-$100k/year SLA

Revenue Model:
- Year 1: 70% services, 30% managed
- Year 3: 50% services, 50% managed
- Year 5: 30% services, 70% managed

Legal Risk: MINIMAL
Compliance: Simple (just provide source)
Competition: Based on expertise, not code
```

### Option 2: Open Core (MODERATE RISK)

```
Company: YourBrand Security, Inc.

Products:
1. YourBrand Community Edition (free)
   - Based on Wazuh (GPLv2/AGPLv3)
   - Source code provided
   - Community support

2. YourBrand Enterprise Edition ($50k-$500k/year)
   - Wazuh Core (open source)
   - Proprietary Management Layer (closed source)
     ├── Advanced UI (separate process)
     ├── Multi-tenancy (separate service)
     ├── ML Analytics (separate service)
     ├── Compliance Automation (separate service)
     └── Premium Integrations (separate service)
   - Enterprise support
   - Professional services

Architecture:
┌─────────────────────┐
│ Wazuh (GPLv2)      │ ← Open source
└──────┬──────────────┘
       │ REST API
┌──────▼──────────────┐
│ Management Layer   │ ← Proprietary
└────────────────────┘

Revenue Model:
- 60% software licenses
- 30% support/services
- 10% training

Legal Risk: MODERATE (requires proper architecture)
Compliance: Complex (multiple components)
Competition: Based on proprietary features
```

### Option 3: SaaS Only (MODERATE RISK)

```
Company: YourBrand Cloud Security, Inc.

Product: YourBrand Security Cloud

Offering:
- Hosted Wazuh infrastructure
- Web dashboard (proprietary)
- API access
- Automatic updates
- 24/7 monitoring
- Integration marketplace

Pricing:
- $5/agent/month (SMB)
- $10/agent/month (Enterprise)
- $15/agent/month (Enterprise Plus)

Technology:
- Backend: Wazuh (modified, AGPLv3)
- Frontend: Custom React app (proprietary)
- API: Custom Go service (proprietary)

Compliance Requirements:
✅ Provide source code download (AGPLv3 Section 13)
✅ Document modifications
✅ Include license info in UI

Revenue Model:
- MRR growth: 20-30% monthly
- Target: 10,000 agents = $50k-$150k MRR

Legal Risk: MODERATE (AGPLv3 network compliance)
Compliance: Must provide source downloads
Competition: Based on convenience, UI, integrations
```

---

## FAQ

### Q1: Can I sell Wazuh without providing source code?

**A: NO.** This violates GPLv2 Section 3. You must:
- Provide source code with binary, OR
- Provide written offer for source code, OR
- Provide download link (if distributing online)

Penalty: License termination, lawsuit, damages

### Q2: Can customers redistribute my product for free?

**A: YES.** GPL Section 1 grants redistribution rights. You cannot prevent this.

**However**: Customers typically don't because:
- They lack your expertise
- They want your support
- They signed service contracts
- They need your updates

**Real-world**: <5% of Red Hat customers redistribute RHEL

### Q3: Can I add a "No Commercial Use" restriction?

**A: NO.** This violates GPL. GPL Section 6 prohibits additional restrictions.

Your license would be invalid → Automatic termination

### Q4: What if I only modify configuration files?

**A: Still GPL**, but simpler compliance.

Configuration files are covered by LICENSE line 21:
"this license applies to the source code, as well as
decoders, rules and any other data file included with Wazuh"

You must provide modified configs with source code.

### Q5: Can I require customers to sign NDAs?

**A: NO** - for Wazuh code
**A: YES** - for your proprietary components

**Illegal NDA**:
"You agree not to disclose the source code of this software"
→ Violates GPL Section 6

**Legal NDA**:
"You agree not to disclose YourBrand's proprietary management
layer, API keys, or business processes. Note that Wazuh
components are open source and not subject to this NDA."

### Q6: What if I only use Wazuh internally (not distributed)?

**A: No obligations** (GPLv2 does not restrict use)

You can:
- Modify freely
- Keep changes private
- No need to release source

**EXCEPTION**: If using AGPLv3 Engine and others access it over network → Must provide source (Section 13)

### Q7: Can I fork Wazuh and create a proprietary competitor?

**A: NO.** The fork must remain GPLv2/AGPLv3.

You can:
- Fork and keep it open source
- Charge for services around it
- Add proprietary features via IPC

You cannot:
- Make the fork proprietary
- Close source the code

### Q8: Do I need permission from Wazuh Inc.?

**A: NO** - for GPL code (license grants permission)
**A: YES** - for trademark use

GPL: License grants automatic permission for use, modification, distribution

Trademark: Requires explicit permission from Wazuh Inc.

### Q9: What if a customer modifies my product and redistributes it?

**A: This is allowed** under GPL. You cannot prevent it.

**Your response**:
- Compete on service quality
- Offer official support
- Maintain brand reputation
- Innovate faster

### Q10: Can I offer Wazuh under a dual license?

**A: NO** - You don't own the copyright.

Only Wazuh Inc. (copyright holder) can offer dual licensing.

You can:
- Distribute under existing GPL/AGPL
- Add proprietary components (separate)

### Q11: What happens if I violate GPL accidentally?

**GPLv2 Section 4**: License automatically terminates

**Process**:
1. Wazuh Inc. (or anyone) sends notice
2. You have 30 days to cure violation
3. If cured, license reinstated
4. If not cured, lawsuit possible

**Best practice**: Compliance from day 1

### Q12: Can I charge $1,000,000 for Wazuh?

**A: YES** - GPL allows any price.

**However**: Customers can redistribute it for $0.

**Successful strategy**: Charge for support/services, not software bits.

Example: Red Hat charges $350-$1,300/year for Linux (free to download), but customers pay for:
- Support
- Certification
- Stability
- Indemnification

---

## Legal Resources

### Official Sources

1. **GNU GPL v2**: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
2. **GNU AGPL v3**: https://www.gnu.org/licenses/agpl-3.0.html
3. **FSF GPL FAQ**: https://www.gnu.org/licenses/gpl-faq.html
4. **Wazuh License**: /home/user/wazuh/LICENSE

### Case Law (GPL Enforcement)

1. **Artifex v. Hancom** (2017) - GPL upheld in US court
2. **Software Freedom Conservancy v. Vizio** (2021) - GPL violation lawsuit
3. **Versata v. Ameriprise** (2016) - GPL compliance case
4. **VMware v. Hellwig** (2019, Germany) - Linux kernel GPL case

### Recommended Reading

1. **GPL Compliance Guide** - Software Freedom Conservancy
2. **Open Source Licensing** - Andrew M. St. Laurent (O'Reilly)
3. **Understanding Open Source Licensing** - Lawrence Rosen

### Legal Counsel

**Recommended specialists**:
- Software Freedom Law Center (SFLC)
- Open Source Initiative legal network
- IP attorneys with GPL experience

**Budget**: $5,000-$25,000 for initial compliance review

---

## Conclusion

### ✅ YES, You Can Build a Commercial Enterprise Product

**The key**: Proper architecture and compliance

**Your options**:
1. **Services model** (safest, proven)
2. **Open core** (moderate risk, high potential)
3. **SaaS** (moderate risk, recurring revenue)

**Requirements**:
- ✅ Provide source code
- ✅ Respect GPL/AGPL terms
- ✅ Create your own brand
- ✅ Separate proprietary features (IPC)
- ✅ Be transparent with customers

### 🚀 Recommended Action Plan

**Month 1: Planning**
- Hire IP attorney ($5k-$10k)
- Design architecture (IPC-based)
- Create brand identity
- Draft business plan

**Month 2-3: Development**
- Build proprietary management layer
- Implement IPC communication
- Create custom UI
- Document everything

**Month 4: Compliance**
- Legal review
- Create LICENSE/NOTICE files
- Setup source code hosting
- Test source builds

**Month 5: Launch**
- Beta customers
- Refine offering
- Marketing
- Sales

**Year 1 Revenue Potential**: $100k-$500k
**Year 3 Revenue Potential**: $1M-$5M+
**Legal Risk**: MINIMAL (if compliant)

### ⚠️ Red Lines (DO NOT CROSS)

1. ❌ Never close-source Wazuh code
2. ❌ Never use "Wazuh" trademark without permission
3. ❌ Never prevent customer redistribution
4. ❌ Never violate GPL terms

**One violation = potential company-ending lawsuit**

### Final Recommendation

**Build on Wazuh, but do it legally.**

The GPL is not your enemy - it's your foundation. Companies like Red Hat have built $3B+ businesses on GPL software.

Your competitive advantage is NOT secret code - it's:
- Expertise
- Support quality
- Integration quality
- User experience
- Brand trust
- Service delivery

**Focus on these, comply with GPL, and you'll succeed.**

---

## Document Maintenance

**Last Updated**: 2024
**Version**: 1.0
**Review Cycle**: Annually or when GPL/AGPL terms change
**Owner**: [Your Company Legal Team]

**Change Log**:
- 2024-01-15: Initial version
- [Future updates here]

---

## Appendix A: GPL/AGPL Full Text

See:
- `/home/user/wazuh/LICENSE` (GPLv2)
- `/home/user/wazuh/src/engine/LICENSE-engine` (AGPLv3)

## Appendix B: Sample Source Code Provision

```
README.txt (include in distribution):
---
Source Code Availability

This software incorporates Wazuh, which is licensed under
the GNU General Public License v2 and GNU Affero General
Public License v3.

Complete source code is available at:
https://yourcompany.com/downloads/source/

Or send written request to:
YourCompany, Inc.
Attn: Source Code Request
123 Main St
City, State ZIP

Source code will be provided for a fee not exceeding our
cost of distribution ($20 for USB drive + shipping).

This offer is valid for three years from the date of
distribution.
```

## Appendix C: Sample LICENSE File

```
LICENSE.txt:
---
YourBrand Security Platform
Copyright (C) 2024 YourCompany, Inc.

This product consists of multiple components with different
licenses:

1. Wazuh Core Components
   Copyright (C) 2015-2024 Wazuh Inc.
   License: GNU General Public License v2
   Source: https://yourcompany.com/source/wazuh-core/

2. Wazuh Analysis Engine
   Copyright (C) 2023-2024 Wazuh Inc.
   License: GNU Affero General Public License v3
   Source: https://yourcompany.com/source/wazuh-engine/

3. YourBrand Management Layer (proprietary)
   Copyright (C) 2024 YourCompany, Inc.
   License: See EULA.txt
   Source: Proprietary (not open source)

For complete license terms, see:
- GPL-2.0.txt (Wazuh Core)
- AGPL-3.0.txt (Wazuh Engine)
- EULA.txt (YourBrand proprietary components)
```

---

**END OF DOCUMENT**

**⚠️ REMEMBER: This is informational only. Consult a qualified attorney before proceeding with your commercial product.**
