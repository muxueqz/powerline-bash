#!/usr/bin/env bash

__powerline() {

	# Unicode symbols
	local readonly PS_SYMBOL_DARWIN=''
	local readonly PS_SYMBOL_LINUX='$'
	local readonly PS_SYMBOL_OTHER='$'

	if [[ -z "$PS_SYMBOL" ]]; then
		case "$(uname)" in
		Darwin)
			PS_SYMBOL=$PS_SYMBOL_DARWIN
			;;
		Linux)
			PS_SYMBOL=$PS_SYMBOL_LINUX
			;;
		*)
			PS_SYMBOL=$PS_SYMBOL_OTHER
			;;
		esac
	fi

	gitStatus() {
		local readonly GIT_BRANCH_SYMBOL='⌥ '

		eval "$1=''"
		eval "$2=''"

		[ -x "$(which git)" ] || return

		local gitCommand="env LANG=C git"
		local branch="$($gitCommand symbolic-ref --short HEAD 2>/dev/null || $gitCommand describe --tags --always 2>/dev/null)"
		[ -n "$branch" ] || return

		local marks

		eval "$2='$marks'"
		eval "$1=' $GIT_BRANCH_SYMBOL$branch$marks '"
		return
	}

	ps1() {
		local readonly GIT_SEPARATOR=''

		local readonly WARN_FG="\[\033[1;33m\]"
		local readonly ALERT_FG="\[\033[0;31m\]"
		local readonly INFO_FG="\[\033[0;34m\]"
		local readonly SUCCESS_FG="\[\033[0;12m\]"
		local readonly COMMON_INV_FG="\[\033[0;30m\]"
		local readonly COMMON_FG="\[\033[1;37m\]"
		local readonly COMMON_LIGHT_FG="\[\033[0;36m\]"

		local readonly WARN_BG="\[\033[46m\]"
		local readonly ALERT_BG="\[\033[41m\]"
		local readonly INFO_BG="\[\033[44m\]"
		local readonly SUCCESS_BG="\[\033[46m\]"
		local readonly COMMON_BG="\[\033[40m\]"

		local readonly DIM="\[$(tput dim)\]"
		local readonly REVERSE="\[$(tput rev)\]"
		local readonly RESET="\[\033[0m\]"
		local readonly BOLD="\[$(tput bold)\]"

		local consoleBackColor="$COMMON_BG"
		local consoleColor="$COMMON_INV_FG"

		local isError=$?

		if [ $isError -eq 0 ]; then
			local consoleBackColor="$COMMON_BG"
			local consoleColor="$COMMON_INV_FG"
		else
			local consoleBackColor="$ALERT_BG"
			local consoleColor="$ALERT_FG"
		fi

		PS1="$INFO_BG$COMMON_FG \w $RESET"

		gitStatus gitInfo gitMarks

		if [ ${#gitMarks} != 0 ]; then
			local branchBackColor="$WARN_BG"
			local branchColor="$WARN_FG"
		else
			local branchBackColor="$SUCCESS_BG"
			local branchColor="$SUCCESS_FG"
		fi

		if shopt -q promptvars; then
			if [ ${#gitInfo} != 0 ]; then
				PS1+="$INFO_FG$branchBackColor$GIT_SEPARATOR$branchColor$branchBackColor${gitInfo}$COMMON_LIGHT_FG$consoleBackColor$GIT_SEPARATOR$RESET"
			else
				PS1+="$INFO_FG$consoleBackColor$GIT_SEPARATOR$RESET"
			fi
		else
			PS1+="$COMMON_FG$ALERT_BG$(gitInfo)$RESET"
		fi
		PS1+="$consoleBackColor$COMMON_FG $PS_SYMBOL $COMMON_BG$consoleColor$GIT_SEPARATOR$RESET"

		if [ $isError -ne 0 ]; then
			PS1+=" "
		fi
	}
	PROMPT_COMMAND=ps1
}

__powerline
unset __powerline
