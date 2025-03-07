open Extractor ;;

type order_total = {
  order_id: int;
  total_amout: float;
  total_taxes: float
} ;;

(* 1. SHOULD I ORDER BY ID? *)
(* 2. WHAT ABOUT THE ORDER WITH NO ITEMS *)
let transform_orders ?(filter=(fun _ -> true)) (joined_lst: item_join_order list) =
  List.filter filter joined_lst
  |> List.fold_left (fun assoc_lst (curr_item: item_join_order) ->
      match List.assoc_opt curr_item.order_id assoc_lst with
      | Some total -> 
          (total.order_id, {
            order_id = total.order_id;
            total_amout = total.total_amout +. (float_of_int curr_item.quantity) *. curr_item.price;
            total_taxes = total.total_taxes +. (float_of_int curr_item.quantity) *. curr_item.price *. curr_item.tax
          }) :: List.remove_assoc total.order_id assoc_lst
      | None -> 
          (curr_item.order_id, {
            order_id = curr_item.order_id;
            total_amout = (float_of_int curr_item.quantity) *. curr_item.price;
            total_taxes = (float_of_int curr_item.quantity) *. curr_item.price *. curr_item.tax
          }) :: assoc_lst
    ) []
  |> List.map snd ;;