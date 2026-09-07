# set zsh as default shell if in codespace
if [ -n "$CODESPACES" ]; then # -n returns true if terminal var is not empty
    sudo chsh "$(id -un)" --shell "/usr/bin/zsh"
fi

# set time zone to central time
export TZ="America/Chicago"

# custom prompt configuration
PROMPT="%F{219}%B%S aszm %s%b %1~ %f" # left: pink foreground / text color, bold, standout mode (swaps foreground + background), current folder
RPROMPT="%F{219}%D{%Y-%m-%d} @ %T%f" # right: pink foreground / text color, custom date (ISO 8601), 24hr time

# sync settings from dotfiles in repo
syncrc() { # rc = run commands
    # set the correct dotfiles directory path based on environment
    local dir="$HOME/dotfiles" # dotfiles directory path in Mac ($HOME is universal systmem path, expands to /Users/username)
    if [ -n "$CODESPACES" ]; then # [ is command / shortcut alias for test (need space after/before), ] is last arg (need space before)
        dir="/workspaces/.codespaces/.persistedshare/dotfiles" # dotfiles directory path in codespace
    fi # end if statements (like closing bracket)

    # ensure dotfiles directory exists
    if [ ! -d "$dir" ]; then # -d returns true if directory exists, ! reverses condition
        print -P "%F{196}%BError: Dotfiles directory not found at $dir%b%f" # print is exclusive to zsh (echo has  multi-shell compatibility), -P interprets prompt codes (red foreground / text color, bold)
        return 1 # error state
    fi

    # push edits from Mac to GitHub
    if [ -z "$CODESPACES" ]; then # -z returns true if str is empty
        print -P "%F{213}Local Mac detected. Backing up and pushing changes to GitHub...%f" # magenta foreground / text color
        (
			# && is safety link operator (runs next command if previous command was successful), \ is line continuation character (treats next line as part of same command, must be last char on line)
            cd "$dir" && \
            git add . && \
            git commit -m "Update dotfiles ($(date '+%Y-%m-%d %H:%M:%S'))" && \
            git push origin main
        )
		source ~/.zshrc # source reads + executes contents of file
        print -P "%F{46}Mac configurations updated and synced to GitHub successfully!%f" # green foreground / text color

    # pull updates from GitHub
    else
        print -P "%F{213}GitHub Codespace detected. Fetching latest configurations...%f" # magenta foreground / text color
        (cd "$dir" && git pull) && cat "$dir/.zshrc" > ~/.zshrc && source ~/.zshrc # () creates subshell (end up in directory you started), cat = concatenate, > overwrites file or creates it if doesn't exist (>> appends to file or creates if nonexistent)
        print -P "%F{46}Codespace configurations updated successfully!%f" # green foreground / text color
    fi
}

# git automation (stage, commit, push)
ghpush() {
	# ensure msg was provided
	if [ -z "$1" ]; then # $1 is 1st arg after command
		print -P "%F{196}%BError: Please provide a commit message.%b%f" # red foreground / text color, bold
		print -P "%F{45}Example: ghpush \"Commit message\"%f" # cyan foreground / text color
		return 1
	fi

	# get current branch name
	local branch=$(git branch --show-current) # no spaces around = (if space before =, terminal thinks = is separate command)

	# stage, commit, push to current branch
	git add . && git commit -m "$1" && git push origin "$branch"
}

# compile + execute C++ files
runcpp() {
    # ensure file name was provided
    if [ -z "$1" ]; then
        print -P "%F{196}%BError: Please provide a C++ file name.%b%f" # red foreground / text color, bold
        print -P "%F{45}Example: runcpp main.cpp%f" # cyan foreground / text color
        return 1
    fi

    # choose compiler version
    local compiler="g++"
    if command -v g++-16 >/dev/null 2>&1; then # command -v checks if tool exists on system path, >/dev/null 2>&1 silences terminal (hides warning)
        compiler="g++-16"
    fi

    # strip extension, compile, run if successful
	local executable="${1%.*}"
    $compiler -std=c++23 "$1" -o "$executable" && "./$executable"
}
