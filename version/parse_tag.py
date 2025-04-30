import semver
import json
import sys

if len(sys.argv) < 2:
    print("usage: python inject-version.py <version> [<distance>]")
    print(f'provided: {" ".join(sys.argv)}')
    exit(1)

ver = semver.Version.parse(sys.argv[1][1:])
distance="0"
if(len(sys.argv) >= 3):
    distance = sys.argv[2]

buildFlag = "0"
buildRelease = "000"
if ver.build is not None:
    if ver.build.startswith("rc"):
        buildFlag = "1"
    elif ver.build.startswith("beta"):
        buildFlag = "2"
    elif ver.build.startswith("alpha"):
        buildFlag = "3"
    elif len(ver.build) > 0:
        buildFlag = "9"

    if len(ver.build) > 0:
        buildRelease = f"{ver.build.split(".")[1]:0>3}"

buildDirty = "1" if int(distance) > 0 else "0"


print(json.dumps({
    'semver': ver.to_dict(),
    'distance': distance,
    'versionEncoded': f"{ver.major}.{ver.minor}.{ver.patch}.{buildFlag}{buildRelease}{buildDirty}",
}))
