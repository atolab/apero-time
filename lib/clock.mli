open Time

module type Clock = sig

   val now: unit -> Time.t

end