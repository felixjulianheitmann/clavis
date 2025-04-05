import yaml
import sys

if len(sys.argv) < 2:
    print("usage: python inject-version.py <version> [<distance>]")
    print(f"provided: {" ".join(sys.argv)}")
    exit(1)

version = sys.argv[1]

if(len(sys.argv) >= 3):
    version += f"+{sys.argv[2]}"
if(version.startswith('v')):
    version = version[1:]

with open("pubspec.yaml", 'r') as f:
    pubspec = yaml.safe_load(f)

pubspec['version'] = version

with open("pubspec.yaml", 'w') as f:
    f.write(yaml.dump(pubspec))