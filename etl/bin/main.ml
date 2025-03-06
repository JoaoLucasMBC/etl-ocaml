open Etl.Extractor ;;
open Etl.Transformer ;;
open Etl.Loader ;;

let () = 
  let order_data: order list = read_order_csv "data/order.csv" in
  let order_item_data: order_item list = read_order_item_csv "data/order_item.csv" in
  let filter: (order->bool) = process_filter in
  let processed_values: order_total list = transform_orders ~filter order_data order_item_data in
  write_order_total_to_csv "data/output.csv" processed_values ;;