import re
import sys
from collections import defaultdict

RULE_PATTERN = re.compile(r'^(DOMAIN|DOMAIN-SUFFIX|DOMAIN-KEYWORD|IP-CIDR|IP-CIDR6|GEOIP|PROCESS-NAME|USER-AGENT|FINAL),(.+)$')


def validate_rule(line):
    line = line.strip()
    if not line or line.startswith('#'):
        return True, None
    if not RULE_PATTERN.match(line):
        return False, f"Invalid rule format: {line}"
    return True, None


def detect_duplicates(lines):
    seen = defaultdict(list)
    issues = []

    for i, line in enumerate(lines):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        if line in seen:
            issues.append(f"Duplicate rule: {line} (lines {seen[line]} & {i+1})")
        seen[line].append(i+1)

    return issues


def detect_conflicts(files):
    domain_map = defaultdict(set)
    issues = []

    for file_name, lines in files.items():
        for line in lines:
            line = line.strip()
            if line.startswith('DOMAIN'):
                parts = line.split(',')
                if len(parts) >= 2:
                    domain = parts[1]
                    domain_map[domain].add(file_name)

    for domain, file_set in domain_map.items():
        if len(file_set) > 1:
            issues.append(f"Conflict: {domain} appears in {', '.join(file_set)}")

    return issues


def main():
    if len(sys.argv) < 2:
        print("Usage: python surge_validator.py <file>")
        sys.exit(1)

    file_path = sys.argv[1]

    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    errors = []

    for line in lines:
        ok, err = validate_rule(line)
        if not ok:
            errors.append(err)

    errors.extend(detect_duplicates(lines))

    if errors:
        print("Validation failed:")
        for e in errors:
            print(" -", e)
        sys.exit(1)

    print("Validation passed")


if __name__ == "__main__":
    main()
