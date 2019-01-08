open Apero

module type Time = sig
  include Apero.Ordered.S

  val after: t -> t -> bool
  val before: t -> t -> bool

  val to_string: t -> string
  val of_string: string -> t option

  val encode: t -> IOBuf.t -> (IOBuf.t, Atypes.error) Result.t
  val decode: IOBuf.t -> (t * IOBuf.t, Atypes.error) Result.t

  val pp: Format.formatter -> t -> unit

end
