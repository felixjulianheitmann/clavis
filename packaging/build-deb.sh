PACKAGE=clavis_{version}-{revision}_{arch}
mkdir $PACKAGE
mkdir -p $PACKAGE/usr/lib64
mkdir -p $PACKAGE/usr/local/bin

cp DEBIAN $PACKAGE/.
cp build/linux/arm64/release/bundle/clavis $PACKAGE/usr/local/bin
cp libs -> $PACKAGE/usr/lib64

python inject_version.py {VERSION} $PACKAGE/DEBIAN/control

dpkg-deb --build --root-owner-group $PACKAGE