# Find commands executed in history

A Bash script to deduplicate and optionally filter your command history (`.bash_history` or `.zsh_history`). Ideal for saving frequently used or important terminal commands.

---

## 📋 What does it do?

- Extracts commands from your shell history (Bash or Zsh).
- Removes duplicates.
- **Optional:** filters commands by a given keyword.
- Saves the results to a file named `deduplicated_commands.txt`.

---

## 🚀 How to use it

### 1. Save the script

Save the content to a file named `find-cmd.sh`.

### 2. Make it executable

```bash
chmod +x find-cmd.sh
```

### 3. Run the script

#### 🔹 Basic usage (no filter)

```bash
./find-cmd.sh
```

This will create `deduplicated_commands.txt` containing all unique commands from your history.

#### 🔹 Filtered usage

```bash
./find-cmd.sh -s docker
# or
./find-cmd.sh --search docker
```

This will include only unique commands containing the keyword `docker`.

---

## 📁 Output file

The result is saved in the current directory as:

```
deduplicated_commands.txt
```

You can open it with any text editor or preview it using:

```bash
cat deduplicated_commands.txt
```

---

## 🐚 Shell support

The script automatically detects your current shell and looks for the history in:

- `~/.bash_history` for Bash
- `~/.zsh_history` for Zsh

⚠️ Other shells are currently not supported.

---

## 🆘 Help

```bash
./find-cmd.sh --help
```

---

## 💡 Practical example

```bash
./find-cmd.sh -s kubectl
```

This command will generate a file with all unique terminal commands that include `kubectl`.

---

## 📄 License

This script is free to use and modify. Feel free to share it if you find it useful!

