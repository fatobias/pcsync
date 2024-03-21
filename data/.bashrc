#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -al'
alias la='ls -A'

#alias vim='nvim'

# Add the following lines to your ~/.bashrc file
PS1='|\w> '

setxkbmap -option caps:escape

export PATH=$PATH:/usr/share/dotnet
export PATH=$PATH:~/.bin
export PATH="$PATH:$HOME/.local/bin"
ranger
export PATH="/home/borec/.bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/usr/share/dotnet:/home/borec/.bin:/home/borec/.local/bin"
