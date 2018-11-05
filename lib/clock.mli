open Time

module type Clock = sig

   val now: unit -> Time.t
   (** [now()] returns the current time *)

end
