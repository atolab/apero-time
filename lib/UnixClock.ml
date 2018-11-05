open Time
open Clock

module UnixClock : Clock = struct

  let now () = Time.of_seconds @@ Unix.gettimeofday()

end