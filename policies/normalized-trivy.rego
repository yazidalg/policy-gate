package trivy.normalized

# Severity map
severity_map = {
  "CRITICAL": "CRITICAL",
  "HIGH": "HIGH",
  "MEDIUM": "MEDIUM",
  "LOW": "LOW",
  "UNKNOWN": "INFO"
}

# Output rule: iterate all vulnerabilities
output := [v |
  result := input.Results[_]
  vuln := result.Vulnerabilities[_]

  v := {
    "Target": result.Target,
    "Vulnerabilities": vuln,
  }
]
