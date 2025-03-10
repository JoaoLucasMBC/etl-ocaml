open Transformer ;;
open Helper ;;

let unparse_total_order order_total_record =
  [
    unparse_order_id order_total_record.order_id;
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


(* https://github.com/cedlemo/ocaml-sqlite3-notes *)
(* SHOULD I ALSO CHECK IF THE TABLE EXISTS AND OTHERWISE CREATE THE TABLE? *)
let gracefully_exit error message db =
  let () = prerr_endline (Sqlite3.Rc.to_string error) in
  let () = prerr_endline (Sqlite3.errmsg db) in
  let () = prerr_endline message in
  let _closed = Sqlite3.db_close db in
  let () = prerr_endline "Exiting ..." in
  exit 1

let clean_table db =
  let sql = "DELETE FROM order_total" in
  match Sqlite3.exec db sql with
  | Sqlite3.Rc.OK -> ()
  | r ->
    let message =  "Unable to clean the table order_total." in
    gracefully_exit r message db ;;

let write_order_total_to_db db_path order_total_lst = 
  let db = Sqlite3.db_open db_path in
  clean_table db;

  let rec write_row row_lst =
    match row_lst with
    | [] -> print_endline "Insertion ended succesfully\n"
    | ot :: rest -> 
      let sql =
        Printf.sprintf "INSERT INTO order_total (order_id, total_amount, total_taxes) VALUES (%d, %.2f, %.2f)" ot.order_id ot.total_amout ot.total_taxes 
      in
      
      let () = match Sqlite3.exec db sql with
      | Sqlite3.Rc.OK ->
        let id = Sqlite3.last_insert_rowid db in
        Printf.printf "Row inserted with id %Ld\n" id
      | r -> prerr_endline (Sqlite3.Rc.to_string r); prerr_endline (Sqlite3.errmsg db)
      
      in write_row rest

  in write_row order_total_lst ;;