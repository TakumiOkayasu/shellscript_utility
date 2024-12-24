#!/bin/bash

set -e

echo "${0} start!"
echo "Var = ${USER_NAME}"

DATE=$(TZ='Asia/Tokyo' date '+%Y-%m-%d %H:%M:%S %z')
echo "  ${0} create $DATE"

# gitの補完スクリプトをダウンロードし、シェルに追加
curl -o /usr/share/bash-completion/completions/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
curl -o /usr/share/bash-completion/completions/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

# ~/.bashrcにPS1とunset PROMPT_COMMANDを追記
cat <<-'EOF' > /home/${USER_NAME}/.bashrc
source /usr/share/bash-completion/completions/git-completion.bash
source /usr/share/bash-completion/completions/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM=auto
unset PROMPT_COMMAND
export PS1="\[\033[01;32m\]\u@\h \[\033[01;33m\] \w \[\033[01;31m\]\$(__git_ps1 '(%s)') \n\[\033[01;34m\]$(if [ \$(id -u) -eq 0 ]; then echo '#'; else echo '\$'; fi) \[\033[00m\]"
EOF

chmod a+x /usr/share/bash-completion/completions/git*

echo "${0} finished!"
