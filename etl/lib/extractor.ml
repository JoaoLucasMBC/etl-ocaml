open Helper ;;

type order = { 
  id: int; 
  client_id: int; 
  order_date: Ptime.t; 
  status: int; 
  origin: int; 
} ;;

type order_item = { 
  order_id: int; 
  product_id: int; 
  quantity: int; 
  price: float; 
  tax: float; 
} ;;

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

let order_csv_to_record lst =
  match lst with
  | [] -> []
  | _ :: t -> List.map parse_order t ;;

let order_item_csv_to_record lst =
  match lst with  
  | [] -> []
  | _ :: t -> List.map parse_order_item t ;;


let read_csv path convert =
  let file = open_in path in
  let data = Csv.load_in file in
  close_in file;
  convert data ;;


let read_order_csv path =
  read_csv path order_csv_to_record ;;

let read_order_item_csv path = 
  read_csv path order_item_csv_to_record ;;


(* Assisted by GPT *)
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

let rec inner_join (order_lst: order list) (item_lst: order_item list) : item_join_order list =
  match item_lst with
  | [] -> []
  | item :: t -> 
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