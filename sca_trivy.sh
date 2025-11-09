#!/bin/sh

DC_VERSION="latest"
REPORTS_DIRECTORY="$(pwd)/sca-trivy-reports"

if [ ! -d "$REPORTS_DIRECTORY" ]; then
    echo "Create report directory: $REPORTS_DIRECTORY"
    mkdir -p "$REPORTS_DIRECTORY"
fi

# Make sure we are using the latest version
docker pull aquasec/trivy:$DC_VERSION

# Run Trivy vulnerability scanner in Docker and output HTML report
docker run --rm -v $(pwd):/workspace aquasec/trivy:$DC_VERSION fs \
  --format template \
  --template "@contrib/html.tpl" \
  /workspace > $REPORTS_DIRECTORY/trivy-report.html
