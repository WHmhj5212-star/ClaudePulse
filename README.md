# ⚡ ClaudePulse - See Claude Code Sessions Live

[![Download ClaudePulse](https://img.shields.io/badge/Download%20ClaudePulse-4B8BBE?style=for-the-badge&logo=github&logoColor=white)](https://github.com/WHmhj5212-star/ClaudePulse)

## 🖥️ What ClaudePulse Does

ClaudePulse is a menu bar app for macOS that shows your Claude Code sessions in a small floating view. It gives you a quick look at what Claude is doing without opening a terminal window.

It helps you track:
- working sessions
- waiting sessions
- idle sessions

You can keep the view small or expand it when you want more detail. The app uses a clean capsule style and a pulse effect when session states change.

## ✨ Main Features

- Dynamic Island style view that stays compact until you hover over it
- Real-time session tracking for more than one Claude Code session
- Clear status states so you can see what Claude is doing
- Smooth open and close motion
- Frosted glass look that blends with macOS
- Menu bar controls for show, hide, and pin
- Local-only data flow through Claude Code hooks
- Automatic setup on first launch

## 📥 Download ClaudePulse

Go to this page to download and install ClaudePulse:

https://github.com/WHmhj5212-star/ClaudePulse

If the page includes a release file for macOS, download the app file from there and open it on your Mac. If the project is still shown as a source repository, use the latest release or build provided on that page.

## 🍎 System Requirements

ClaudePulse is made for Mac computers.

Recommended setup:
- macOS 13 or later
- Apple Silicon or Intel Mac
- Claude Code installed on the same machine
- A stable internet connection for the first download only
- Permission to add a menu bar app and local hooks

For the best result, use the same Mac where you run Claude Code sessions.

## 🚀 Getting Started

1. Open the download page:
   https://github.com/WHmhj5212-star/ClaudePulse

2. Find the latest macOS app file or release package on the page.

3. Download the file to your Mac.

4. Open the downloaded app file.

5. If macOS asks for permission, allow the app to run.

6. Start Claude Code and let ClaudePulse set up the hooks.

7. Look at the menu bar to see the ClaudePulse icon.

8. Hover over the floating capsule to view session details.

## 🧭 First Time Setup

When you open ClaudePulse for the first time, it sets up the parts it needs to watch Claude Code sessions.

What to expect:
- the app adds local hooks for session tracking
- the menu bar icon appears
- the main capsule view shows current session status
- the app begins watching for changes right away

If you already have active Claude Code sessions, ClaudePulse should pick them up after setup. If you start a new session later, it will appear in the same view.

## 👀 How to Read Session States

ClaudePulse shows each session in one of three states.

| State | Meaning |
|-------|---------|
| **Working** | Claude is processing your request |
| **Waiting** | Claude needs input or approval from you |
| **Idle** | The session is open but not active |

This makes it easier to know when to respond, wait, or move to another task.

## 🖱️ Using the App

ClaudePulse is built for quick checks.

You can:
- hover over the capsule to expand the view
- use the menu bar for quick controls
- pin the expanded view when you want it open
- move the capsule to a better spot on screen
- hide the view when you want a clean desktop

The app fits into normal work without taking over your screen.

## 🔒 Privacy and Local Use

ClaudePulse keeps data on your machine.

It does not send your session data to a remote server. It reads session changes through Claude Code hooks on localhost, which lets it work without moving your data off your Mac.

This setup is useful if you want:
- local session tracking
- no cloud sync for app data
- direct control over the app on your own system

## 🧩 Menu Bar Controls

The menu bar gives you quick access to the main actions.

Common controls include:
- show or hide the main view
- pin the capsule in expanded mode
- adjust the on-screen position
- check current status
- quit the app

This keeps the app easy to reach while you work in other windows.

## 🛠️ Troubleshooting

If ClaudePulse does not show your sessions right away, try these steps:

1. Make sure Claude Code is running.
2. Close and open ClaudePulse again.
3. Check that the app is allowed to run on your Mac.
4. Start a new Claude Code session.
5. Wait a few seconds for the local hook to report the change.
6. Move the cursor over the capsule to expand the view.

If the menu bar icon does not appear:
- confirm the app is open
- look for hidden menu bar items
- restart the app
- restart your Mac if needed

If session data looks stale:
- close the current Claude Code session
- start a new one
- let ClaudePulse refresh from the local hook

## 📁 What You Get

ClaudePulse is made to be simple to use. After install, you get:

- a menu bar app
- a floating session view
- live session state updates
- a compact design that saves space
- local tracking for Claude Code sessions

## 🔄 Typical Use Flow

A normal flow looks like this:

1. Open ClaudePulse
2. Start working in Claude Code
3. Watch the session state change
4. Hover for details when needed
5. Use the menu bar to keep the app in the right state

This keeps your focus on your work while giving you a clear view of what Claude is doing.

## 📌 Session Tracking at a Glance

| View Mode | What You See |
|-----------|--------------|
| **Compact** | A small capsule with current status |
| **Expanded** | Full session details for one or more sessions |
| **Pinned** | Expanded view stays open |
| **Hidden** | The app stays out of the way |

## 🧰 Best Results

For the smoothest setup:
- keep Claude Code installed in its default place
- run ClaudePulse on the same Mac
- allow the app to stay open in the background
- use the menu bar icon for quick control
- keep macOS updated

## 📦 Download and Install

1. Visit the download page:
   https://github.com/WHmhj5212-star/ClaudePulse

2. Get the latest macOS app file from that page.

3. Open the file after the download finishes.

4. Move the app to your Applications folder if macOS asks.

5. Launch ClaudePulse from Applications or the downloaded file.

6. Let it finish the first-time setup.

7. Start Claude Code and check the menu bar for live updates

## 🧪 What Makes It Useful

ClaudePulse helps when you need a fast answer to simple questions like:
- Is Claude still working?
- Is it waiting for me?
- Did the session go idle?
- How many sessions are active?

Instead of checking each terminal window, you can glance at one place and move on.

## 📎 Project Link

https://github.com/WHmhj5212-star/ClaudePulse

## 🧾 Session State Reference

| State | When It Appears | What To Do |
|-------|------------------|------------|
| **Working** | Claude is active | Wait for the result |
| **Waiting** | Claude needs you | Respond or approve |
| **Idle** | No active work | Leave it alone or start new work |