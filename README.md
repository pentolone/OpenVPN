# OpenVPN
Scripts to create CA, server config and client config in .ovpn format.
1) Create a folder openVPN in your $HOME
2) Install EasyRSA in $HOME/openVPN
3) Create a symbolic link in $HOME/openVPN ln -s EasyRSA<version> EasyRSA
4) Create a folder $HOME/openVPN/ca
5) Create a folder $HOME/openVPN/servers
5) Create a folder $HOME/openVPN/clients
6) Copy server.conf.example in $HOME/openVPN/servers
7) Copy client.conf in $HOME/openVPN/clients
8) Copy vars.example in $HOME/EasyRSA to $HOME/openVPN/ca/<your first server>
9) Change files according to your requirements
10) Create the first OpenVPN server

Let me know if something wrong or missed
