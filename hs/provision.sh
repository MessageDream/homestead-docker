#!/usr/bin/env bash

# Laravel homestead original provisioning script
# https://github.com/laravel/settler

# Update Package List
apt-get update
apt-get upgrade -y

# Force Locale
apt-get install -y locales
echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
locale-gen en_US.UTF-8
export LANG=en_US.UTF-8

# Install ssh server
apt-get -y install openssh-server pwgen
mkdir -p /var/run/sshd
sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

# Basic packages
apt-get install -y sudo software-properties-common nano curl \
build-essential dos2unix gcc git git-flow libpcre3-dev apt-utils \
make python-dev python-pip python3-dev python3-pip re2c supervisor \
unattended-upgrades whois vim zip unzip imagemagick zsh

# update pip3
pip3 install --upgrade pip

# PPA
apt-add-repository ppa:ondrej/php -y

# Update Package Lists
apt-get update

# Create homestead user
adduser homestead
usermod -p $(echo secret | openssl passwd -1 -stdin) homestead
# Add homestead to the sudo group and www-data
usermod -aG sudo homestead
usermod -aG www-data homestead

# Timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# PHP
apt-get install -y php7.3-cli php7.3-dev \
php7.3-mysql php7.3-pgsql php7.3-sqlite3 php7.3-soap \
php7.3-json php7.3-curl php7.3-gd \
php7.3-gmp php7.3-imap php-xdebug \
php7.3-mbstring php7.3-zip \
php-pear php-apcu php-memcached php-redis \
php7.3-dom php7.3-bcmath php-imagick

# Nginx & PHP-FPM
apt-get install -y nginx php7.3-fpm

# Install Composer
curl -sS https://getcomposer.org/installer | php -d default_socket_timeout=3600
# php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
# chmod +x composer-setup.php
# php composer-setup.php
# php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

# Add Composer Global Bin To Path
printf "\nPATH=\"/home/homestead/.composer/vendor/bin:\$PATH\"\n" | tee -a /home/homestead/.profile

# Laravel Envoy
su homestead <<'EOF'
/usr/local/bin/composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
/usr/local/bin/composer global require hirak/prestissimo
/usr/local/bin/composer global require "laravel/envoy=^1.6"
/usr/local/bin/composer global require "laravel/installer=^3.0.1"
/usr/local/bin/composer global require "laravel/lumen-installer=^1.1"
/usr/local/bin/composer global require "laravel/spark-installer=dev-master"
/usr/local/bin/composer global require "slince/composer-registry-manager=^2.0"
EOF

# Set Some PHP CLI Settings
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.3/cli/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.3/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.3/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.3/cli/php.ini

sed -i "s/.*daemonize.*/daemonize = no/" /etc/php/7.3/fpm/php-fpm.conf
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.3/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.3/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.3/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.3/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.3/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.3/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.3/fpm/php.ini

printf "[openssl]\n" | tee -a /etc/php/7.3/fpm/php.ini
printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.3/fpm/php.ini

printf "[curl]\n" | tee -a /etc/php/7.3/fpm/php.ini
printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.3/fpm/php.ini

# Enable Remote xdebug
echo "xdebug.remote_enable = 1" >> /etc/php/7.3/fpm/conf.d/20-xdebug.ini
echo "xdebug.remote_autostart = 1" >> /etc/php/7.3/fpm/conf.d/20-xdebug.ini
echo "xdebug.remote_connect_back = 0" >> /etc/php/7.3/fpm/conf.d/20-xdebug.ini
echo "xdebug.remote_host = host.docker.internal" >> /etc/php/7.3/fpm/conf.d/20-xdebug.ini
echo "xdebug.remote_port = 9000" >> /etc/php/7.3/fpm/conf.d/20-xdebug.ini
echo "xdebug.var_display_max_depth = -1" >> /etc/php/7.3/fpm/conf.d/20-xdebug.ini
echo "xdebug.var_display_max_children = -1" >> /etc/php/7.3/fpm/conf.d/20-xdebug.ini
echo "xdebug.var_display_max_data = -1" >> /etc/php/7.3/fpm/conf.d/20-xdebug.ini
echo "xdebug.max_nesting_level = 512" >> /etc/php/7.3/fpm/conf.d/20-xdebug.ini

# Not xdebug when on cli
phpdismod -s cli xdebug

# Set The Nginx & PHP-FPM User
sed -i '1 idaemon off;' /etc/nginx/nginx.conf
sed -i "s/user www-data;/user homestead;/" /etc/nginx/nginx.conf
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

mkdir -p /run/php
touch /run/php/php7.3-fpm.sock
sed -i "s/user = www-data/user = homestead/" /etc/php/7.3/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = homestead/" /etc/php/7.3/fpm/pool.d/www.conf
sed -i "s/;listen\.owner.*/listen.owner = homestead/" /etc/php/7.3/fpm/pool.d/www.conf
sed -i "s/;listen\.group.*/listen.group = homestead/" /etc/php/7.3/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.3/fpm/pool.d/www.conf

# Install Node
curl --silent --location https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt-get install -y nodejs

npm install -g -y yarn
npm install -g grunt-cli
npm install -g gulp-cli

# golang
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

# Install SQLite
apt-get install -y sqlite3 libsqlite3-dev

# Memcached
apt-get install -y memcached

