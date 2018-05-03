#!/bin/bash
protoc -I proto-files --elixir_out=plugins=grpc:lib/proto/ proto-files/*.proto
echo "Generated Protos Successfully"