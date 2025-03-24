(** Module for saving the output data into CSV or Sqlite DB *)

open Transformer ;;
open Helper ;;

(** Converts an [order_total_record] into a list of strings for CSV output.
    @param order_total_record The order total record to convert.
    @return A list of string values representing the order total. *)
let unparse_total_order order_total_record =
  [
    unparse_order_id order_total_record.order_id;
    unparse_total_amount order_total_record.total_amout;
    unparse_total_taxes order_total_record.total_taxes
  ] ;;

(** Processes a list of order total records into a format suitable for CSV writing.
    @param order_total_lst A list of order total records.
    @return A list of string lists representing CSV rows. *)
let process_data order_total_lst =
  List.map (fun x -> unparse_total_order x) order_total_lst ;;

(** Writes a list of order total records to a CSV file.
    @param path The file path where the CSV will be written.
    @param order_total_lst The list of order total records to write.
    @return Unit () *)
let write_order_total_to_csv path order_total_lst =
  let file = Csv.to_channel (open_out path) in
  Csv.output_record file ["order_id"; "total_amount"; "total_taxes"];
  Csv.output_all file (process_data order_total_lst);
  Csv.close_out file;
  () ;;


(* https://github.com/cedlemo/ocaml-sqlite3-notes *)
(* SHOULD I ALSO CHECK IF THE TABLE EXISTS AND OTHERWISE CREATE THE TABLE? *)

(** Handles errors gracefully, prints an error message, and exits the program.
    @param error The SQLite3 error code.
    @param message A custom error message.
    @param db The SQLite3 database connection.
    @return This function does not return; it exits the program. *)
let gracefully_exit error message db =
  let () = prerr_endline (Sqlite3.Rc.to_string error) in
  let () = prerr_endline (Sqlite3.errmsg db) in
  let () = prerr_endline message in
  let _closed = Sqlite3.db_close db in
  let () = prerr_endline "Exiting ..." in
  exit 1

(** Cleans the [order_total] table by deleting all rows.
    @param db The SQLite3 database connection.
    @return Unit () *)
let clean_table db table =
  let sql = Printf.sprintf "DELETE FROM %s" table in 
  match Sqlite3.exec db sql with
  | Sqlite3.Rc.OK -> ()
  | r ->
    let message =  "Unable to clean the table order_total." in
    gracefully_exit r message db ;;

(** Writes a list of order total records into an SQLite database.
    @param db_path The path to the SQLite database file.
    @param order_total_lst A list of order total records to insert.
    @return Unit ()
    @raise Failure if insertion fails. *)
let write_order_total_to_db db_path order_total_lst = 
  let db = Sqlite3.db_open db_path in
  clean_table db "order_total";

  (* Recursively inserts each row into the database. *)
  let rec write_row row_lst =
    match row_lst with
    | [] -> print_endline "Insertion ended successfully\n"
    | ot :: rest -> 
      let sql =
        Printf.sprintf "INSERT INTO order_total (order_id, total_amount, total_taxes) VALUES (%d, %.2f, %.2f)" 
          ot.order_id ot.total_amout ot.total_taxes 
      in
      
      (* Execute the SQL statement *)
      let () = match Sqlite3.exec db sql with
      | Sqlite3.Rc.OK ->
        let id = Sqlite3.last_insert_rowid db in
        Printf.printf "Row inserted with id %Ld\n" id
      | r -> 
        prerr_endline (Sqlite3.Rc.to_string r); 
        prerr_endline (Sqlite3.errmsg db)
      
      in write_row rest

  in write_row order_total_lst ;;


(** Writes a list of average income and tax records into an SQLite database.
  @param db_path The path to the SQLite database file.
  @param avg_income_tax_lst A list of average income and tax records to insert.
  @return Unit () *)
let write_avg_income_tax_monthly_to_db db_path (avg_income_tax_lst: avg_income_tax list) =
  let db = Sqlite3.db_open db_path in
  clean_table db "avg_income_tax";

  (* Recursively inserts each row into the database. *)
  let rec write_row (row_lst: avg_income_tax list) =
    match row_lst with
    | [] -> print_endline "Insertion ended successfully\n"
    | at :: rest -> 
      let sql =
        Printf.sprintf "INSERT INTO avg_income_tax (month_year, avg_income, avg_tax) VALUES ('%s', %.2f, %.2f)" 
          at.month_year at.avg_income at.avg_tax 
      in
      
      (* Execute the SQL statement *)
      let () = match Sqlite3.exec db sql with
      | Sqlite3.Rc.OK ->
        let id = Sqlite3.last_insert_rowid db in
        Printf.printf "Row inserted with id %Ld\n" id
      | r -> 
        prerr_endline (Sqlite3.Rc.to_string r); 
        prerr_endline (Sqlite3.errmsg db)
      
      in write_row rest

  in write_row avg_income_tax_lst ;;