open Apero
open Time

module Timestamp: sig
  
  module T: sig
    type t
    val compare: t -> t -> int
  end

  include (module type of Ordered.Make (T))

  val create: Uuid.t -> Time.t -> t
  val get_source: t -> Uuid.t
  val get_time: t -> Time.t
  val to_string: t -> string

end
