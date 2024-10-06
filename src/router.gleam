import gleam/bit_array
import gleam/http
import gleam/option.{None, Some}

import wisp

import cache.{type Cache}

pub type RouterContext {
  RouterContext(cache: Cache)
}

pub fn handle_request(
  req: wisp.Request,
  context: RouterContext,
) -> wisp.Response {
  wisp.log_info("request started for path: " <> req.path)

  wisp.log_info("setup common middleware")
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  use req <- use_cache_value(req, context.cache, req.path)

  wisp.log_info("cache, if possible")
  case req.method {
    http.Post | http.Put | http.Patch -> {
      wisp.log_info(
        "["
        <> http.method_to_string(req.method)
        <> "]"
        <> " caching for key: "
        <> req.path,
      )

      let assert Ok(body) = wisp.read_body_to_bitstring(req)
      let assert Ok(body_string) = bit_array.to_string(body)

      cache.set_cache_value(context.cache, req.path, body_string)

      wisp.ok()
      |> wisp.string_body(body_string)
    }
    _ -> {
      wisp.log_info(
        "["
        <> http.method_to_string(req.method)
        <> "]"
        <> " skipping caching - no body expected",
      )
      wisp.ok()
    }
  }
}

pub fn use_cache_value(
  req: wisp.Request,
  cache: Cache,
  key: String,
  otherwise alternative: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  wisp.log_info("use cache or continue")

  let cache_value = cache.get_cache_value(cache, key)

  case cache_value {
    Some(value) -> {
      wisp.log_info("cache found for key: " <> key)

      wisp.ok()
      |> wisp.string_body(value)
    }
    None -> {
      wisp.log_info("no cache found for key: " <> key)
      alternative(req)
    }
  }
}
