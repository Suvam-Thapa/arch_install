Usr_Conf_Dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

U_say () {
echo -ne " 

╔══╦╗─────╔╗─╔╗╔╗───╔╗──╔═╦╗──────────╔╗╔╗─────╔══╗
║══╣╚╦═╗╔╦╣╚╗║╚╣╚╦═╗╠╬═╦╣═╣╚╦═╗╔╗╔╗╔═╗║╚╬╬═╦═╦╗╚═╗║
╠══║╔╣╬╚╣╔╣╔╣║╔╣║║╩╣║║║║╠═║╔╣╬╚╣╚╣╚╣╬╚╣╔╣║╬║║║║─╔╔╝
╚══╩═╩══╩╝╚═╝╚═╩╩╩═╝╚╩╩═╩═╩═╩══╩═╩═╩══╩═╩╩═╩╩═╝─╠╣
────────────────────────────────────────────────╚╝

" 
while true; do
    read -p "(Yy/Nn): " yn
    case $yn in
        [Yy]* )
            echo "Installation started."
        break;;
        [Nn]* ) 
            exit;
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done
}
U_say

source $Usr_Conf_Dir/aur_helper.sh

source $Usr_Conf_Dir/install_package.sh

