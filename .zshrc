# set zsh as default shell if in codespace
if [ -n "$CODESPACES" ]; then # -n returns true if str / terminal var is not empty
    sudo chsh "$(id -un)" --shell "/usr/bin/zsh"
fi

# set time zone to central time
export TZ="America/Chicago"

# custom prompt configuration
PROMPT="%F{219}%B%S aszm %s%b %1~ %% %f"
RPROMPT="%F{219}%D{%Y-%m-%d} @ %T%f"

# compile and execute C++ files
runcpp() { g++-16 -std=c++23 "$1" -o "${1%.*}" && "./${1%.*}"; } # only need semicolon at end if declaring entire func in one line

# git automation (stage, commit, push)
ghpush() {
	# check if msg was provided
	if [ -z "$1" ]; then # -z returns true if str is empty, $1 is 1st arg after command
		echo "Error: Please provide a commit message."
		return 1 # error state
	fi # end if statements (like closing bracket)

	# get current branch name
	local branch=$(git branch --show-current) # no spaces around = (if space before =, terminal thinks = is separate command)

	# stage, commit, and push to current branch
	git add . && git commit -m "$1" && git push origin "$branch"
}
