# SpringConfig

SpringConfig allows Elixir projects to load configuration from a Spring centralized configuration server

## Installation

### Hex

using Hex:

```elixir
def deps do
  [
    {:spring_config, "~> 0.1.1"}
  ]
end
```

### Git

SpringConfig can be installed using Git:

```elixir
def deps do
  [
    {:spring_config, github: "jfpedroza/spring_config"}
  ]
end
```

## Documentation

Documentation can be found in [https://hexdocs.pm/spring_config](here)

## Usage

Add this to your `config.exs`:

```elixir
config :spring_config,
  otp_app: :my_app,
  profile: Mix.env()
```

### application.yaml

SpringConfig requires an YAML file to be part of your application. By default this file's path is `priv/application.yaml` and the following is an example:

```yaml
spring:
  application:
    name: my_app

---

spring:
  profiles: dev
  cloud:
    config:
      uri: http://localhost:9888/config-service

---

spring:
  profiles: prod
  cloud:
    config:
      uri: http://example.com/config-service
```

### Accessing the configuration

#### provided configuration

```yaml
foo: value
bar:
  bazz: 3
  fuzz: value2
```

#### Accessing it in Elixir

```elixir
iex> SpringConfig.get!(:foo)
"value"

iex> SpringConfig.get!(:"bar.bazz")
3

iex> SpringConfig.get!(:"not.found")
** (RuntimeError) Key not.found not found in configuration entries

iex> SpringConfig.get(:"not.found", "default-value")
"default-value"
```

### Environment configuration

You can set any SpringConfig config key from an environment variable using a system tuple, for example:

```elixir
config :spring_config,
  profile: {:system, "APP_PROFILE", "dev"} # will use dev as profile if APP_PROFILE is not defined

config :spring_config,
  profile: {:system, "APP_PROFILE"} # will raise if APP_PROFILE is not defined
```

### Available config keys

The following keys are allowed to configure SpringConfig

| Key | Description | Example | Required | Default | Type |
| --- | --- | --- | --- | --- | --- |
| otp_app | The app that contains the YAML file | `:my_app` | Yes | N/A | Atom or String |
| path | Spring local configuration file | `"priv/my_app.yml"` | No | `"priv/application.yml"` | String |
| app_name | Name to use when requesting the remote configuration | `"my-app"` | No | The value of the key `"string.application.name"` in the YAML file. Will raise if neither is found | String |
| profile | The profile to use when requesting the remote configuration | `Mix.env()`, `"staging"` | Yes | N/A | Atom or String |
| remote_uri_key | The key in the YAML file to use for the remote server | `:"remote.uri"` | No | `:"spring.cloud.config.uri"` | Atom or String |
| remote_uri | The base url of the remote server | `"http://localhost:9888/config-service"` | No | The value of the `remote_uri_key`. if present the key specified in `remote_uri_key` is not required to be present | String |

The url for requesting the remote configuration is made like so:
`$remote_uri/$app_name/$profile`

### Integrating with Ecto

You can integrate SpringConfig with Ecto through Ecto's `init/2` callback

In your remote configuration:

```yaml

spring:
  profiles: prod

database:
  database: dbname
  password: super-secret
  hostname: 1.2.3.4
  port: "5432"
  username: db_user

```

In Ecto's callback:

```elixir

defmodule MyApp.Repo do
  use Ecto.Repo, otp_app: :my_app, adapter: Ecto.Adapters.Postgres

  def init(_, opts) do
    # When running migrations, Ecto starts the repository outside the supervision tree,
    # so SpringConfig is not available. If you want to run migrations, pass ensure_started: true
    # and SpringConfig will start temporarily using Application.ensure_all_started
    db_config = SpringConfig.get!(:"database", ensure_started: true)

    opts = Keyword.merge(Map.to_list(db_config), opts)
    # or opts = Keyword.merge(opts, Map.to_list(db_config))
    # depening on which configuration should take precedence

    {:ok, opts}
  end
end

```

License

-------

    Copyright 2018 Jhon Pedroza

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
