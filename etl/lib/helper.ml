(** Helper functions for parsing and unparsing order-related data. *)

(** Parses an order ID from a string.
    @param id_str The string representation of the ID.
    @return The parsed integer ID. *)
let parse_id id_str =
  int_of_string id_str ;;

(** Parses a client ID from a string.
    @param client_id_str The string representation of the client ID.
    @return The parsed integer client ID. *)
let parse_client_id client_id_str =
  int_of_string client_id_str ;;

(* GPT ASSISTED *)
(** Parses an order date from an RFC3339 formatted string.
    @param order_date_str The string representation of the order date.
    @return The parsed [Ptime.t] timestamp.
    @raise Failure if the date format is invalid. *)
let parse_order_date order_date_str =
  match Ptime.of_rfc3339 (order_date_str ^ "Z") with
  | Ok (ptime, _, _) -> ptime
  | Error _ -> failwith "Invalid date" ;;

(** Parses an order status from a string.
    Possible values:
    - "Pending" -> 0
    - "Complete" -> 1
    - "Cancelled" -> 2
    @param status_str The string representation of the status.
    @return The corresponding integer status.
    @raise Failure if the status is not recognized. *)
let parse_order_status status_str =
  match status_str with
  | "Pending" -> 0
  | "Complete" -> 1
  | "Cancelled" -> 2 
  | _ -> failwith "Status should be either Pending, Complete, or Cancelled" ;;

(** Parses an order origin from a string.
    Possible values:
    - "P" -> 0 (Physical store)
    - "O" -> 1 (Online)
    @param origin_str The string representation of the order origin.
    @return The corresponding integer origin.
    @raise Failure if the origin is not recognized. *)
let parse_order_origin origin_str =
  match origin_str with
  | "P"  -> 0
  | "O" -> 1
  | _ -> failwith "Origin should be either P or O" ;;

(** Parses an order ID from a string.
    @param order_id_str The string representation of the order ID.
    @return The parsed integer order ID. *)
let parse_order_id order_id_str =
  int_of_string order_id_str ;;

(** Parses a product ID from a string.
    @param product_id_str The string representation of the product ID.
    @return The parsed integer product ID. *)
let parse_product_id product_id_str =
  int_of_string product_id_str ;;

(** Parses a quantity from a string.
    @param quantity_str The string representation of the quantity.
    @return The parsed integer quantity. *)
let parse_quantity quantity_str =
  int_of_string quantity_str ;;

(** Parses a price from a string.
    @param price_str The string representation of the price.
    @return The parsed floating-point price. *)
let parse_price price_str =
  float_of_string price_str ;;

(** Parses a tax amount from a string.
    @param tax_str The string representation of the tax amount.
    @return The parsed floating-point tax. *)
let parse_tax tax_str =
  float_of_string tax_str ;;

(** Converts an order ID into a string.
    @param order_id The integer order ID.
    @return The string representation of the order ID. *)
let unparse_order_id order_id =
  string_of_int order_id ;;

(** Formats a total amount as a string with two decimal places.
    @param total_amount The total amount as a float.
    @return A formatted string representing the total amount. *)
let unparse_total_amount total_amount =
  Printf.sprintf "%.2f" total_amount ;;

(** Formats a total tax amount as a string with two decimal places.
    @param total_taxes The total tax amount as a float.
    @return A formatted string representing the total tax. *)
let unparse_total_taxes total_taxes =
  Printf.sprintf "%.2f" total_taxes ;;    