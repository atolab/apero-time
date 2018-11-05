open Apero_time

let check_if b ?arg line =
  let test_name =
    match arg with
    | None -> Printf.sprintf "test line %d" line
    | Some(s) -> Printf.sprintf "test line %d with %s" line s
  in
    Alcotest.(check bool) test_name b


module MyHLC = (val hlc_create (Apero.Uuid.make_from_alias "id1") 8 0.1 (module UnixClock: Clock): HLC)


let print_ts ts = Printf.printf "%s\n" (Timestamp.to_string ts)

let test1 () =
  let%lwt t1 = MyHLC.update_with_clock () in
  let%lwt t2 = MyHLC.update_with_clock () in
  let open Timestamp.Infix in
  check_if true  __LINE__ @@ (t2 > t1);
  Lwt.return_unit

let test2 () =
  let l = List.init 2000 (fun _ -> Lwt_main.run @@MyHLC.update_with_clock ()) in
  List.mapi (fun i t -> print_ts t; if i = 0 then true else Timestamp.Infix.(t > List.nth l (i-1))) l |>
  List.iter (check_if true  __LINE__)

let all_tests = [
  "test1", `Quick, (fun () -> Lwt_main.run @@ test1 ());
  "test1", `Quick, test2;
]
