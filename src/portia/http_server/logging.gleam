import gleam/bit_array
import gleam/result
import logging

pub fn log_body(body: BitArray) -> Result(BitArray, _) {
  logging.log(
    logging.Info,
    "Request body: " <> bit_array.to_string(body) |> result.unwrap("ReadError"),
  )
  Ok(body)
}
