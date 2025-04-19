<p align="center">
<img src="assets/Key-Logo_Diagonal.png" width="10%" />
</p>

<p align="center">
<img src="assets/clavis_white.svg" width="20%" />
</p>

A management client for your [Gamevault](https://gamevau.lt) library.

_This project is independent from Phalcode. It's using the Gamevault's open source backend API to provide a multi-platform client interface._


This Readme is more of a scratchpad for a roadmap at the moment.

## Install

Currently, the only release form is a web-app hosted using Docker.

| System | Instructions |
| ------ | ----- |
| Docker | [Install using Docker](#docker) |
| Deb package | ... |
| App image | ... |
| Flatpak | ... |
| Win executable | ... |
| Android APK | ... |
| F-Droid | ... |


### Docker

## Features

- Authentication
  - [x] auhtenticate to your gamevault instance
  - [x] store credentials safely for auto-authentication
- Game browsing
  - [x] Cover gallery view of your gamevault library
  - [ ] Gallery listview of the library
  - [x] searching gamelist by title
  - [ ] searching by other criteria
  - [ ] filtering list using pre-populated filter lists (e.g. only show games from Bethesda)
- Game details
  - [x] cover + description + banner + screenshots
  - [x] display links to other pages (steam, wikipedia, youtube, etc)
  - [ ] download game files
  - [ ] show game stats related to user
    - [ ] play time, last played, etc.
  - [ ] display trailer
  - [ ] add to bookmark
- User management
  - [ ] User Me page
    - [x] update user info
    - [ ] deactivate user
    - [ ] delete user
    - [ ] display usage history
      - [ ] last played games
      - [ ] last login
      - [ ] playtime stats, etc
  - [ ] Admin Users page
    - [x] hidden for non-admins
    - [x] Shows all users sorted by active/inactive/deleted
    - [x] Allows activating/deactivating users
    - [x] Allows deleting/restoring users
- Application settings
  - [x] Dark/Light Mode
  - [ ] Default Download Directory
- Gamevault Server page
  - [ ] General info about gamevault server
  - [ ] Display news page

