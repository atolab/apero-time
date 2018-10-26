open Apero
open Time
open Timestamp

module HLC: sig

  type hlc_error = [ `DeltaExceed of Uuid.t * int64 * Time.t * Time.t ]

  module type S = sig
    val update_with_clock:  unit -> Timestamp.t Lwt.t
    val update_with_message: Timestamp.t -> (Timestamp.t, hlc_error) Result.t  Lwt.t
  end

  module type Config = sig    
    val id: Uuid.t
    val csize: int
    val delta: int64
  end

  module Make (C: Config) (MVar: MVar): S 

  val create:  Uuid.t -> int -> float -> (module S)
  (** [create id csize delta] creates a new HLC for the source with [id], using a counter of [csize] bits and a [delta] in seconds *)

end
