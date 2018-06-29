FROM elixir:1.6.4

RUN apt-get update
RUN apt-get install --yes inotify-tools protobuf-compiler

WORKDIR /app
ADD . /app


ENV PATH="/root/.mix/escripts:${PATH}"
ENV MIX_ENV=docker
RUN mix local.rebar --force
RUN mix local.hex --force
RUN mix deps.get
RUN mix escript.install hex protobuf --force
RUN ./init.sh
# RUN protoc -I proto-files --elixir_out=plugins=grpc:lib/gateway/proto/ proto-files/*.proto
WORKDIR /app



CMD ["iex", "-S", "mix"]
