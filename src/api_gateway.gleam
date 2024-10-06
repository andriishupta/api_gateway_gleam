import cache
import gleam/erlang/process
import gleam/int

import dot_env/env

import mist

import wisp
import wisp/wisp_mist

import router

pub fn main() {
  wisp.configure_logger()
  wisp.log_info("logger configured")

  let secret_key_base = wisp.random_string(64)
  let port = env.get_int_or("PORT", 8080)

  let cache = cache.new_cache("default")
  let context = router.RouterContext(cache)

  wisp.log_info("cache created")

  let assert Ok(_) =
    router.handle_request(_, context)
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  wisp.log_info(
    "The server is running on http://localhost:" <> int.to_string(port),
  )

  process.sleep_forever()
}
