# Author: Austin
#!/bin/bash
#
# This script configure some global options in git like aliases, credential helper, user name and email. 



echo ""
echo "Configuring git..."
echo "Write your git username"
read USER
DEFAULT_EMAIL="$USER@users.noreply.github.com"
read -p "Write your git email [Press enter to accept the private email $DEFAULT_EMAIL]: " EMAIL
EMAIL="${EMAIL:-${DEFAULT_EMAIL}}"

echo "Configuring global user name and email..."
git config --global user.name "$USER"
git config --global user.email "$EMAIL"

echo "Configuring global aliases..."
git config --global alias.ci commit
git config --global alias.st status
git config --global core.editor "vim"
git config --global credential.helper 'cache --timeout=36000'

read -r -p "Do you want to add ssh credentials for git? [y/n] " RESP
RESP=${RESP,,}    # tolower (only works with /bin/bash)
if [[ $RESP =~ ^(yes|y)$ ]]
then
    echo "Configuring git ssh access..."
    ssh-keygen -t rsa -b 4096 -C "$EMAIL"
    echo "This is your public key. To activate it in github, got to settings, SHH and GPG keys, New SSH key, and enter the following key:"
    cat ~/.ssh/id_rsa.pub
    echo ""
    echo "To work with the ssh key, you have to clone all your repos with ssh instead of https. For example, for this repo you will have to use the url: git@github.com:miguelgfierro/scripts.git"
fi

if [ "$(uname)" == "Darwin" ]; then # Mac OS X platform  
	echo "Setting autocompletion"
	AUTOCOMPLETION_URL="https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
	AUTOCOMPLETION_PATH=/opt/local/etc/bash_completion.d
	AUTOCOMPLETION_SCRIPT=git-completion.bash 
	sudo mkdir -p $AUTOCOMPLETION_PATH
	sudo curl  -o $AUTOCOMPLETION_PATH/$AUTOCOMPLETION_SCRIPT $AUTOCOMPLETION_URL
	source $AUTOCOMPLETION_PATH/$AUTOCOMPLETION_SCRIPT
	echo "source $AUTOCOMPLETION_PATH/$AUTOCOMPLETION_SCRIPT" >> ~/.bash_profile
fi
echo ""
echo "git configured"
