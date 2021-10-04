build:
	@go build

image/build:
    docker build -t nautible/nautible-maw:1.0.0 .

cert/generate:
	@cd certs/ && \
	cfssl gencert -initca ca-csr.json | cfssljson -bare ca - && \
	cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server server-csr.json | cfssljson -bare server

	@echo "ca: $(shell openssl enc -base64 -in ./certs/ca.pem | tr -d '\n')"
	@echo "cert: $(shell openssl enc -base64 -in ./certs/server.pem | tr -d '\n')"
	@echo "key: $(shell openssl enc -base64 -in ./certs/server-key.pem | tr -d '\n')"

deploy:
	kubectl apply -f deploy/
