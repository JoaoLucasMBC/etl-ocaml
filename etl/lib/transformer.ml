(** Module for transforming order and order_item data into output data *)

open Extractor ;;

(** Represents the total amount and taxes for an order. *)
type order_total = {
  order_id: int;  (** Unique identifier for the order. *)
  total_amout: float;  (** Total amount spent on the order. *)
  total_taxes: float  (** Total taxes applied to the order. *)
} ;;

(* 1. SHOULD I ORDER BY ID? *)
(* 2. WHAT ABOUT THE ORDER WITH NO ITEMS *)

(** Transforms a list of joined order items into a list of order totals.
    This function aggregates the total amount and taxes for each order.

    @param filter An optional filter function to apply to the list before aggregation. 
                  Defaults to a function that returns [true] for all elements.
    @param joined_lst The list of joined order items ([item_join_order]).
    @return A list of [order_total] records, with amounts and taxes aggregated per order.
*)
let transform_orders ?(filter=(fun _ -> true)) (joined_lst: item_join_order list) =
  (* First, filter the orders *)
  List.filter filter joined_lst
  (* The reduce is used to accumulate all order_totals in a associated list *)
  (* the assoc list is also used to check if a certain order already started computation or not *)
  |> List.fold_left (fun assoc_lst (curr_item: item_join_order) ->
      (* Tries to find the order in the list *)
      match List.assoc_opt curr_item.order_id assoc_lst with
      | Some total -> 
          (total.order_id, {
            order_id = total.order_id;
            total_amout = total.total_amout +. (float_of_int curr_item.quantity) *. curr_item.price;
            total_taxes = total.total_taxes +. (float_of_int curr_item.quantity) *. curr_item.price *. curr_item.tax
          }) :: List.remove_assoc total.order_id assoc_lst
      (* If it is not found, create a new record for the list *)
      | None ->
          (curr_item.order_id, {
            order_id = curr_item.order_id;
            total_amout = (float_of_int curr_item.quantity) *. curr_item.price;
            total_taxes = (float_of_int curr_item.quantity) *. curr_item.price *. curr_item.tax
          }) :: assoc_lst
    ) []
  (* Returns only the records from the assoc list, not the order_ids *)
  |> List.map snd ;;
