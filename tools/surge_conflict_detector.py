import os
import glob
from collections import defaultdict

RULE_PREFIXES = ("DOMAIN", "DOMAIN-SUFFIX", "DOMAIN-KEYWORD", "IP-CIDR", "IP-CIDR6", "GEOIP")


def parse_rule(line):
    line = line.strip()
    if not line or line.startswith('#'):
        return None, None
    for p in RULE_PREFIXES:
        if line.startswith(p):
            parts = line.split(',')
            if len(parts) >= 2:
                return parts[0], parts[1]
    return None, None


def load_files(pattern="surge/*.list"):
    files = {}
    for path in glob.glob(pattern):
        with open(path, 'r', encoding='utf-8') as f:
            files[path] = f.readlines()
    return files


def build_index(files):
    index = defaultdict(lambda: defaultdict(set))
    # domain -> file -> rules
    for file, lines in files.items():
        for line in lines:
            rule_type, domain = parse_rule(line)
            if rule_type and domain:
                index[domain][file].add(rule_type)
    return index


def detect_conflicts(index):
    issues = []

    for domain, file_map in index.items():
        if len(file_map) > 1:
            issues.append({
                "domain": domain,
                "files": list(file_map.keys())
            })

    return issues


def main():
    files = load_files()
    index = build_index(files)
    conflicts = detect_conflicts(index)

    if not conflicts:
        print("No cross-file conflicts detected.")
        return

    print("Cross-file conflicts found:")
    for c in conflicts:
        print(f"- {c['domain']} -> {', '.join(c['files'])}")


if __name__ == "__main__":
    main()
