ExUnit.start()

ExUnit.after_suite(fn _ ->
  database_name = Application.get_env(:vecchio_api, VecchioApi.Repo)[:database]

  Mongo.drop_database(:mongo, database_name)
  IO.puts("Banco de teste #{database_name} limpo!")
end)
