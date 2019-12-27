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

# Install Some PPAs
apt-get install -y software-properties-common curl
apt-add-repository ppa:nginx/development -y
apt-add-repository ppa:ondrej/php -y
apt-add-repository ppa:chris-lea/redis-server -y

# Update Package Lists
apt-get update

# Install ssh server
apt-get -y install openssh-server pwgen
mkdir -p /var/run/sshd
sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

# Basic packages
apt-get install -y sudo software-properties-common nano curl \
build-essential dos2unix gcc git git-flow libpcre3-dev apt-utils \
make python2.7-dev python-pip pip3 re2c supervisor unattended-upgrades whois vim zip unzip


# Create homestead user
adduser homestead
usermod -p $(echo secret | openssl passwd -1 -stdin) homestead
# Add homestead to the sudo group and www-data
usermod -aG sudo homestead
usermod -aG www-data homestead

# Timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# PHP
apt-get install -y php7.4 php7.4-bcmath php7.4-bz2 php7.4-cgi php7.4-cli php7.4-common php7.4-curl php7.4-dba php7.4-dev \
php7.4-enchant php7.4-fpm php7.4-gd php7.4-gmp php7.4-imap php7.4-interbase php7.4-intl php7.4-json php7.4-ldap \
php7.4-mbstring php7.4-mysql php7.4-odbc php7.4-opcache php7.4-pgsql php7.4-phpdbg php7.4-pspell php7.4-readline \
php7.4-snmp php7.4-soap php7.4-sqlite3 php7.4-sybase php7.4-tidy php7.4-xml php7.4-xmlrpc php7.4-xsl php7.4-zip

update-alternatives --set php /usr/bin/php7.4
update-alternatives --set php-config /usr/bin/php-config7.4
update-alternatives --set phpize /usr/bin/phpize7.4

# Install Composer
curl -sS https://getcomposer.org/installer | php
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
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.4/cli/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.4/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/cli/php.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.4/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.4/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.4/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.4/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.4/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/fpm/php.ini

printf "[openssl]\n" | tee -a /etc/php/7.4/fpm/php.ini
printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.4/fpm/php.ini

printf "[curl]\n" | tee -a /etc/php/7.4/fpm/php.ini
printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.4/fpm/php.ini

# Enable Remote xdebug
echo "xdebug.remote_enable = 1" >> /etc/php/7.4/mods-available/xdebug.ini
echo "xdebug.remote_autostart = 1" >> /etc/php/7.4/mods-available/xdebug.ini
echo "xdebug.remote_connect_back = 0" >> /etc/php/7.4/mods-available/xdebug.ini
echo "xdebug.remote_host = host.docker.internal" >> /etc/php/7.4/mods-available/xdebug.ini
echo "xdebug.remote_port = 9000" >> /etc/php/7.4/mods-available/xdebug.ini
echo "xdebug.var_display_max_depth = -1" >> /etc/php/7.4/mods-available/xdebug.ini
echo "xdebug.var_display_max_children = -1" >> /etc/php/7.4/mods-available/xdebug.ini
echo "xdebug.var_display_max_data = -1" >> /etc/php/7.4/mods-available/xdebug.ini
echo "xdebug.max_nesting_level = 512" >> /etc/php/7.4/mods-available/xdebug.ini
echo "opcache.revalidate_freq = 0" >> /etc/php/7.4/mods-available/opcache.ini
# Not xdebug when on cli
phpdismod -s cli xdebug

# Nginx & PHP-FPM
apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
nginx

# Copy fastcgi_params to Nginx because they broke it on the PPA
cat > /etc/nginx/fastcgi_params << EOF
fastcgi_param	QUERY_STRING		\$query_string;
fastcgi_param	REQUEST_METHOD		\$request_method;
fastcgi_param	CONTENT_TYPE		\$content_type;
fastcgi_param	CONTENT_LENGTH		\$content_length;
fastcgi_param	SCRIPT_FILENAME		\$request_filename;
fastcgi_param	SCRIPT_NAME			\$fastcgi_script_name;
fastcgi_param	REQUEST_URI			\$request_uri;
fastcgi_param	DOCUMENT_URI		\$document_uri;
fastcgi_param	DOCUMENT_ROOT		\$document_root;
fastcgi_param	SERVER_PROTOCOL		\$server_protocol;
fastcgi_param	GATEWAY_INTERFACE	CGI/1.1;
fastcgi_param	SERVER_SOFTWARE		nginx/\$nginx_version;
fastcgi_param	REMOTE_ADDR			\$remote_addr;
fastcgi_param	REMOTE_PORT			\$remote_port;
fastcgi_param	SERVER_ADDR			\$server_addr;
fastcgi_param	SERVER_PORT			\$server_port;
fastcgi_param	SERVER_NAME			\$server_name;
fastcgi_param	HTTPS				\$https if_not_empty;
fastcgi_param	REDIRECT_STATUS		200;
EOF

