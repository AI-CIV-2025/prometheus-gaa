# 🎯 Tmux for Complete Beginners - Quick Start Guide

## What is tmux?
Think of tmux as a **window manager for your terminal**. It lets you:
- Run programs that keep running even after you disconnect
- Split your terminal into multiple panes
- Have multiple "tabs" (windows) in one terminal
- Detach and reattach to sessions (perfect for Claude Code!)

## Essential Commands You Need (Just 5!)

### 1. Start tmux with a named session
```bash
tmux new -s claude
```
This creates a new session called "claude". You'll see a green bar at the bottom.

### 2. Detach from tmux (leave it running)
Press: `Ctrl+B` then `D`
- Hold Ctrl and B together
- Release both
- Press D
- You're back to normal terminal, but tmux keeps running!

### 3. List your tmux sessions
```bash
tmux ls
```
Shows all running sessions.

### 4. Reattach to your session
```bash
tmux attach -t claude
```
You're back in your session exactly where you left it!

### 5. Kill a session (when done)
```bash
tmux kill-session -t claude
```

## Your Specific Use Case: Running Claude Code

### Step 1: Start tmux
```bash
tmux new -s claude
```

### Step 2: Run Claude Code inside tmux
```bash
claude
```

### Step 3: Detach (leave Claude running)
Press: `Ctrl+B` then `D`

### Step 4: Your Claude is now running in background!
You can close your terminal, come back later, and reattach:
```bash
tmux attach -t claude
```

## The Magic Part: Auto-Wake System

Once Claude is running in tmux, you can send it messages from outside:
```bash
tmux send-keys -t claude "Wake up and check agents!" Enter
```

This types the message INTO Claude's input box and presses Enter!

## Visual Guide

```
Normal Terminal:
┌────────────────┐
│ $ claude       │ <- If you close terminal, Claude dies
└────────────────┘

With tmux:
┌────────────────┐
│ [tmux: claude] │ <- Green bar shows you're in tmux
│ $ claude       │ <- Keeps running even if you disconnect!
└────────────────┘
```

## Quick Practice Session

Try this right now:
```bash
# 1. Start tmux
tmux new -s test

# 2. Run something simple
echo "Hello from tmux!"

# 3. Detach (Ctrl+B, then D)

# 4. Check it's still there
tmux ls

# 5. Reattach
tmux attach -t test

# 6. Kill it when done
tmux kill-session -t test
```

## Common Issues & Solutions

**"Sessions should be nested with care"**
- You're already in tmux! Just run your command.

**"No session found"**
- Check with `tmux ls` to see session names

**"Can't see the green bar"**
- You might not be in tmux. The status bar is at the bottom.

## Pro Tips for Claude Code

1. **Name your session "claude"** - easier to remember
2. **The green bar shows useful info** - session name, time, etc.
3. **You can scroll up** - Press `Ctrl+B` then `[` to enter scroll mode, `q` to exit
4. **Multiple windows** - `Ctrl+B` then `c` creates a new window (like a tab)

## Your Next Steps

1. Exit Claude Code (if running)
2. Start tmux: `tmux new -s claude`  
3. Run Claude: `claude`
4. Start the agents: `cd /home/corey/projects/GAA/gaa-5-testing && ./start.sh`
5. Detach: `Ctrl+B` then `D`
6. Run the wake setup: `./quick_wake_setup.sh`

That's it! You now know enough tmux to use the auto-wake system! 🚀