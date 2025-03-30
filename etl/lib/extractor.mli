(** Module for processing orders and order items from CSV files and URLs. *)

open Types ;;

(** Reads an order CSV file and returns a list of orders. 
    @param path The file path of the CSV.
    @return A list of [order] records. *)
val read_order_csv : string -> order list

(** Reads an order item CSV file and returns a list of order items.
    @param path The file path of the CSV.
    @return A list of [order_item] records. *)
val read_order_item_csv : string -> order_item list

(** Reads an order CSV file from a URL and returns a list of orders.
    @param url The URL pointing to the CSV file.
    @return A list of [order] records. *)
val read_order_url : string -> order list

(** Reads an order item CSV file from a URL and returns a list of order items.
    @param url The URL pointing to the CSV file.
    @return A list of [order_item] records. *)
val read_order_item_url : string -> order_item list

(** Filters an [item_join_order] record based on command-line parameters.
    Filters by order status and origin if provided.
    @param item The [item_join_order] record to filter.
    @return [true] if the record passes the filters, otherwise [false]. *)
val process_filter: item_join_order -> bool

(** Performs an inner join between a list of orders and a list of order items.
    @param order_list The list of orders.
    @param item_list The list of order items.
    @return A list of [item_join_order] records.
    @raise Failure if an order item does not have a corresponding order. *)
val inner_join: order list -> order_item list -> item_join_order list

(** Parses a list of strings into an [order] record.
  @param order The list of strings representing an order row read from a csv source.
  @return The parsed [order] record.
  @raise Failure if the input does not match the expected format.
*)
val parse_order : string list -> order

(** Parses a list of strings into an [order_item] record.
    @param order_item The list of strings representing an order item row from a csv source.
    @return The parsed [order_item] record.
    @raise Failure if the input does not match the expected format.
*)
val parse_order_item : string list -> order_item

(** Converts a list of orders read from a CSV source into a list of [order] records.
    @param lst The list of CSV rows.
    @return A list of parsed [order] records.
*)
val  order_csv_to_record : string list list -> order list

(** Converts a list of order items from a CSV source into a list of [order_item] records.
    @param lst The list of CSV rows.
    @return A list of parsed [order_item] records.
*)
val order_item_csv_to_record : string list list -> order_item list