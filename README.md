# Projeto Vecchio API

Este projeto é uma API construída para gerenciamento de dados com transações. Ele utiliza Elixir, Phoenix e um banco de dados NoSQL. Para rodar o projeto, basta utilizar o Docker e o Docker Compose.

## Pré-requisitos

Antes de rodar o projeto, certifique-se de ter o Docker e o Docker Compose instalados em sua máquina. Se você não os tem, siga os seguintes passos para instalação:

- [Instalar Docker](https://docs.docker.com/get-docker/)
- [Instalar Docker Compose](https://docs.docker.com/compose/install/)

## Como rodar o projeto

1. Clone este repositório:

```bash
git clone https://github.com/seu-usuario/vecchio-api.git
cd vecchio-api
```

2. Construa e inicie os containers com o comando abaixo:
```bash
docker-compose up -d
```

## Estrutura do projeto

A estrutura do código segue o padrão de um projeto Elixir com Phoenix, com foco em manipulação de dados com transações. O código está organizado da seguinte maneira:

  1. VecchioApi.Core.Helpers.HelperGenServer: Módulo responsável pela lógica de transações e manipulação de dados.
  2. VecchioApi.Database.Context.KeyValueStores: Módulo responsável pela interação com o banco de dados.
  3. VecchioApi.Command.Handler: Módulo que manipula os comandos de transação e de dados.

## Como parar o projeto

Para parar o ambiente e remover os containers, execute o seguinte comando:

```bash
docker-compose down
```

### Explicação do README:

1. **Pré-requisitos**: Instruções sobre como instalar o Docker e o Docker Compose, caso o usuário ainda não tenha essas ferramentas.
2. **Como rodar o projeto**: O passo a passo para clonar o repositório e rodar o projeto com Docker Compose.
3. **Estrutura do projeto**: Uma breve descrição de como o código está organizado.
5. **Como parar o projeto**: Como parar e remover os containers quando não precisar mais.

Com esse README, qualquer pessoa que queira rodar o seu projeto pode facilmente fazer isso com o Docker Compose, bastando rodar o comando `docker-compose up -d` para inicializar o ambiente.
