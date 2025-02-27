open Etl.Extractor ;;
open Etl.Transformer ;;
open Etl.Loader ;;

let () = 
  let order_data = read_order_csv "data/order.csv" in
  let order_item_data = read_order_item_csv "data/order_item.csv" in
  let processed_values = transform_orders order_data order_item_data in
  write_order_total_to_csv "data/output.csv" processed_values ;;