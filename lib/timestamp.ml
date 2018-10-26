open Apero
open Time

module Timestamp = struct
  
  module T = struct
    type t = {
        id: Uuid.t;
        time: Time.t;
    }
    let compare t t' =
      let time_compare = Time.compare t.time t'.time in
      if time_compare != 0 then time_compare else Uuid.compare t.id t'.id

    let create (id:Uuid.t) (time:Time.t) = { id; time; }
    let get_source t = t.id
    let get_time t = t.time
    let to_string t = Time.to_string t.time ^"/"^ Uuid.to_string t.id
  end

  include Ordered.Make (T)

  let create = T.create
  let get_source = T.get_source
  let get_time = T.get_time
  let to_string = T.to_string

end