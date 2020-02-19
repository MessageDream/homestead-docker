wget -q -P /usr/local/src/ https://studygolang.com/dl/golang/go1.13.5.linux-amd64.tar.gz
tar -zxf /usr/local/src/go1.13.5.linux-amd64.tar.gz -C /usr/local/
rm -f /usr/local/src/go1.13.5.linux-amd64.tar.gz
echo "export GOROOT=/usr/local/go" | tee -a /etc/profile.d/golang.sh /etc/zsh/zshenv
# echo "export GOOS=linux" | tee -a /etc/profile.d/golang.sh /etc/zsh/zshenv
# echo 'export GOTOOLDIR==$GOROOT/pkg/tool/linux_amd64' | tee -a /etc/profile.d/golang.sh /etc/zsh/zshenv
echo "export GO111MODULE=on" | tee -a /etc/profile.d/golang.sh /etc/zsh/zshenv
echo "export GOPROXY=https://goproxy.cn,direct" | tee -a /etc/profile.d/golang.sh /etc/zsh/zshenv
echo 'export PATH=$PATH:$GOROOT/bin' | tee -a /etc/profile.d/golang.sh /etc/zsh/zshenv
chmod 755 /etc/profile.d/golang.sh