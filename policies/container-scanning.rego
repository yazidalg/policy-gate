package trivy.policy

max_critical := 0
max_high := 0
max_medium := 1
max_low := 5

vulnerabilities := [v | result := input.Results[_]; v := result.Vulnerabilities[_]]

count_severities := {
	"CRITICAL": count([v | v := vulnerabilities[_]; v.Severity == "CRITICAL"]),
  "HIGH":     count([v | v := vulnerabilities[_]; v.Severity == "HIGH"]),
  "MEDIUM":   count([v | v := vulnerabilities[_]; v.Severity == "MEDIUM"]),
  "LOW":      count([v | v := vulnerabilities[_]; v.Severity == "LOW"])
}

deny contains msg if {
	count_severities["CRITICAL"] > max_critical
	msg := sprintf("❌ Too many CRITICAL vulnerabilities: %d (allowed: %d)", [count_severities["CRITICAL"], max_critical])
}

deny contains msg if {
	count_severities["HIGH"] > max_high
	msg := sprintf("⚠️ Too many HIGH vulnerabilities: %d (allowed: %d)", [count_severities["HIGH"], max_high])
}

warn contains msg if {
	count_severities["MEDIUM"] > max_medium
	msg := sprintf("‼️ Too many MEDIUM vulnerabilities: %d (allowed: %d)", [count_severities["MEDIUM"], max_medium])
}

warn contains msg if {
	count_severities["LOW"] > max_low
  msg := sprintf("🔻 Too many LOW vulnerabilities: %d (allowed: %d)", [count_severities["LOW"], max_low])
}

warn contains msg if {
  msg := sprintf("✅ Vulnerability summary: CRITICAL=%d, HIGH=%d, MEDIUM=%d, LOW=%d",
    [count_severities["CRITICAL"], count_severities["HIGH"], count_severities["MEDIUM"], count_severities["LOW"]])
}