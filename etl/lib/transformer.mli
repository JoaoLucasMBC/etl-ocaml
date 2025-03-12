(** Module for transforming order and order_item data into output data *)

open Extractor ;;

(** Represents the total amount and taxes for an order. *)
type order_total = {
  order_id: int;  (** Unique identifier for the order. *)
  total_amout: float;  (** Total amount spent on the order. *)
  total_taxes: float  (** Total taxes applied to the order. *)
} ;;

(** Transforms a list of joined order items into a list of order totals.
    This function aggregates the total amount and taxes for each order.

    @param filter An optional filter function to apply to the list before aggregation. 
                  Defaults to a function that returns [true] for all elements.
    @param joined_lst The list of joined order items ([item_join_order]).
    @return A list of [order_total] records, with amounts and taxes aggregated per order.
*)
val transform_orders : ?filter:(item_join_order -> bool) -> item_join_order list -> order_total list