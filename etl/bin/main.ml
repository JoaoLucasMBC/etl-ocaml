open Etl.Extractor ;;
open Etl.Transformer ;;
open Etl.Loader ;;

let () = 
  let order_data: order list = read_order_url "https://raw.githubusercontent.com/JoaoLucasMBC/etl-ocaml/refs/heads/main/etl/data/order.csv" in
  let order_item_data: order_item list = read_order_item_url "https://raw.githubusercontent.com/JoaoLucasMBC/etl-ocaml/refs/heads/main/etl/data/order_item.csv" in
  let filter: (item_join_order->bool) = process_filter in
  let joined_data: item_join_order list = inner_join order_data order_item_data in
  let processed_values: order_total list = transform_orders ~filter joined_data in
  write_order_total_to_csv "data/output.csv" processed_values ;;