use Mix.Config

config :gateway, Gateway.Repo,
  adapter: Mongo.Ecto,
  database: "gateway",
  username: "gateway_dev_user",
  password: "gateway_dev_pass",
  port: 27017,
  hostname: "localhost"
