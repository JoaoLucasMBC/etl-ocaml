(* #use "helper.ml" ;; *)

type order = { id: int; client_id: int; order_date: string; status: int; origin: int; } ;;

let read_csv path =
  let file = open_in path in
  let data = Csv.load_in file in
  close_in file;
  data ;;

let parse_order order =
  match order with
  | id :: client_id :: order_date :: status :: origin -> 
    { 
      id = parse_id id;
      client_id = parse_client_id client_id;
      order_date = parse_order_date order_date;
      status = parse_order_status status;
      origin = parse_order_origin origin
    }
  | _ -> failwith "Invalid order" ;;

let rec order_csv_to_record lst =
  match lst with
  | [] -> []
  | h :: t -> parse_order h :: order_csv_to_record t ;;
