<p align="center">
<img src="assets/Key-Logo_Diagonal.png" width="10%" />
</p>

<p align="center">
<img src="assets/clavis_white.svg" width="20%" />
</p>

The key to your [Gamevault](https://gamevau.lt) library.

[![Build Pipeline](https://github.com/felixjulianheitmann/clavis/actions/workflows/build-and-release.yaml/badge.svg)](https://github.com/felixjulianheitmann/clavis/actions/workflows/build-and-release.yaml)

_This project is independent from Phalcode. It's using the Gamevault's open source backend API to provide a multi-platform client interface._

This is not a replacement for the official [Gamevault Client](https://github.com/Phalcode/gamevault-app). At the moment, this is a mere management application. It doesn't allow you to install or run any of the games from your vault.

:::warning
This software is still in a very early development phase expect bugs and other issues to pop up.
:::

This Flutter-based application is a management application for your Gamevault server. The feature set includes
- browsing through your game library
  - viewing individual games including screenshots, description, external links, etc.
  - bookmarking games
  - downloading the backends game installation files
- managing Gamevault users
  - registering new users
  - activating/deactivating existing users
  - deleting/restoring existing users
  - editing user info and credentials
- viewing your own gaming history

There are plans for greatness in the future but I am trying for a stable minimum viable application first.

## Install

Check for the latest available releases on the [Releases Page](https://github.com/felixjulianheitmann/clavis/releases/latest).

clavis is available as:
- [Docker image](#docker)
- Linux RPM package
- Linux deb package
- Windows installer package
- Android APK 

### Docker

The Docker image is available on the Github Container registry.
The container is quite simple and doesn't have any dependencies or persistent storage.

```
docker run --rm -p 8080:80 ghcr.io/felixjulianheitmann/clavis:latest
```

You can then access the application on `http://localhost:8080`.
