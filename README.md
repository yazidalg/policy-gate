# Container Security Policy Enforcement

This repository contains Open Policy Agent (OPA) Rego policies for enforcing container security scanning policies using Trivy scan results. The policies validate vulnerability counts by severity level and provide clear feedback on security compliance.

## Overview

The policy enforces security thresholds for container images scanned with Trivy, categorizing vulnerabilities by severity:
- **CRITICAL**: Failures that block deployment
- **HIGH**: Failures that block deployment
- **MEDIUM**: Warnings that exceed threshold
- **LOW**: Warnings that exceed threshold

## Prerequisites

- [Conftest](https://www.conftest.dev/) - Policy testing tool for OPA
- [Trivy](https://aquasecurity.github.io/trivy/) - Container vulnerability scanner
- Trivy scan results in JSON format

## Installation

### Install Conftest

```bash
# macOS
brew install conftest

# Linux
wget https://github.com/open-policy-agent/conftest/releases/download/v0.45.0/conftest_0.45.0_Linux_x86_64.tar.gz
tar xzf conftest_0.45.0_Linux_x86_64.tar.gz
sudo mv conftest /usr/local/bin

# Verify installation
conftest --version
```

### Install Trivy

```bash
# macOS
brew install trivy

# Linux
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
```

## Usage

### Step 1: Scan Your Container Image

Scan your container image with Trivy and save the results to a JSON file:

```bash
trivy image --format json --output results.json lidm-frontend:v1.0
```

### Step 2: Run Policy Validation

Validate the scan results against the security policies:

```bash
conftest test results.json --policy policies --namespace trivy.policy
```

### Example Output

Based on the `results.json` file in this repository, here's what the output looks like:

```
WARN - results.json - trivy.policy - ‼️ Too many MEDIUM vulnerabilities: 15 (allowed: 1)

WARN - results.json - trivy.policy - ✅ Vulnerability summary: CRITICAL=2, HIGH=4, MEDIUM=15, LOW=5

FAIL - results.json - trivy.policy - ⚠️ Too many HIGH vulnerabilities: 4 (allowed: 0)

FAIL - results.json - trivy.policy - ❌ Too many CRITICAL vulnerabilities: 2 (allowed: 0)
```

## Policy Configuration

The security thresholds are defined in `policies/container-scanning.rego`:

```rego
max_critical := 0
max_high := 0
max_medium := 1
max_low := 5
```

### Understanding the Policy

1. **Vulnerability Extraction**: The policy extracts all vulnerabilities from Trivy scan results across all result sets.

2. **Severity Counting**: It counts vulnerabilities by severity level:
   - CRITICAL
   - HIGH
   - MEDIUM
   - LOW

3. **Policy Rules**:
   - **deny** rules: Fail the policy check if thresholds are exceeded (CRITICAL and HIGH)
   - **warn** rules: Issue warnings if thresholds are exceeded (MEDIUM and LOW)
   - **summary**: Always provides a summary of all vulnerability counts

### Customizing Thresholds

Edit `policies/container-scanning.rego` to adjust the maximum allowed vulnerabilities:

```rego
max_critical := 0  # Change to allow more CRITICAL vulnerabilities
max_high := 0      # Change to allow more HIGH vulnerabilities
max_medium := 1    # Change to allow more MEDIUM vulnerabilities
max_low := 5       # Change to allow more LOW vulnerabilities
```

## Understanding the Output

### Exit Codes

- **Exit code 0**: All policies passed (no failures)
- **Exit code 1**: One or more policies failed

### Message Types

- **FAIL**: Denial message - policy check failed (CRITICAL/HIGH exceed limits)
- **WARN**: Warning message - threshold exceeded but not blocking (MEDIUM/LOW exceed limits)
- **Summary**: Always shown, provides complete vulnerability breakdown

### Example Interpretation

For the example `results.json`:
- **Total**: 26 vulnerabilities
  - CRITICAL: 2 (exceeds limit of 0) → **FAIL**
  - HIGH: 4 (exceeds limit of 0) → **FAIL**
  - MEDIUM: 15 (exceeds limit of 1) → **WARN**
  - LOW: 5 (within limit of 5) → **OK**

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Container Security Scan

on:
  push:
    branches: [ main ]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Trivy
        run: |
          sudo apt-get update
          sudo apt-get install -y wget apt-transport-https gnupg lsb-release
          wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
          echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
          sudo apt-get update
          sudo apt-get install -y trivy
      
      - name: Install Conftest
        run: |
          wget https://github.com/open-policy-agent/conftest/releases/download/v0.45.0/conftest_0.45.0_Linux_x86_64.tar.gz
          tar xzf conftest_0.45.0_Linux_x86_64.tar.gz
          sudo mv conftest /usr/local/bin
      
      - name: Build Docker image
        run: docker build -t myapp:latest .
      
      - name: Scan container image
        run: trivy image --format json --output results.json myapp:latest
      
      - name: Validate security policies
        run: conftest test results.json --policy policies --namespace trivy.policy
```

### GitLab CI Example

```yaml
security-scan:
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - apk add --no-cache wget
    - wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apk add --allow-untrusted -
    - wget https://github.com/open-policy-agent/conftest/releases/download/v0.45.0/conftest_0.45.0_Linux_x86_64.tar.gz
    - tar xzf conftest_0.45.0_Linux_x86_64.tar.gz
    - mv conftest /usr/local/bin/
  script:
    - docker build -t myapp:latest .
    - trivy image --format json --output results.json myapp:latest
    - conftest test results.json --policy policies --namespace trivy.policy
```

## File Structure

```
.
├── README.md                    # This file
├── policies/
│   └── container-scanning.rego # OPA Rego policy file
├── results.json                 # Example Trivy scan results
└── result.json                  # Alternative results file
```

## Troubleshooting

### Policy Not Found

If you get an error about the policy not being found:

```bash
# Ensure you're in the repository root
cd /path/to/PSI

# Verify the policy file exists
ls -la policies/container-scanning.rego

# Run conftest with absolute path if needed
conftest test results.json --policy ./policies --namespace trivy.policy
```

### Invalid JSON Format

Ensure your Trivy scan output is in JSON format:

```bash
# Use --format json flag
trivy image --format json --output results.json <image-name>
```

### No Vulnerabilities Found

If Trivy finds no vulnerabilities, the policy will still run and show:
```
✅ Vulnerability summary: CRITICAL=0, HIGH=0, MEDIUM=0, LOW=0
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with your own scan results
5. Submit a pull request

## License

This project is open source and available for use in your security workflows.

## References

- [Open Policy Agent (OPA)](https://www.openpolicyagent.org/)
- [Conftest Documentation](https://www.conftest.dev/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Rego Policy Language](https://www.openpolicyagent.org/docs/latest/policy-language/)

