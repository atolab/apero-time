open Apero
open Time
open Timestamp
open Clock

module type HLC = sig

  module Time: Time
  module Timestamp: Timestamp.S

  type hlc_error = [ `DeltaExceed of Uuid.t * int64 * Time.t * Time.t ]


  val update_with_clock:  unit -> Timestamp.t Lwt.t
  (** [update_with_clock()] updates the HLC with the local time and returns a new [Timestamp]
       which is greater than any previously returned timestamp *)

  val update_with_timestamp: Timestamp.t -> (Timestamp.t, hlc_error) Result.t  Lwt.t
  (** [update_with_timestamp ()] updates the HLC with the timestamp from an incoming message and returns a new [Timestamp]
       which is greater than the provided timestamp and than any previously returned timestamp *)

end

val hlc_create:  Uuid.t -> int -> float -> (module Clock with type Time.t = int64) -> (module HLC)
