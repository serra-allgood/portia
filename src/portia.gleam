import gleam/erlang/process
import gleam/otp/actor
import gleam/otp/static_supervisor.{type Supervisor} as supervisor
import portia/http_server

// import portia/replicant_factory

fn start_supervisor() -> actor.StartResult(Supervisor) {
  supervisor.new(supervisor.OneForOne)
  // |> supervisor.add(replicant_factory.supervised())
  |> supervisor.add(http_server.supervised())
  |> supervisor.start()
}

pub fn main() -> Nil {
  let assert Ok(_) = start_supervisor()
  process.sleep_forever()
}
