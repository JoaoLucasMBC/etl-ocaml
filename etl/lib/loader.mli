(** Module for saving the output data into CSV or Sqlite DB *)

open Transformer ;;

(** Writes a list of order total records to a CSV file.
    @param path The file path where the CSV will be written.
    @param order_total_lst The list of order total records to write.
    @return Unit () *)
val write_order_total_to_csv : string -> order_total list -> unit ;;

(** Writes a list of order total records into an SQLite database.
    @param db_path The path to the SQLite database file.
    @param order_total_lst A list of order total records to insert.
    @return Unit () *)
val write_order_total_to_db : string -> order_total list -> unit ;;
