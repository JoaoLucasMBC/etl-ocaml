(** Module for transforming order and order_item data into output data *)

open Types ;;

(** Transforms a list of joined order items into a list of order totals.
    This function aggregates the total amount and taxes for each order.

    @param filter An optional filter function to apply to the list before aggregation. 
                  Defaults to a function that returns [true] for all elements.
    @param joined_lst The list of joined order items ([item_join_order]).
    @return A list of [order_total] records, with amounts and taxes aggregated per order.
*)
val transform_orders : ?filter:(item_join_order -> bool) -> item_join_order list -> order_total list

(** Calculates the average income and tax per month-year from a list of order totals.

  This function groups the input list by month and year, then computes the
  average of [total_amout] and [total_taxes] for each group. The result is a
  list of [avg_income_tax] records, one for each month-year.

  @param total_lst The list of [order_total] records to process.
  @return A list of [avg_income_tax] records, each containing the month-year and corresponding averages.
*)
val calculate_avg_income_and_tax_by_year_month : order_total list -> avg_income_tax list

(** Groups a list of order totals by their corresponding month and year.

    This function creates a hash table where each key is a string representing the
    month and year in the format ["YYYY-MM"], and the value is a list of all
    [order_total] records that occurred in that month.
*)
val group_by_date : order_total list -> (string, order_total list) Hashtbl.t