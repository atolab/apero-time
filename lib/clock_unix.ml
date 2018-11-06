open Clock
open Time_int64

module Clock_unix : Clock with module Time = Time_int64 = struct

  module Time = Time_int64

  let now () = Time.of_seconds @@ Unix.gettimeofday()

end