# Beanstalkd
apt-get install -y beanstalkd
sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd

# Redis
apt-get install -y redis-server
sed -i "s/daemonize yes/daemonize no/" /etc/redis/redis.conf

# Configure default nginx site
block="server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;
    root /var/www/html;
    server_name localhost;
    index index.html index.htm index.php;
    charset utf-8;
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }
    access_log off;
    error_log  /var/log/nginx/app-error.log error;
    error_page 404 /index.php;
    sendfile off;
    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php7.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi.conf;
    }
    location ~ /\.ht {
        deny all;
    }
}
"

rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default

cat > /etc/nginx/sites-enabled/default
echo "$block" > "/etc/nginx/sites-enabled/default"

# oh my zsh 
apt-get install -y powerline fonts-powerline autojump

su homestead <<'EOF'

git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions

mkdir -p ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/incr
curl -o ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/incr/incr-0.2.zsh https://mimosa-pudica.net/src/incr-0.2.zsh

sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"agnoster\"/' ~/.zshrc
sed -i 's/plugins=(git)/plugins=(git golang node npm npx yarn pip composer laravel vi-mode systemd supervisor autojump zsh-autosuggestions zsh-completions zsh-syntax-highlighting)/' ~/.zshrc

echo "source ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/incr/incr*.zsh" >> ~/.zshrc
echo "source ~/.profile"  >> ~/.zshrc

export GOPATH=~/gopath
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

echo "export GOPATH=~/gopath" >> ~/.zshrc
echo 'export GOBIN=$GOPATH/bin' >> ~/.zshrc
echo 'export PATH=$PATH:$GOBIN' >> ~/.zshrc
echo "export GOCACHE=~/.cache/go-build" >> ~/.zshrc
echo "export GOENV=~/.config/go/env" >> ~/.zshrc


echo "# go remote debug" >> ~/.zshrc
echo "alias godebug='dlv debug --headless --listen \":9900\" --log --api-version 2'" >> ~/.zshrc
echo "alias goattach='dlv attach --headless --listen \":9900\" --log --api-version 2'" >> ~/.zshrc
echo "alias goexec='dlv exec --headless --listen \":9900\" --log --api-version 2'" >> ~/.zshrc
echo "alias gobuild='go build -gcflags=\"all=-N -l\"'" >> ~/.zshrc

echo "# npm" >> ~/.zshrc
echo "alias nst='npm start'" >> ~/.zshrc
echo "alias nin='npm install'" >> ~/.zshrc
echo "alias nind='npm install -D'" >> ~/.zshrc
echo "alias nins='npm install -S'" >> ~/.zshrc
echo "alias nb='npm run build'" >> ~/.zshrc
echo "alias ngin='npm install -g'" >> ~/.zshrc
echo "alias nrun='npm run'" >> ~/.zshrc

echo "# artisan" >> ~/.zshrc
echo "alias pada='php artisan dump-autoload'" >> ~/.zshrc
echo "alias parol='php artisan routes'" >> ~/.zshrc
echo "alias pavp='php artisan vendor:publish'" >> ~/.zshrc
echo "alias pamre='php artisan migrate:reset'" >> ~/.zshrc
echo "alias pakg='php artisan key:generate'" >> ~/.zshrc
echo "alias paop='php artisan optimize'" >> ~/.zshrc
echo "alias pacc='php artisan clear-compiled'" >> ~/.zshrc
echo "alias pacm='php artisan command:make'" >> ~/.zshrc
echo "alias pami='php artisan migrate:install'" >> ~/.zshrc
echo "alias pammg='php artisan make:migration'" >> ~/.zshrc


echo "autoload -U compinit && compinit" >> ~/.zshrc

/usr/local/go/bin/go get -u github.com/mdempsky/gocode
/usr/local/go/bin/go get -u github.com/uudashr/gopkgs/cmd/gopkgs
/usr/local/go/bin/go get -u github.com/ramya-rao-a/go-outline
/usr/local/go/bin/go get -u github.com/acroca/go-symbols
/usr/local/go/bin/go get -u golang.org/x/tools/cmd/guru
/usr/local/go/bin/go get -u golang.org/x/tools/cmd/gorename
/usr/local/go/bin/go get -u github.com/cweill/gotests/...
/usr/local/go/bin/go get -u github.com/fatih/gomodifytags
/usr/local/go/bin/go get -u github.com/josharian/impl
/usr/local/go/bin/go get -u github.com/davidrjenni/reftools/cmd/fillstruct
/usr/local/go/bin/go get -u github.com/haya14busa/goplay/cmd/goplay
/usr/local/go/bin/go get -u github.com/godoctor/godoctor
/usr/local/go/bin/go get -u github.com/go-delve/delve/cmd/dlv
/usr/local/go/bin/go get -u github.com/stamblerre/gocode
/usr/local/go/bin/go get -u github.com/rogpeppe/godef
/usr/local/go/bin/go get -u golang.org/x/tools/cmd/goimports
/usr/local/go/bin/go get -u golang.org/x/lint/golint
/usr/local/go/bin/go get -u golang.org/x/tools/gopls
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $GOBIN v1.21.0

mkdir -p $WORK_DIR
EOF

apt-get -y autoremove;
apt-get -y clean;

usermod -s /bin/zsh homestead