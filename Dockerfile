#FROM golang:1.19 AS builder
#WORKDIR /go/src/open-cluster-management.io/addon-contrib/hellospoke-addon
#COPY . .
#ENV GO_PACKAGE open-cluster-management.io/addon-contrib/hellospoke-addon
#
## Build
#RUN make build --warn-undefined-variables
#
## Use distroless as minimal base image to package the manager binary
## Refer to https://github.com/GoogleContainerTools/distroless for more details
#FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
#
## Add the binaries
#COPY --from=builder go/src/open-cluster-management.io/addon-contrib/hellospoke-addon/bin/hellospoke-addon .
#
#ENTRYPOINT ["/argo-wf-status-addon"]
# Start from golang base image
FROM golang:alpine as builder

# Enable go modules
ENV GO111MODULE=on

# Install git. (alpine image does not have git in it)
RUN apk update && apk add --no-cache git

# Set current working directory
WORKDIR /app

# Note here: To avoid downloading dependencies every time we
# build image. Here, we are caching all the dependencies by
# first copying go.mod and go.sum files and downloading them,
# to be used every time we build the image if the dependencies
# are not changed.

# Copy go mod and sum files
COPY go.mod ./
COPY go.sum ./

RUN go mod tidy
RUN go mod vendor
#WORKDIR /app
## Download all dependencies.
#RUN go mod download

# Now, copy the source code
COPY . .

# Note here: CGO_ENABLED is disabled for cross system compilation
# It is also a common best practise.

# Build the application.
RUN CGO_ENABLED=0 go build -o ./bin/argo-wf-status-addon ./cmd/main.go

# Finally our multi-stage to build a small image
# Start a new stage from scratch
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

# Copy the Pre-built binary file
COPY --from=builder /app/bin/argo-wf-status-addon .

# Run executable
ENTRYPOINT ["./argo-wf-status-addon"]
