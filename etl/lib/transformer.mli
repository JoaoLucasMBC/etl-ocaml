open Extractor ;;

type order_total = {
  order_id: int;
  total_amout: float;
  total_taxes: float
} ;;

val transform_orders : order list -> order_item list -> order_total list