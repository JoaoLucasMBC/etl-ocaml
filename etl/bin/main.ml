open Etl.Extractor ;;
open Etl.Transformer ;;
open Etl.Loader ;;

let () = 
  let order_data = read_order_csv "data/order.csv" in
  let order_item_data = read_order_item_csv "data/order_item.csv" in
  let processed_values = transform_orders order_data order_item_data in
  let () = write_order_total_to_csv "data/output.csv" processed_values in
  
  List.iter (fun row -> (Printf.printf "%d, %f, %f \n" row.order_idd row.total_amout row.total_taxes)) processed_values ;;