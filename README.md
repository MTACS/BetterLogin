# BetterLogin

Add features to loginwindow on macOS

### Screenshots

![Screenshot 2025-02-02 at 9 16 42 PM](https://github.com/user-attachments/assets/afb91c01-04ce-4873-a884-2d3b8c34ab10)

![Screenshot 2025-02-02 at 9 19 41 PM](https://github.com/user-attachments/assets/295ad2f9-e664-4af8-a564-53c4effb2985)

<details>
  <summary>Settings Previews</summary>
    <img width="634" alt="wallpaper" src="https://github.com/user-attachments/assets/36e9552e-f67d-46d2-8310-95b7d29486c7" />
    <img width="634" alt="clock" src="https://github.com/user-attachments/assets/09239025-0d20-4ae6-8970-aa910af53c0c" />
    <img width="634" alt="date" src="https://github.com/user-attachments/assets/e87a5c8c-7704-470a-807b-9ffbf4003905" />
    <img width="634" alt="password" src="https://github.com/user-attachments/assets/e1438f99-1e96-44bf-bc20-6781081d0970" />
    <img width="634" alt="other" src="https://github.com/user-attachments/assets/2e554655-13aa-4f08-8bc3-3533ed46097d" />
</details>

## Installation

_macOS Sonoma 14.0 or greater is required_

1. Move BetterLogin.bundle to /Library/Application Support/MacEnhance/Plugins, or double click to automatically open in MacForge

2. Move BetterLogin.app to /Applications (not required, app will work in any location)

Some versions of macOS and MacForge do not automatically inject newly installed bundles. To manually inject BetterLogin follow these steps in terminal. This may be required after every login

```
lldb -p $(pgrep -x loginwindow) 

expr (void) [[NSBundle bundleWithPath:@"/Library/Application Support/MacEnhance/Plugins/BetterLogin.bundle"] load]

expr (void) [BetterLogin load]

c
```

Close terminal window and lock screen

# Building from source

Open project in Xcode and build BetterLogin scheme to build MacForge plugin, build BetterLoginApp scheme for settings application

To build via terminal run 

```
xcodebuild -scheme BetterLogin CODE_SIGNING_ALLOWED="NO" CODE_SIGNING_REQUIRED="NO" CODE_SIGN_IDENTITY=""

xcodebuild -scheme BetterLoginApp CODE_SIGNING_ALLOWED="NO" CODE_SIGNING_REQUIRED="NO" CODE_SIGN_IDENTITY=""
```



