open Time

module UnixClock = struct
  include Clock

  let now () = Time.of_seconds @@ Unix.gettimeofday()

end