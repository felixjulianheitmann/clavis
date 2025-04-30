BUILDDIR=$1
VERSION=$2
REVISION=$3
ARCH=$4

NAME=clavis

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <BUILDDIR> <VERSION> <REVISION> <ARCH>"
    exit 1
fi

rm -rf tmp

PKG=${NAME}_${VERSION}_${REVISION}_${ARCH}
PKG_DIR=tmp/$PKG
echo PKG: $PKG
echo Ordner: $PKG_DIR/usr/local/bin/$NAME
mkdir -p $PKG_DIR/usr/local/bin/$NAME

cp -r $BUILDDIR/* $PKG_DIR/usr/local/bin/$NAME
mkdir -p $PKG_DIR/DEBIAN

cat <<EOF > $PKG_DIR/DEBIAN/control
Package: clavis
Version: $VERSION
Architecture: $ARCH
Maintainer: Felix Bruns
Description: Gamevault management client
 A client application to manage your Gamevault instance
Depends: libsecret-1-0, libjsoncpp25
EOF

dpkg-deb --build --root-owner-group $PKG_DIR