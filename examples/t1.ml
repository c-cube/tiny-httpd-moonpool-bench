module M = Moonpool
module H = Tiny_httpd

let j = ref 20
let min_per_dom = ref 2
let port = ref 8084

let handle_name (server : H.t) : unit =
  H.add_route_handler server H.Route.(exact "hello" @/ string @/ return)
  @@ fun name _req ->
  H.Response.make_string @@ Ok (Printf.sprintf "hello %s" name)

let count = Atomic.make 0

let handle_name_json (server : H.t) : unit =
  H.add_route_handler server H.Route.(exact "hellojs" @/ string @/ return)
  @@ fun name _req ->
  let j =
    `Assoc
      [
        "what", `String "hello";
        "who", `String name;
        "count", `Int (Atomic.fetch_and_add count 1);
      ]
  in
  H.Response.make_string @@ Ok (Yojson.Safe.to_string j)

let run () : int =
  let pool = M.Ws_pool.create ~num_threads:!j () in
  let server =
    H.create ~max_connections:2048 ~port:!port
      ~new_thread:(M.Runner.run_async pool) ()
  in

  handle_name server;
  handle_name_json server;

  Printf.printf "listening on http://127.0.0.1:%d (%d threads)\n%!" !port
    (M.Runner.size pool);
  match H.run server with
  | Ok () -> 0
  | Error e ->
    Printf.eprintf "error: %s\n%!" (Printexc.to_string e);
    1

let () =
  (* force linking *)
  ignore (Jemalloc.version ());

  Printexc.record_backtrace true;
  Arg.parse
    [
      "-j", Arg.Set_int j, " size of pool";
      ( "--min-per-dom",
        Arg.Set_int min_per_dom,
        " minimum number of threads per domain" );
      "-p", Arg.Set_int port, " port to listen on";
    ]
    ignore "t1 [opt]*";

  let code = run () in
  exit code
