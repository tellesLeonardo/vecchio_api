defmodule VecchioApi.Repo do
  use Mongo.Repo,
  otp_app: :vecchio_api,
  topology: :mongo
end
