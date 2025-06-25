# RightClickQuit

A lightweight macOS menu bar utility that quits apps when you right-click the close button.

## How to Use

### 1. Download the App

-   Go to the [Releases](https://github.com/kevinsanchh/RightClickQuit/releases/tag/v0.0.1) page and download the `RightClickQuit.zip` file from the latest release.
-   Unzip the file to get `RightClickQuit.app`.

### 2. Install and Run for the First Time

1.  Move `RightClickQuit.app` to your Mac's main **Applications** folder.
2.  **Important:** The first time you run the app, you must **right-click** on it and select **Open** from the menu.
3.  A warning dialog will appear. Click the **Open** button to grant an exception for the app.

### 3. Grant Permissions

1.  After opening the app, a system prompt will ask for Accessibility permissions. Click **Open System Settings**.
2.  You will be taken to `System Settings > Privacy & Security > Accessibility`.
3.  Find `RightClickQuit` in the list and **turn on the switch** next to it. You may need to enter your password.

The app will now run silently in your menu bar. You can quit any application by right-clicking its red close button.

## Features

-   **Right-Click to Quit:** Instantly quit almost any application like using `Cmd+Q`.
-   **Menu Bar Native:** Lives discreetly in your menu bar with no Dock icon.
-   **Lightweight:** Built with Swift to be fast and efficient.
-   **Smart:** Ignores clicks on itself and Finder to prevent mistakes.
