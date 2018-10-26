open Apero_time

let check_if b ?arg line =
  let test_name =
    match arg with
    | None -> Printf.sprintf "test line %d" line
    | Some(s) -> Printf.sprintf "test line %d with %s" line s
  in
    Alcotest.(check bool) test_name b

(* let new_timestamp hlc =
  let hlc' = HLC.update_with_clock hlc in (hlc', HLC.get_timestamp hlc') *)

module MyHlc = HLC.Make (struct
      let id = Apero.Uuid.make_from_alias "id1"
      let csize = 8
      let delta = Time.of_seconds 0.1
    end) (Apero.MVar_lwt)


let print_ts ts = Printf.printf "%s\n" (Timestamp.to_string ts)

let test1 () =
  let%lwt t1 = MyHlc.update_with_clock () in
  let%lwt t2 = MyHlc.update_with_clock () in
  let open Timestamp.Infix in
  check_if true  __LINE__ @@ (t2 > t1);
  Lwt.return_unit

let test2 () =
  let l = List.init 2000 (fun _ -> Lwt_main.run @@MyHlc.update_with_clock ()) in
  List.mapi (fun i t -> print_ts t; if i = 0 then true else Timestamp.Infix.(t > List.nth l (i-1))) l |>
  List.iter (check_if true  __LINE__)

let all_tests = [
  "test1", `Quick, (fun () -> Lwt_main.run @@ test1 ());
  "test1", `Quick, test2;
]
