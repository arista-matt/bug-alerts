# bug-alerts

Download Arista bug alert data and query it with jq.

## Usage

```bash
export BUG_ALERT_TOKEN="your-token-here"
./bug-alerts.sh
```

This downloads the full bug alert database to `bug-alerts.json`.

## Example queries

All examples operate on `bug-alerts.json`.

### List all CVEs

```bash
jq '[.bugs[] | select(.cve != "") | {cve, severity, product, summary: .alertSummary}]' bug-alerts.json
```

### Count bugs by severity

```bash
jq '[.bugs[].severity] | group_by(.) | map({(.[0]): length}) | add' bug-alerts.json
```

### All sev1 bugs

```bash
jq '[.bugs[] | select(.severity == "sev1") | {bugId, cve, summary: .alertSummary, fixed: .versionFixed}]' bug-alerts.json
```

### CVEs with security advisories

```bash
jq '[.bugs[] | select(.securityAdvisoryURL != "") | {cve, url: .securityAdvisoryURL, summary: .alertSummary}]' bug-alerts.json
```

### Bugs affecting a specific EOS version

Find bugs introduced at or before 4.28.0 and not fixed until after it:

```bash
jq '[.bugs[] | select(
  .product == "eos" and
  (.versionIntroduced | any(. <= "4.28.0")) and
  (.versionFixed | any(. > "4.28.0"))
) | {bugId, severity, cve, summary: .alertSummary}]' bug-alerts.json
```

### Most common tags (platform/feature indicators)

```bash
jq '[.bugs[] | .conjunction // [[]] | .[][] | .tag] | group_by(.) | map({tag: .[0], count: length}) | sort_by(-.count) | .[0:15]' bug-alerts.json
```

### Bugs matching a specific tag (e.g. VXLAN)

```bash
jq '[.bugs[] | select(.conjunction // [[]] | .[][] | .tag == "vxlanEnabled") | {bugId, severity, summary: .alertSummary}]' bug-alerts.json
```

### Most "bitten" bugs (highest field impact)

```bash
jq '[.bugs[] | select(.bites > 0) | {bugId, bites, severity, summary: .alertSummary}] | sort_by(-.bites) | .[0:10]' bug-alerts.json
```

### Bugs by product

```bash
jq '[.bugs[].product] | group_by(.) | map({(.[0]): length}) | add' bug-alerts.json
```

### Recently exported bugs

```bash
jq '[.bugs[] | select(.exportedTime > 1700000000) | {bugId, severity, cve, summary: .alertSummary, exported: (.exportedTime | todate)}] | sort_by(-.exportedTime)' bug-alerts.json
```

### CVE summary with affected and fixed versions

```bash
jq '[.bugs[] | select(.cve != "") | {cve, product, severity, introduced: .versionIntroduced, fixed: .versionFixed, tags: [(.conjunction // [[]] | .[][] | .tag)]}]' bug-alerts.json
```
