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
