open Apero
open Time

module Timestamp = struct
  
  module type S = sig
    module Time: Time

    module T: sig
      type t
      val compare: t -> t -> int
      val equal: t -> t -> bool
    end

    include (module type of Ordered.Make (T))

    val create: Uuid.t -> Time.t -> t
    val get_source: t -> Uuid.t
    val get_time: t -> Time.t
    val to_string: t -> string
  end

  module Make (T: Time) = struct

    module Time = T

    module T = struct
      type t = {
          id: Uuid.t;
          time: Time.t;
      }
      let compare t t' =
        let time_compare = T.compare t.time t'.time in
        if time_compare != 0 then time_compare else Uuid.compare t.id t'.id
      let equal t t' = T.equal t.time t'.time && Uuid.equal t.id t'.id

      let create (id:Uuid.t) (time:Time.t) = { id; time; }
      let get_source t = t.id
      let get_time t = t.time
      let to_string t = T.to_string t.time ^"/"^ Uuid.to_string t.id
    end

    include Ordered.Make (T)

    let create = T.create
    let get_source = T.get_source
    let get_time = T.get_time
    let to_string = T.to_string
  end
end