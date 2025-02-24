open Extractor ;;

type order_total = {
  order_idd: int;
  total_amout: float;
  total_taxes: float
} ;;

let calculate_total (order_id: int) (order_items: order_item list) =
  List.fold_left (fun acc x -> acc +. x) 0.0
    (List.map (fun x -> (float_of_int x.quantity) *. x.price)
      (List.filter (fun x -> x.order_id = order_id) order_items)) ;;

let calculate_tax (order_id: int) (order_items: order_item list) =
  List.fold_left (fun acc x -> acc +. x) 0.0
    (List.map (fun x -> (float_of_int x.quantity) *. x.price *. x.tax)
      (List.filter (fun x -> x.order_id = order_id) order_items)) ;;

let transform_orders (orders: order list) (order_items: order_item list) =
  List.map (fun x -> { order_idd = x.id; total_amout = calculate_total x.id order_items; total_taxes = calculate_tax x.id order_items }) orders ;;