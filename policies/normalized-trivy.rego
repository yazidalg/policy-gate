package trivy.normalized

# Output rule: iterate all vulnerabilities
output := [v |
  result := input.Results[_]
  vuln := result.Vulnerabilities[_]

  v := {
    { "index": {"_index": "container_scanning"} },
    {
      "Target": result.Target,
      "Vulnerabilities": vuln,
    }
  }
]
