type ('hash, 'a) t [@@deriving sexp]
type ('hash, 'a) merkle_tree = ('hash, 'a) t

module Free_hash : sig
  type 'a t =
    | Hash_value of 'a
    | Hash_empty
    | Compress of 'a t * 'a t
  [@@deriving sexp]

  val diff : 'a t -> 'a t -> bool list option

  val run
    : 'a t
    -> hash:('a option -> 'hash)
    -> compress:('hash -> 'hash -> 'hash)
    -> 'hash
end

val root : ('hash, _) t -> 'hash

val depth : (_, _) t -> int

val create
  : hash:('a option -> 'hash)
  -> compress:('hash -> 'hash -> 'hash)
  -> 'a
  -> ('hash, 'a) t

val add
  : ('hash, 'a) t -> 'a -> ('hash, 'a) t

val add_many
  : ('hash, 'a) t -> 'a list -> ('hash, 'a) t

val update : ('hash, 'a) t -> bool list -> 'a -> ('hash, 'a) t

val get     : (_, 'a) t -> bool list -> 'a option
val get_exn : (_, 'a) t -> bool list -> 'a

val get_path
  : ('hash, 'a) t -> bool list -> 'hash list

val implied_root
  : compress:('hash -> 'hash -> 'hash) ->  bool list -> 'hash -> 'hash list -> 'hash

val get_free_path
  : (_, 'a) t -> bool list -> 'a Free_hash.t list

val free_root : (_, 'a) t -> 'a Free_hash.t

val implied_free_root
  : bool list -> 'a -> 'a Free_hash.t list -> 'a Free_hash.t

val root : ('hash, 'a) t -> 'hash

val to_list : ('hash, 'a) t -> 'a list

val check_exn : (_, _) t -> unit

module Checked
    (Impl : Snark_intf.S)
    (Hash : sig
      type var
      type value
      val typ : (var, value) Impl.Typ.t
      val hash : var -> var -> (var, _) Impl.Checked.t
      val if_ : Impl.Boolean.var -> then_:var -> else_:var -> (var, _) Impl.Checked.t
      val assert_equal : var -> var -> (unit, _) Impl.Checked.t
    end)
    (Elt : sig
      type var
      type value
      val typ : (var, value) Impl.Typ.t
      val hash : var -> (Hash.var, _) Impl.Checked.t
    end)
  : sig
  open Impl

  module Address : sig
    type 'a t = 'a list [@@deriving sexp]
    type var = Boolean.var t
    type value = bool t [@@deriving sexp]
    val value_of_int : depth:int -> int -> value
    val typ : depth:int -> (var, value) Typ.t
  end

  (* TODO: Change [prev] to be [prev_hash : Hash.var] since there may be no need
    to certify that the hash of the element is a particular value. *)
  val update
    : depth:int
    -> root:Hash.var
    -> prev:Elt.var
    -> next:Elt.var
    -> Address.var
    -> (Hash.var, (Hash.value, Elt.value) merkle_tree) Checked.t

end

