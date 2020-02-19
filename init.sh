git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions

mkdir -p ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/incr
curl -o ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/incr/incr-0.2.zsh https://mimosa-pudica.net/src/incr-0.2.zsh

# sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"agnoster\"/' ~/.zshrc
sed -i 's/plugins=(git)/plugins=(git golang node npm npx yarn pip composer laravel vi-mode systemd supervisor autojump zsh-autosuggestions zsh-completions zsh-syntax-highlighting)/' ~/.zshrc

echo "export GOPATH=~/gopath" >> ~/.zshrc
echo 'export GOBIN=$GOPATH/bin' >> ~/.zshrc
echo 'export PATH=$PATH:$GOBIN' >> ~/.zshr

echo "source ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/incr/incr*.zsh" >> ~/.zshrc
echo "source ~/.profile"  >> ~/.zshrc

echo "alias vi='vim'" >> ~/.zshrc

echo "# npm" >> ~/.zshrc
echo "alias nst='npm start'" >> ~/.zshrc
echo "alias nin='npm install'" >> ~/.zshrc
echo "alias nind='npm install -D'" >> ~/.zshrc
echo "alias nins='npm install -S'" >> ~/.zshrc
echo "alias nb='npm run build'" >> ~/.zshrc
echo "alias ngin='npm install -g'" >> ~/.zshrc
echo "alias nrun='npm run'" >> ~/.zshrc