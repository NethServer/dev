# High Load on Worker Nodes During Cluster Join Due to user-domain-changed Event Storm

## Problem
When new worker nodes join an NS8 cluster with multiple user domains, the system experiences significant load spikes. Each ldapproxy on newly joined nodes broadcasts a `user-domain-changed` event for **every** user domain, causing all applications across **all** nodes to process these events.

**Observed**: 2 new nodes × 25 domains × 6 apps = **300 event handler invocations** (only 12 should trigger actual service changes)

## Root Cause
1. ldapproxy generates one event per domain instead of batching
2. Event handlers don't filter by node_id, so they process remote events unnecessarily
3. Journal analysis: `journalctl --grep 'user-domain-changed is starting' | wc -l` → 300 entries
4. Worker nodes hit load averages of 4.60+ on 4-CPU systems
5. Leader's `alloy` process consumed high CPU reading excessive journal logs

## Proposed Solution

**1. Batch events at source** (ldapproxy):
- Single domain: `{"node_id": 5, "domain": "example.com"}`
- Multiple domains: `{"node_id": 5, "domains": ["domain1", "domain2", ...]}`

**2. Add node filtering** in event handlers:
```python
def handle_user_domain_changed(event):
    if event.get('node_id') != current_node_id:
        return  # Ignore remote events
    
    domains = event.get('domains', [event['domain']] if 'domain' in event else [])
    for domain in domains:
        if domain_is_relevant(domain):
            restart_or_reload_services()
```

## Components Affected
- **ns8-core**: ldapproxy event generation
- **ns8-mail** and other apps with user-domain-changed handlers

## References
- https://github.com/NethServer/ns8-mail/pull/141#pullrequestreview-2454099533
- Similar to past "letsencrypt-gate" issue with certificate renewal API calls
