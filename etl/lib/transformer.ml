(** Module for transforming order and order_item data into output data *)

open Types ;;

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
            total_taxes = total.total_taxes +. (float_of_int curr_item.quantity) *. curr_item.price *. curr_item.tax;
            order_date = curr_item.order_date
          }) :: List.remove_assoc total.order_id assoc_lst
      (* If it is not found, create a new record for the list *)
      | None ->
          (curr_item.order_id, {
            order_id = curr_item.order_id;
            total_amout = (float_of_int curr_item.quantity) *. curr_item.price;
            total_taxes = (float_of_int curr_item.quantity) *. curr_item.price *. curr_item.tax;
            order_date = curr_item.order_date
          }) :: assoc_lst
    ) []
  (* Returns only the records from the assoc list, not the order_ids *)
  |> List.map snd ;;


(** Groups a list of order totals by their corresponding month and year.

    This function creates a hash table where each key is a string representing the
    month and year in the format ["YYYY-MM"], and the value is a list of all
    [order_total] records that occurred in that month.

    @param total_lst The list of [order_total] records to group.
    @return A hash table mapping each month-year string to a list of order totals.
*)
let group_by_date (total_lst: order_total list) : (string, order_total list) Hashtbl.t =
  let dmap = Hashtbl.create (List.length total_lst) in
  List.iter (fun (curr_total: order_total) ->
    let (year, month, _) = Ptime.to_date curr_total.order_date in
    let month_year = Printf.sprintf "%04d-%02d" year month in
    let grouped_lst = match Hashtbl.find_opt dmap month_year with
      | Some lst -> lst
      | None -> [] in
    Hashtbl.replace dmap month_year (curr_total :: grouped_lst)
  ) total_lst;
  dmap ;;


(** Calculates the average income and tax per month-year from a list of order totals.

  This function groups the input list by month and year, then computes the
  average of [total_amout] and [total_taxes] for each group. The result is a
  list of [avg_income_tax] records, one for each month-year.

  @param total_lst The list of [order_total] records to process.
  @return A list of [avg_income_tax] records, each containing the month-year and corresponding averages.
*)
let calculate_avg_income_and_tax_by_year_month (total_lst: order_total list) : (avg_income_tax list) =
  let date_map = group_by_date total_lst in
  Hashtbl.fold (fun month_year total_lst acc ->
    let total_income = List.fold_left (fun acc total -> acc +. total.total_amout) 0. total_lst in
    let total_tax = List.fold_left (fun acc total -> acc +. total.total_taxes) 0. total_lst in
    let avg_income = total_income /. (float_of_int (List.length total_lst)) in
    let avg_tax = total_tax /. (float_of_int (List.length total_lst)) in
    { month_year; avg_income; avg_tax } :: acc
  ) date_map [] ;;