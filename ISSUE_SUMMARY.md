# High Load on Worker Nodes During Cluster Join Due to user-domain-changed Event Storm

## Summary

When new worker nodes join an existing NethServer 8 cluster with multiple user domains, the system experiences significant load spikes caused by an excessive number of `user-domain-changed` events. This creates a "butterfly effect" where each ldapproxy on newly joined nodes broadcasts events for every user domain, causing all applications across all nodes to process these events, even when they should be ignored.

## Problem Description

### Observed Behavior

When two new nodes were added to a complex NethServer 8 cluster:
- Worker nodes experienced concerning high load averages (4.60, 4.48, 3.89 on a 4-CPU system)
- Load eventually stabilized but the spike was significant during the join process
- On the leader node, `alloy` process was consuming high CPU resources reading journal logs
- Journal analysis revealed: `journalctl --grep 'user-domain-changed is starting' | wc -l` returned **300 events**

### Root Cause Analysis

The excessive events are caused by:
1. **Event multiplication**: Each ldapproxy on newly joined nodes sends a `user-domain-changed` event for every user domain in the system
2. **Lack of filtering**: Applications receive and start processing events even when they originate from different nodes
3. **Combinatorial explosion**: With 2 new nodes × 25 user domains × 6 applications = 300 event handler invocations

### Evidence from Logs

Redis logs showed continuous disk writes every 5 seconds (normal behavior but amplified by the event storm):
```
Nov 12 15:15:25 nodo7 redis[31177]: 1:S 12 Nov 2025 15:15:25.351 * 1 changes in 5 seconds. Saving...
Nov 12 15:15:25 nodo7 redis[31177]: 1:S 12 Nov 2025 15:15:25.353 * Background saving started by pid 177
Nov 12 15:15:25 nodo7 redis[31177]: 177:C 12 Nov 2025 15:15:25.394 * DB saved on disk
```

Frequent `get-node-status` task executions:
```
Nov 12 15:15:26 nodo7 agent@node[30875]: task/node/13/8fbe1304-bacd-498e-9917-b4722a09ba2b: get-node-status/20read is starting
```

### Impact

- **Performance**: Temporary high load during cluster join operations
- **Scalability**: Problem scales with number of nodes × number of domains × number of applications
- **Resource consumption**: Unnecessary CPU and I/O usage processing irrelevant events
- **Logging overhead**: Excessive journal writes being processed by `alloy` on the leader

### Current Situation

Out of the 300 event handler invocations:
- Only **12 should actually result in service restarts/reloads** (those matching the domain name)
- The remaining **288 are unnecessary** and should be prevented or ignored

## Proposed Solution

Implement two complementary approaches to prevent the event storm:

### 1. Reduce Events at the Source

Instead of generating one event per domain, ldapproxy should generate a **single event** containing all affected domains:

**Current behavior** (multiple events):
```json
{"node_id": 5, "domain": "domain1"}
{"node_id": 5, "domain": "domain2"}
{"node_id": 5, "domain": "domain3"}
...
```

**Proposed behavior** (single event):
- For single domain changes (normal operation):
  ```json
  {"node_id": 5, "domain": "example.com"}
  ```
  
- For multiple domain changes (e.g., during node join):
  ```json
  {"node_id": 5, "domains": ["domain1", "domain2", "domain3", ...]}
  ```

### 2. Implement Node Filtering in Event Handlers

Event handlers should ignore events originating from other nodes unless the application needs to react to remote changes:

```python
# Pseudo-code for event handler
if event.node_id != current_node_id:
    # Ignore events from other nodes
    return
```

### 3. Update Event Handlers Gracefully

To maintain backward compatibility while rolling out the fix:

1. **Phase 1**: Update ldapproxy to send new payload format with `domains` array
2. **Phase 2**: Update application event handlers to:
   - Check for `node_id` and ignore if different (unless application requires cross-node event processing)
   - Handle both old format (`domain` string) and new format (`domains` array)
   - If `domain` key is not found, terminate without action (this happens when only `domains` is present)

**Backward compatibility logic**:
```python
def handle_user_domain_changed(event):
    # Ignore events from other nodes
    if event.get('node_id') != current_node_id:
        return
    
    # Handle new format (multiple domains)
    if 'domains' in event:
        domains_to_process = event['domains']
    # Handle old format (single domain)
    elif 'domain' in event:
        domains_to_process = [event['domain']]
    else:
        # Neither key present, nothing to do
        return
    
    # Process domains
    for domain in domains_to_process:
        if domain_is_relevant(domain):
            restart_or_reload_services()
```

## Components Affected

- **ns8-core**: ldapproxy event generation logic
- **Applications** with user-domain-changed event handlers:
  - ns8-mail (referenced in the conversation via PR #141)
  - Other applications that handle user domain events
  - All applications need review and potential updates

## References

- Related PR: https://github.com/NethServer/ns8-mail/pull/141#pullrequestreview-2454099533
- Initial discussion about the GiacomoProxy change that exposed this issue
- Similar past issue: "letsencrypt-gate" where API calls for certificate renewals caused similar event multiplication

## Expected Behavior

After implementing this fix:
- Node join operations should generate **O(1)** events instead of **O(domains)** events
- Worker nodes should experience minimal load increase during cluster join
- Only applications on nodes with relevant domain configurations should process events
- System should scale better with large numbers of domains and nodes

## Steps to Reproduce

1. Set up a NethServer 8 cluster with multiple nodes
2. Configure 20-30 user domains across the cluster
3. Install 5-6 applications that handle user domain events (e.g., Mail, NextCloud, etc.)
4. Monitor system load: `watch -n 1 'uptime'`
5. Add 1-2 new worker nodes to the cluster
6. Observe:
   - High load on worker nodes during join process
   - Check journal for event count: `journalctl --grep 'user-domain-changed is starting' | wc -l`
   - Monitor `alloy` process CPU usage on leader: `top -p $(pidof alloy)`

## Additional Context

This issue was observed in production environments including:
- NethServer SaaS clusters
- Customer clusters with significant numbers of nodes
- Any complex cluster during node join operations

The issue is considered normal behavior for complex clusters but should be optimized for better scalability and performance.

## Priority

**High** - This affects cluster scalability and can cause concerning load spikes during node operations. While the load eventually stabilizes, it creates operational anxiety and potentially impacts service availability during scaling operations.
