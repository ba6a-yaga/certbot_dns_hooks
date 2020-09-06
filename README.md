# certbot_dns_hooks

Получение сертификата с помощью Certbot в manual mode через хуки

- [x] - yandex dns
- [x] - cloudflare dns

#### Сборка образа

```bash
docker build -t ba6ayaga/certbot-hooks .
```

#### Запуск контейнера и получение сертификата

```bash
docker run -it -e 'DOMAINS=YOUR_DOMAIN' -e 'PROVIDER=cloudflare' -e 'PLUGIN=certonly' -e 'EMAIL=YOUR_EMAIL' -e 'TEST=true' -e 'Token=YOUR_TOKEN' -v $(pwd)/YOUR_PATH_TO/letsencrypt:/etc/letsencrypt:rw ba6ayaga/certbot-hooks
```
