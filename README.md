
## Bring up the network

#### Stdout debug of constructing network
```
docker-compose up infra_builder channel_ctr awscli
```

## Reset the network
```
./scripts/reset-network.sh
```


## Deploy chaincode to the network

#### Change to chaincode project directory, and install go dependencies
```
go mod vendor
```

#### Change the working directory to project root directory
```
./scripts/deploy-loc.sh
```
