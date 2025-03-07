open Extractor ;;

type order_total = {
  order_id: int;
  total_amout: float;
  total_taxes: float
} ;;

val transform_orders : ?filter:(item_join_order -> bool) -> item_join_order list -> order_total list