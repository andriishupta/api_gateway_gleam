import gleam/option.{type Option, None, Some}

import carpenter/table

pub type Cache =
  table.Set(String, String)

pub type CacheValue =
  Option(String)

pub fn new_cache(name: String) -> Cache {
  let assert Ok(cache) =
    table.build(name)
    |> table.privacy(table.Public)
    |> table.write_concurrency(table.AutoWriteConcurrency)
    |> table.read_concurrency(True)
    |> table.decentralized_counters(True)
    |> table.compression(False)
    |> table.set

  cache
}

pub fn set_cache_value(cache: Cache, key: String, value: String) -> Nil {
  table.insert(cache, [#(key, value)])
}

pub fn get_cache_value(cache: Cache, key: String) -> CacheValue {
  case table.lookup(cache, key) {
    [] -> None
    [#(_, value), ..] -> Some(value)
  }
}
