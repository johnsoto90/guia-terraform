#!/bin/bash

# Carga .env y crea las variables de entorno
set -a
source .env
set +a

# Actualiza el sistema y instala los paquetes necesarios
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl zip unzip nginx mysql-server

# Instala PHP y sus extensiones
sudo apt install -y php php-cli php-fpm php-json php-pdo php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath

# Remueve Apache para que no haya conflictos con Nginx
sudo systemctl stop apache2
sudo systemctl disable apache2
sudo apt purge apache2

# Instala Composer
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Crea el archivo de configuración de Nginx para Laravel
sudo tee /etc/nginx/sites-available/laravel <<EOL
server {
    listen 80;
    server_name your_domain;
    root /var/www/$PROJECT_NAME/public;
    index index.php index.html index.htm;

    location / {
         try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL
# Remueve el archivo de configuración de Nginx por defecto
sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/sites-available/default

sudo ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

# Configura MySQL
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_PASSWORD'; FLUSH PRIVILEGES;"
sudo mysql_secure_installation

# Crea la base de datos y el usuario para Laravel
sudo mysql -u root -p -e "CREATE DATABASE $DB_DATABASE; CREATE USER '$DB_USERNAME'@'localhost' IDENTIFIED BY '$DB_PASSWORD'; GRANT ALL PRIVILEGES ON $DB_DATABASE.* TO '$DB_USERNAME'@'localhost'; FLUSH PRIVILEGES;"

# Clona el repositorio de GitHub y lo coloca en la carpeta de Nginx
git clone $REPO /var/www/$PROJECT_NAME

# Cambia los permisos de la carpeta del proyecto
sudo chown -R www-data:www-data /var/www/$PROJECT_NAME
sudo chmod -R 755 /var/www/$PROJECT_NAME/storage

# Instala las dependencias de Larave y crea el archivo .env
cd /var/www/$PROJECT_NAME
composer install
cp .env.example .env
php artisan key:generate

# Modifica el archivo .env con los datos de la base de datos
sed -i "s/DB_DATABASE=laravel/DB_DATABASE=$DB_DATABASE/" .env
sed -i "s/DB_USERNAME=root/DB_USERNAME=$DB_USERNAME/" .env
sed -i "s/DB_PASSWORD=/DB_PASSWORD=$DB_PASSWORD/" .env

# Crea las tablas en la base de datos y agrega los datos de prueba
php artisan migrate --seed
