LOCAL_BIN:=$(CURDIR)/bin
GOOS ?= linux
GOARCH ?= amd64
APP ?= auth-api_$(GOOS)
RELEASE ?= 0.0.1
CONTAINER_IMAGE?=docker.io/pu4mane/$(APP)
DOCKER_USERNAME ?= pu4mane
DOCKER_TOKEN ?= dckr_pat_fOkhhIvKOSHXqfKMiOLZ5smP08Q

install-golangci-lint:
	GOBIN=$(LOCAL_BIN) go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.63.4

lint:
	$(LOCAL_BIN)/golangci-lint run ./... --config .golangci.pipeline.yaml

install-deps:
	GOBIN=$(LOCAL_BIN) go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.36.1
	GOBIN=$(LOCAL_BIN) go install -mod=mod google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.5.1

get-deps:
	go get -u google.golang.org/protobuf/cmd/protoc-gen-go
	go get -u google.golang.org/grpc/cmd/protoc-gen-go-grpc


generate:
	make generate-user-api

generate-user-api:
	mkdir -p pkg/grpc/user_v1
	protoc --proto_path api/grpc/user_v1 \
	--go_out=pkg/grpc/user_v1 --go_opt=paths=source_relative \
	--plugin=protoc-gen-go=$(LOCAL_BIN)/protoc-gen-go \
	--go-grpc_out=pkg/grpc/user_v1 --go-grpc_opt=paths=source_relative \
	--plugin=protoc-gen-go-grpc=$(LOCAL_BIN)/protoc-gen-go-grpc \
	api/grpc/user_v1/user.proto
	go mod tidy	

clean:
	rm -f $(APP)

build: clean
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(APP) cmd/grpc_server/main.go

docker-build-and-push:
	docker buildx build --no-cache --platform $(GOOS)/$(GOARCH) -t $(CONTAINER_IMAGE):$(RELEASE) .
	docker login -u $(DOCKER_USERNAME) -p $(DOCKER_TOKEN) docker.io/pu4mane
	docker push $(CONTAINER_IMAGE):$(RELEASE)