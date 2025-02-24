open Transformer ;;
open Helper ;;

let unparse_total_order order_total_record =
  [
    unparse_order_id order_total_record.order_idd;
    unparse_total_amount order_total_record.total_amout;
    unparse_total_taxes order_total_record.total_taxes
  ] ;;

let process_data order_total_lst =
  List.map (fun x -> unparse_total_order x) order_total_lst ;;

let write_order_total_to_csv path order_total_lst =
  let file = Csv.to_channel (open_out path) in
  Csv.output_record file ["order_id"; "total_amount"; "total_taxes"];
  Csv.output_all file (process_data order_total_lst);
  Csv.close_out file;
  () ;;