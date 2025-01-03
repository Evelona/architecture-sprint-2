# pymongo-api

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d --build
```

Заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

## Схемы

схемы прикрепила тут в файле Sprint2Task1.drawio, или можно открыть к google диск по ссылке https://drive.google.com/file/d/1YSeE9bhU8OilQPSHikK_R7Fa64kStVuy/view?usp=sharing


## Как проверить

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs