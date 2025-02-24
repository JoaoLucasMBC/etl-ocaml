

let parse_id id_str =
  int_of_string id_str ;;

let parse_client_id client_id_str =
  int_of_string client_id_str ;;

(* GPT help *)
let parse_order_date order_date_str =
  match Ptime.of_rfc3339 (order_date_str ^ "Z") with
  | Ok (ptime, _, _) -> ptime
  | Error _ -> failwith "Invalid date" ;;

let parse_order_status status_str =
  match status_str with
  | "Pending" -> 0
  | "Complete" -> 1
  | "Cancelled" -> 2 
  | _ -> failwith "Status should be either Pending, Compelte, or Cancelled" ;;

let parse_order_origin origin_str =
  match origin_str with
  | "P"  -> 0
  | "O" -> 1
  | _ -> failwith "Origin should be either P or O" ;;


let parse_order_id order_id_str =
  int_of_string order_id_str ;;

let parse_product_id product_id_str =
  int_of_string product_id_str ;;

let parse_quantity quantity_str =
  int_of_string quantity_str ;;

let parse_price price_str =
  float_of_string price_str ;;

let parse_tax tax_str =
  float_of_string tax_str ;;

let unparse_order_id order_id =
  string_of_int order_id ;;

let unparse_total_amount total_amount =
  Printf.sprintf "%.2f" total_amount ;;

let unparse_total_taxes total_taxes =
  Printf.sprintf "%.2f" total_taxes ;;