open Etl.Extractor ;;
open Etl.Transformer ;;
open Etl.Loader ;;
open Etl.Types ;;


(** Entry point of the program.
    - Reads order and order item data from CSV files.
    - Performs an inner join on the data.
    - Applies filtering logic from command-line arguments.
    - Computes order totals.
    - Writes results to both a CSV file and a database.
    @return Unit () *)
let () = 
  (* EXTRACT *)
  let order_data: order list = read_order_url "https://raw.githubusercontent.com/JoaoLucasMBC/etl-ocaml/refs/heads/main/etl/data/order.csv" in
  let order_item_data: order_item list = read_order_item_url "https://raw.githubusercontent.com/JoaoLucasMBC/etl-ocaml/refs/heads/main/etl/data/order_item.csv" in
  let filter: (item_join_order->bool) = process_filter in
  let joined_data: item_join_order list = inner_join order_data order_item_data in
  (* TRANSFORM *)
  let processed_values: order_total list = transform_orders ~filter joined_data in
  (* LOAD *)
  write_order_total_to_db "./data/output.db" processed_values ;
  let avg_income_tax_values: avg_income_tax list = calculate_avg_income_and_tax_by_year_month processed_values in
  write_avg_income_tax_monthly_to_db "./data/output.db" avg_income_tax_values ;;