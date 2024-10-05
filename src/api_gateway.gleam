import gleam/erlang/process
import gleam/int

import dot_env/env

import mist

import wisp
import wisp/wisp_mist

import router

pub fn main() {
  wisp.configure_logger()

  let secret_key_base = wisp.random_string(64)
  let port = env.get_int_or("PORT", 3000)

  let assert Ok(_) =
    router.handle_request
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  wisp.log_info(
    "The server is running on http://localhost:" <> int.to_string(port),
  )

  process.sleep_forever()
}
