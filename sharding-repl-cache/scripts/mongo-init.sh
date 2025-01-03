#!/bin/sh

# Настраиваем сервер конфигурации
docker compose exec -T configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate({
    _id: "config_server",
    configsvr: true,
    members: [{
        _id: 0,
        host: "configSrv:27017"
    }]
});
EOF

# Настраиваем шард1
docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
rs.initiate({
    _id: "shard1",
    members: [{
        _id: 0,
        host: "shard1:27018"
    },
    {_id: 1, host: "shard1_2:27022"},
    {_id: 2, host: "shard1_3:27023"}]
});
EOF

# Настраиваем шард2
docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
rs.initiate({
    _id: "shard2",
    members: [{
        _id: 0,
        host: "shard2:27019"
    },
    {_id: 1, host: "shard2_2:27024"},
    {_id: 2, host: "shard2_3:27025"}]
});
EOF

# Делаю паузу на 2 секунды, чтобы сервер конфигурации и шарды успели установиться и настроиться
sleep 2

# Настраиваем роутер1
docker compose exec -T mongos_router1 mongosh --port 27020 --quiet <<EOF
sh.addShard( "shard1/shard1:27018");
sh.addShard( "shard2/shard2:27019");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
EOF

# Настраиваем роутер2
docker compose exec -T mongos_router2 mongosh --port 27021 --quiet <<EOF
sh.addShard( "shard1/shard1:27018");
sh.addShard( "shard2/shard2:27019");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
EOF

# Проверяем работоспособность: заполняем оба роутера по 1000 документов
docker compose exec -T mongos_router1 mongosh --port 27020 --quiet <<EOF
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
db.helloDoc.countDocuments()
EOF

docker compose exec -T mongos_router2 mongosh --port 27021 --quiet <<EOF
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
db.helloDoc.countDocuments()
EOF

# Проверяем работоспособность: выводим количесво документов на шарде 1
docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
use somedb
db.helloDoc.countDocuments();
EOF

# Проверяем работоспособность: выводим количесво документов на шарде 1
docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF

