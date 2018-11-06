open Apero
open Time
open Time_64bit
open Timestamp
open Clock

module type HLC = sig

  module Time: Time
  module Timestamp: Timestamp.S

  type hlc_error = [ `DeltaExceed of Uuid.t * int64 * Time.t * Time.t ]

  val update_with_clock:  unit -> Timestamp.t Lwt.t
  val update_with_timestamp: Timestamp.t -> (Timestamp.t, hlc_error) Result.t  Lwt.t

end

module type Config = sig
  val id: Uuid.t
  val csize: int
  val delta: Time_64bit.t
end

module Make (C: Config) (MVar: MVar) (Clk: Clock with type Time.t = Time_64bit.t) = struct

  module Time = Clk.Time
  module Timestamp = Timestamp.Make(Time)

  type hlc_error = [ `DeltaExceed of Uuid.t * int64 * Time.t * Time.t ]

  let last_time = MVar.create 0L

  let cmask = let open Int64 in sub (shift_left 1L C.csize) 1L
  let lmask = Int64.lognot @@ cmask

  let get_l time = Int64.logand time lmask
  let get_c time = Int64.logand time cmask

  let max t t' = let open Time.Infix in if t > t' then t else t'

  let max3 t1 t2 t3 = max t1 t2 |> max t3

  let update_with_clock () =
    let open Int64 in
    let pt = get_l (Clk.now()) in
    MVar.guarded last_time @@ fun time ->
      let l' = get_l time in
      let l = max l' pt in
      let c = if (Int64.equal l l') then succ (get_c time) else 0L in
      let new_time = logor l c in
      let _ = Logs.debug (fun m -> m "[HLC] update_with_clock: %Lx -> %Lx\n" time new_time) in
      Lwt.return (Lwt.return @@ Timestamp.create C.id new_time, new_time)

  let update_with_timestamp timestamp =
    let open Int64 in
    let now = Clk.now() in
    let msg_time = Timestamp.get_time timestamp in
    if sub (sub msg_time now) C.delta > 0L then
      let source = Timestamp.get_source timestamp in
      let _ = Logs.warn (fun m -> m "[HLC] incoming timestamp from %s exceeding delta %Ld is rejected: %Ld vs. now: %Ld"
        (Uuid.to_string source) C.delta msg_time now) in
      Lwt.return @@ Result.fail (`DeltaExceed (source, C.delta, msg_time, now))
    else
      let pt = get_l now in
      let lm = get_l msg_time in
      let cm = get_c msg_time in
      MVar.guarded last_time @@ fun time ->
        let l' = get_l time in
        let l = max3 l' msg_time pt in
        let c =
          if (Int64.equal l l') && (Int64.equal l msg_time) then succ (max (get_c time) cm)
          else if (Int64.equal l l') then succ (get_c time)
          else if (Int64.equal l lm) then succ cm
          else 0L
        in
        let new_time = logor l c in
        let _ = Logs.debug (fun m -> m "[HLC] update_with_message %Lx: %Lx -> %Lx" msg_time time new_time) in
        Lwt.return (Lwt.return (Result.return @@ Timestamp.create C.id new_time), new_time)

end

let hlc_create id csize delta (module C: Clock with type Time.t = Time_64bit.t) =
  let module M = Make (struct
    let id = id
    let csize = csize
    let delta = Time_64bit.of_seconds delta
  end) (MVar_lwt) (C)
  in (module M : HLC)

