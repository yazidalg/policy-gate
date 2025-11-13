package trivy.policy

deny contains msg if {
	some r in input.Results
	some v in r.Vulnerabilities
	v.Severity == "CRITICAL"
	msg := sprintf("❌ Critical vulnerability found: %s (%s)", [v.VulnerabilityID, v.PkgName])
}

deny contains msg if {
	some r in input.Results
	some v in r.Vulnerabilities
	v.Severity == "HIGH"
	msg := sprintf("⚠️ High vulnerability found: %s (%s)", [v.VulnerabilityID, v.PkgName])
}

warn contains msg if {
	some r in input.Results
	some v in r.Vulnerabilities
	v.Severity == "MEDIUM"
	msg := sprintf("‼️ Medium vulnerability found: %s (%s)", [v.VulnerabilityID, v.PkgName])
}

warn contains msg if {
	some r in input.Results
    some v in r.Vulnerabilities
    v.Severity == "LOW"
    msg := sprintf("🔻 LOW vulnerability found: %s (%s)", [v.VulnerabilityID, v.PkgName])
}


summary := {
	"total": count([v | some r in input.Results; v := r.Vulnerabilities[_]]),
	"critical": count([v | some r in input.Results; v := r.Vulnerabilities[_]; v.Severity == "CRITICAL"]),
	"high": count([v | some r in input.Results; v := r.Vulnerabilities[_]; v.Severity == "HIGH"]),
	"medium": count([v | some r in input.Results; v := r.Vulnerabilities[_]; v.Severity == "MEDIUM"]),
	"low": count([v | some r in input.Results; v := r.Vulnerabilities[_]; v.Severity == "LOW"]),
}
