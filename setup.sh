ln -s ~/nvmcfg/.zshrc ~/.zshrc
ln -s ~/nvmcfg/.bash_profile ~/.bash_profile

ln -s ~/nvmcfg/init.lua ~/.config/nvim/init.lua

ln -s ~/nvmcfg/plugins ~/.config/nvim/lua/plugins

ln -s ~/nvmcfg/vimopt.lua ~/.config/nvim/lua/vimopt.lua
ln -s ~/nvmcfg/keymap.lua ~/.config/nvim/lua/keymap.lua
ln -s ~/nvmcfg/autocmd.lua ~/.config/nvim/lua/autocmd.lua
ln -s ~/nvmcfg/usercmd.lua ~/.config/nvim/lua/usercmd.lua

ln -s ~/nvmcfg/.stylua.toml ~/.config/nvim/.stylua.toml

ln -s ~/nvmcfg/kitty.conf ~/.config/kitty/kitty.conf

ln -s ~/nvmcfg/protozerg.conf ~/.config/kitty/protozerg.conf
ln -s ~/nvmcfg/protozerg.css ~/.config/wofi/protozerg.css
ln -s ~/nvmcfg/protozerg.qute.py ~/.config/qutebrowser/config.py

ln -s ~/nvmcfg/.clangd ~/.clangd

wofi --show dmenu --style ~/.config/wofi/protozerg.css
