open Clock

module UnixClock: Clock
(** Implementation of a [Clock] relying on [Unix.gettimeofday] *)