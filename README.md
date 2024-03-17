# Mixion

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Scaffolded via
```
  mix phx.new mixion --live --database sqlite3
  cd mixion
  mix deps.get

  mix phx.gen.live Recipes Recipe recipes name:string color:string steps:string
  mix phx.gen.live Orders Order orders timestamp:naive_datetime bartender:string recipe:references:recipes
  # add the routes to the entities each to router.ex

  mix ecto.migrate
```
Funny thing, but `phx.gen.live` automatically creates migration files starting with a timestamp number. This brings `ecto.migrate` to fail with
`** (Protocol.UndefinedError) protocol String.Chars not implemented for {:wrong_type, 20240317220655} of type Tuple. This protocol is implemented for the following type(s): ...` inside exqlite. Just rename the `priv/repo/migrations/20240317220655_...exs` to it doesn't contain the number anymore (names of migrations don't matter anyway.)