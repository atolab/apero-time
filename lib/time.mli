

module Time : sig
  include (module type of Apero.Ordered.Make(Int64))

  val of_seconds: float -> t
  val to_seconds: t -> float

  val after: t -> t -> bool
  val before: t -> t -> bool

  val to_string: t -> string

end
