# we need to flesh this out into a mini tuturial

echo "   _  _    __  ";
echo " _| || |_ |  |  Welcome to #!. This network has three rules:";
echo "|_  __  _||  | ";
echo " _| || |_ |  |  1. When people need help, teach. Don't do it for them";
echo "|_  __  _||__|  2. Don't use our resources for closed source projects";
echo "  |_||_|  (__)  3. Be excellent to each other";
echo "               ";
echo " Things to explore:";
echo " ";
echo "   * You are already in our IRC channel in \"tab 0\" of this \"tmux\" session";
echo "     Type <Ctrl-B> + 0 to get there and talk to us";
echo " ";
echo "   * You have public webspace at http://$USER.hashbang.sh";
echo "     Any files you create in your 'Public' folder will appear there";
echo " ";
echo "   * We have a wide range of tools to explore. If a tool you want is not";
echo "     available please ask in IRC and someone can probably make it happen";
echo " ";
echo " Also note you can get back here at any time via:";
echo " ";
echo " > ssh $USER@shell.hashbang.sh";
echo " ";
echo " To disable this message run \`rm .bash_profile\`";
echo " ";




# make sure this is an interactive session, then start tmux
[[ $- != *i* ]] && return
[[ -z "$TMUX" ]] && ~/.tmux_bootstrap
