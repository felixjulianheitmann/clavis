BUILDDIR=$1
VERSION=$2
REVISION=$3
ARCH=$4

NAME=clavis

PKG=$NAME_$VERSION-$REVISION_$ARCH
PKG_DIR=tmp/$PKG
mkdir -p $PKG_DIR/usr/local/bin/$NAME

cp DEBIAN $PKG_DIR/.
cp $BUILDDIR/* $PKG_DIR/usr/local/bin/$NAME
cp libs -> $PKG_DIR/usr/lib64

python inject_version.py {VERSION} $PKG_DIR/DEBIAN/control

dpkg-deb --build --root-owner-group $PKG