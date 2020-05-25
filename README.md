Получение сертификата с помощью Certbot в manual mode через хуки

[x] - yandex dns

#### Сборка образа

`docker build -t ba6ayaga/certbot-hooks .`

#### Запуск контейнера и получение сертификата

`docker run -it -e 'TEST=true' -e 'DOMAINS=YOUR_DOMAINS' -e 'PROVIDER=yandex' -e 'PLUGIN=certonly' -e 'EMAIL=YOUR_EMAIL' -e 'PddToken=YOUR_TOKEN' ba6ayaga/certbot-hooks`
