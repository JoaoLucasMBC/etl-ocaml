  open Extractor ;;

  type order_total = {
    order_id: int;
    total_amout: float;
    total_taxes: float
  } ;;

  let calculate_total (order_id: int) (order_items: order_item list) =
    List.fold_left (fun (sum_amount, sum_tax) (amount, tax) -> (sum_amount +. amount, sum_tax +. tax)) (0.0, 0.0)
      (List.map (fun x -> ((float_of_int x.quantity) *. x.price, (float_of_int x.quantity) *. x.price *. x.tax))
        (List.filter (fun (x: order_item) -> x.order_id = order_id) order_items)) ;;

  let transform_orders ?(filter=(fun _ -> true)) (orders: order list) (order_items: order_item list) =
    List.map (fun x -> 
      let total_amount, total_taxes = calculate_total x.id order_items in
      { order_id = x.id; total_amout = total_amount; total_taxes = total_taxes }
    ) (List.filter filter orders) ;;