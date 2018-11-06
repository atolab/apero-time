module type Time = sig
  include Apero.Ordered.S

  val after: t -> t -> bool
  val before: t -> t -> bool

  val to_string: t -> string

end