# Set The Nginx & PHP-FPM User
sed -i '1 idaemon off;' /etc/nginx/nginx.conf
sed -i "s/user www-data;/user homestead;/" /etc/nginx/nginx.conf
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

mkdir -p /run/php
touch /run/php/php7.4-fpm.sock
sed -i "s/user = www-data/user = homestead/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = homestead/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/;listen\.owner.*/listen.owner = homestead/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/;listen\.group.*/listen.group = homestead/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.4/fpm/pool.d/www.conf

# Install Node
curl --silent --location https://deb.nodesource.com/setup_12.x | bash -
apt-get install -y nodejs
npm install -g grunt-cli
npm install -g gulp-cli
npm install -g bower
npm install -g yarn

# golang
curl -o /usr/local/src/go1.13.5.linux-amd64.tar.gz https://studygolang.com/dl/golang/go1.13.5.linux-amd64.tar.gz
tar -zxvf /usr/local/src/go1.13.5.linux-amd64.tar.gz -C /usr/local/
echo "export GOROOT=/usr/local/go" >> /etc/profile
# echo "export GOOS=linux" >> /etc/profile
# echo "export GOARCH=amd64" >> /etc/profile
# echo "export GOHOSTOS=linux" >> /etc/profile
# echo "export GOTOOLDIR==$GOROOT/pkg/tool/linux_amd64" >> /etc/profile
echo "export GO111MODULE=on" >> /etc/profile
echo "export GOPROXY=https://goproxy.cn,direct" >> /etc/profile
echo "export PATH=$PATH:$GOROOT/bin" >> /etc/profile
export PATH=$PATH:$GOROOT/bin

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

#zsh 
apt-get install -y zsh
apt-get install -y powerline fonts-powerline
apt-get install -y autojump

su homestead <<'EOF'

git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions

mkdir -p ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/incr
curl -o ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/incr/incr-0.2.zsh https://mimosa-pudica.net/src/incr-0.2.zsh

sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"agnoster\"/' ~/.zshrc
sed -i 's/plugins=(git)/plugins=(git golang node npm npx yarn pip composer laravel laravel4 laravel5 vi-mode systemd supervisor autojump zsh-autosuggestions zsh-completions zsh-syntax-highlighting)/' ~/.zshrc

echo "source ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/incr/incr*.zsh" >> ~/.zshrc
echo "source ~/.profile"  >> ~/.zshrc

export GOPATH=~/Documents/gopath
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

echo "export GOPATH=$GOPATH" >> ~/.zshrc
echo 'export GOBIN=$GOPATH/bin' >> ~/.zshrc
echo 'export PATH=$PATH:$GOBIN' >> ~/.zshrc
echo "export GOCACHE=~/.cache/go-build" >> ~/.zshrc
echo "export GOENV=~/.config/go/env" >> ~/.zshrc


echo "# go remote debug" >> ~/.zshrc
echo "alias godebug=dlv debug --headless --listen \":9900\" --log --api-version 2" >> ~/.zshrc
echo "alias goattach=dlv attach --headless --listen \":9900\" --log --api-version 2" >> ~/.zshrc
echo "alias goexec=dlv exec --headless --listen \":9900\" --log --api-version 2" >> ~/.zshrc
echo "alias gobuild=go build -gcflags=\"all=-N -l\"" >> ~/.zshrc

echo "# npm" >> ~/.zshrc
echo "alias nst='npm start'" >> ~/.zshrc
echo "alias nin='npm install'" >> ~/.zshrc
echo "alias nind='npm install -D'" >> ~/.zshrc
echo "alias nins='npm install -S'" >> ~/.zshrc
echo "alias nb='npm run build'" >> ~/.zshrc
echo "alias ngin='npm install -g'" >> ~/.zshrc
echo "alias nrun='npm run'" >> ~/.zshrc

echo "autoload -U compinit && compinit" >> ~/.zshrc

go get -u -v github.com/mdempsky/gocode
go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs
go get -u -v github.com/ramya-rao-a/go-outline
go get -u -v github.com/acroca/go-symbols
go get -u -v golang.org/x/tools/cmd/guru
go get -u -v golang.org/x/tools/cmd/gorename
go get -u -v github.com/cweill/gotests/...
go get -u -v github.com/fatih/gomodifytags
go get -u -v github.com/josharian/impl
go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct
go get -u -v github.com/haya14busa/goplay/cmd/goplay
go get -u -v github.com/godoctor/godoctor
go get -u -v github.com/go-delve/delve/cmd/dlv
go get -u -v github.com/stamblerre/gocode
go get -u -v github.com/rogpeppe/godef
go get -u -v golang.org/x/tools/cmd/goimports
go get -u -v golang.org/x/lint/golint
go get -u -v golang.org/x/tools/gopls
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $GOBIN v1.21.1

EOF

apt-get -y autoremove;
apt-get -y clean;

usermod -s /bin/zsh homestead
