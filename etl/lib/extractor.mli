type order = { 
  id: int; 
  client_id: int; 
  order_date: Ptime.t; 
  status: int; 
  origin: int; 
} ;;

type order_item = { 
  order_id: int; 
  product_id: int; 
  quantity: int; 
  price: float; 
  tax: float; 
} ;;

type item_join_order = {
  order_id: int;
  client_id: int;
  order_date: Ptime.t;
  status: int;
  origin: int;
  product_id: int;
  quantity: int;
  price: float;
  tax: float;
} ;;

val read_order_csv : string -> order list
val read_order_item_csv : string -> order_item list
val read_order_url : string -> order list
val read_order_item_url : string -> order_item list

val process_filter: item_join_order -> bool
val inner_join: order list -> order_item list -> item_join_order list