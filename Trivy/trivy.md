## Simulate a Quality Score (like 70%)

Trivy doesn't provide a numeric score by default, but you can simulate one by comparing high/critical vulnerabilities to the total. Here's a Bash script that does exactly that:

```bash
#!/bin/bash

IMAGE="mdinesh28/imdb"

# Get total vulnerabilities (LOW, MEDIUM, HIGH, CRITICAL)
TOTAL=$(trivy image --severity LOW,MEDIUM,HIGH,CRITICAL --format json "$IMAGE" \
    | jq '.Results[].Vulnerabilities | length' \
    | awk '{s+=$1} END {print s}')

# Get only HIGH and CRITICAL vulnerabilities
CRITICAL_HIGH=$(trivy image --severity HIGH,CRITICAL --format json "$IMAGE" \
    | jq '.Results[].Vulnerabilities | length' \
    | awk '{s+=$1} END {print s}')

# If no vulnerabilities found
if [ "$TOTAL" -eq 0 ]; then
    echo "Image is clean ✅"
    exit 0
fi

# Calculate simulated security score
BAD_PERCENT=$((CRITICAL_HIGH * 100 / TOTAL))
GOOD_PERCENT=$((100 - BAD_PERCENT))

echo "Security score: $GOOD_PERCENT%"

# Apply quality gate
if [ "$GOOD_PERCENT" -lt 70 ]; then
    echo "❌ Image failed security quality gate (< 70%)"
    exit 1
else
    echo "✅ Image passed security quality gate (>= 70%)"
    exit 0
fi
```
## You're using jq in your script to parse Trivy JSON output, but jq isn't installed.
## Install jq on your system:
    sudo apt-get update
    sudo apt-get install -y jq
