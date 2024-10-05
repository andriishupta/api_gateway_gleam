import gleam/http
import gleam/string_builder
import wisp

pub fn handle_request(req: wisp.Request) -> wisp.Response {
  // setup common middleware
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  // Wisp doesn't have a special router abstraction, instead we recommend using
  // regular old pattern matching. This is faster than a router, is type safe,
  // and means you don't have to learn or be limited by a special DSL.
  //
  case wisp.path_segments(req) {
    // This matches `/`.
    [] -> home_page(req)

    // This matches `/comments`.
    ["comments"] -> comments(req)

    // This matches `/comments/:id`.
    // The `id` segment is bound to a variable and passed to the handler.
    ["comments", id] -> show_comment(req, id)

    // This matches all other paths.
    _ -> wisp.not_found()
  }
}

fn home_page(req: wisp.Request) -> wisp.Response {
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  use <- wisp.require_method(req, http.Get)

  let html = string_builder.from_string("Hello, Joe!")
  wisp.ok()
  |> wisp.html_body(html)
}

fn comments(req: wisp.Request) -> wisp.Response {
  // This handler for `/comments` can respond to both GET and POST requests,
  // so we pattern match on the method here.
  case req.method {
    http.Get -> list_comments()
    http.Post -> create_comment(req)
    _ -> wisp.method_not_allowed([http.Get, http.Post])
  }
}

fn list_comments() -> wisp.Response {
  // In a later example we'll show how to read from a database.
  let html = string_builder.from_string("Comments!")
  wisp.ok()
  |> wisp.html_body(html)
}

fn create_comment(_req: wisp.Request) -> wisp.Response {
  // In a later example we'll show how to parse data from the request body.
  let html = string_builder.from_string("Created")
  wisp.created()
  |> wisp.html_body(html)
}

fn show_comment(req: wisp.Request, id: String) -> wisp.Response {
  use <- wisp.require_method(req, http.Get)

  // The `id` path parameter has been passed to this function, so we could use
  // it to look up a comment in a database.
  // For now we'll just include in the response body.
  let html = string_builder.from_string("Comment with id " <> id)
  wisp.ok()
  |> wisp.html_body(html)
}
