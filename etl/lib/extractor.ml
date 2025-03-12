(** Module for processing orders and order items from CSV files and URLs. *)

open Helper ;;

(** Represents an order with an ID, client ID, order date, status, and origin. *)
type order = { 
  id: int; 
  client_id: int; 
  order_date: Ptime.t; 
  status: int; 
  origin: int; 
} ;;

(** Represents an item in an order, including the order ID, product ID, quantity, price, and tax. *)
type order_item = { 
  order_id: int; 
  product_id: int; 
  quantity: int; 
  price: float; 
  tax: float; 
} ;;

(** Represents a joined record of an order and its items, including order and item details. This is used after an INNER JOIN
    operation on the order and order_item tables. 
*)
type item_join_order = {
  order_id: int;
  client_id: int;
  order_date: Ptime.t;
  status: int;
  origin: int;
  product_id: int;
  quantity: int;
  price: float;
  tax: float;
} ;;

(** Parses a list of strings into an [order] record.
    @param order The list of strings representing an order row read from a csv source.
    @return The parsed [order] record.
    @raise Failure if the input does not match the expected format.
*)
let parse_order order =
  match order with
  | id :: client_id :: order_date :: status :: origin :: [] -> 
    { 
      id = parse_id id;
      client_id = parse_client_id client_id;
      order_date = parse_order_date order_date;
      status = parse_order_status status;
      origin = parse_order_origin origin
    }
  | _ -> failwith "Invalid order" ;;

(** Parses a list of strings into an [order_item] record.
    @param order_item The list of strings representing an order item row from a csv source.
    @return The parsed [order_item] record.
    @raise Failure if the input does not match the expected format.
*)
let parse_order_item order_item =
  match order_item with
  | order_id :: product_id :: quantity :: price :: tax :: [] -> 
    { 
      order_id = parse_order_id order_id;
      product_id = parse_product_id product_id;
      quantity = parse_quantity quantity;
      price = parse_price price;
      tax = parse_tax tax
    }
  | _ -> failwith "Invalid order item" ;;

(** Converts a list of orders read from a CSV source into a list of [order] records.
    @param lst The list of CSV rows.
    @return A list of parsed [order] records.
*)
let order_csv_to_record lst =
  match lst with
  | [] -> []
  | _ :: t -> List.map parse_order t ;;

(** Converts a list of order items from a CSV source into a list of [order_item] records.
    @param lst The list of CSV rows.
    @return A list of parsed [order_item] records.
*)
let order_item_csv_to_record lst =
  match lst with  
  | [] -> []
  | _ :: t -> List.map parse_order_item t ;;

(** Reads a CSV file and applies a conversion function.
    @param path The file path.
    @param convert The conversion function to apply to the CSV data (to transform it into records).
    @return The converted data.
*)
let read_csv path convert =
  let file = open_in path in
  let data = Csv.load_in file in
  close_in file;
  convert data ;;

(** Reads an order CSV file and returns a list of [order] records.
    @param path The file path.
    @return A list of [order] records.
*)
let read_order_csv path =
  read_csv path order_csv_to_record ;;

(** Reads an order item CSV file and returns a list of [order_item] records.
    @param path The file path.
    @return A list of [order_item] records.
*)
let read_order_item_csv path = 
  read_csv path order_item_csv_to_record ;;

(* GPT ASSISTED *)
(** Processes command-line arguments to filter orders.
    Supports filtering by order status and order origin.
    @return A filtering function that can create [item_join_order] records.
*)
let process_filter: (item_join_order -> bool) =
  let status_ref = ref None in
  let origin_ref = ref None in

  let set_status s = status_ref := Some (parse_order_status s) in
  let set_origin o = origin_ref := Some (parse_order_origin o) in

  let specs = [
    ("--status", Arg.String set_status, "Filter by order status");
    ("--origin", Arg.String set_origin, "Filter by order origin")
  ] in

  let usage_msg = "Usage: program_name [--status STATUS] [--origin ORIGIN]" in
  Arg.parse specs (fun _ -> ()) usage_msg;

  let filter_fn (i: item_join_order) =
    (match !status_ref with
    | Some s -> i.status = s
    | None -> true)
    &&
    (match !origin_ref with
    | Some o -> i.origin = o
    | None -> true)
  in
  filter_fn

(** Performs an inner join between orders and order items.
    @param order_lst The list of orders.
    @param item_lst The list of order items.
    @return A list of joined records ([item_join_order]).
    @raise Failure if an order item does not have a corresponding order.
*)
let rec inner_join (order_lst: order list) (item_lst: order_item list) : item_join_order list =
  match item_lst with
  | [] -> []
  | item :: t -> 
    (* For every item, it finds its order to create the new record *)
    match List.find_opt (fun (o: order) -> o.id = item.order_id) order_lst with
    | Some o -> {
                  order_id = item.order_id;
                  client_id = o.client_id;
                  order_date = o.order_date;
                  status = o.status;
                  origin = o.origin;
                  product_id = item.product_id;
                  quantity = item.quantity;
                  price = item.price;
                  tax = item.tax
                } :: inner_join order_lst t
    | _ -> failwith "Every item must have an order" ;;

(** Fetches the contents of a URL.
    @param url The URL to fetch.
    @return The response body as a string.
*)
let fetch url =
  let uri = (Uri.of_string url) in
  let (_, body) = Lwt_main.run (Cohttp_lwt_unix.Client.get uri) in
  let body_str = Lwt_main.run (Cohttp_lwt.Body.to_string body) in
  body_str ;;

(** Reads a CSV file from a URL and applies a conversion function.
    @param url The CSV file URL.
    @param convert The conversion function to apply to the CSV data (ti transform it into records).
    @return The converted data.
*)
let read_csv_url url convert =
  let raw_data = fetch url in
  let data = Csv.of_string raw_data |> Csv.input_all in
  convert data;;

(** Reads an order CSV file from a URL and returns a list of [order] records.
    @param url The URL of the raw csv in the internet.
    @return A list of [order] records.
*)
let read_order_url url =
  read_csv_url url order_csv_to_record ;;

(** Reads an order item CSV file from a URL and returns a list of [order_item] records.
    @param url The URL of the raw csv in the internet.
    @return A list of [order_item] records.
*)
let read_order_item_url url =
  read_csv_url url order_item_csv_to_record ;;
