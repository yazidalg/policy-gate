package trivy.normalized

# Output rule: iterate all vulnerabilities and emit ES bulk pairs
output := [item |
  result := input.Results[_]
  vuln := result.Vulnerabilities[_]

  entry := [
    {"index": {"_index": "container_scanning"}},
    {
      "Target": result.Target,
      "Vulnerabilities": vuln,
    },
  ]

  item := entry
]
