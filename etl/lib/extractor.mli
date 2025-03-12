(** Module for processing orders and order items from CSV files and URLs. *)

(** Represents an order with relevant details. *)
type order = { 
  id: int;  (** Unique identifier for the order. *)
  client_id: int;  (** Identifier of the client who placed the order. *)
  order_date: Ptime.t;  (** Timestamp when the order was placed. *)
  status: int;  (** Status of the order (e.g., pending, shipped, completed). *)
  origin: int;  (** Origin of the order (e.g., store, online, mobile app). *)
}

(** Represents an item within an order. *)
type order_item = { 
  order_id: int;  (** ID of the associated order. *)
  product_id: int;  (** ID of the purchased product. *)
  quantity: int;  (** Quantity of the product ordered. *)
  price: float;  (** Price per unit of the product. *)
  tax: float;  (** Tax applied to the product. *)
}

(** Represents a joined record combining order and item details. *)
type item_join_order = {
  order_id: int;  (** ID of the associated order. *)
  client_id: int;  (** ID of the client who placed the order. *)
  order_date: Ptime.t;  (** Timestamp when the order was placed. *)
  status: int;  (** Status of the order. *)
  origin: int;  (** Origin of the order. *)
  product_id: int;  (** ID of the product ordered. *)
  quantity: int;  (** Quantity of the product ordered. *)
  price: float;  (** Price per unit of the product. *)
  tax: float;  (** Tax applied to the product. *)
}

(** Reads an order CSV file and returns a list of orders. 
    @param path The file path of the CSV.
    @return A list of [order] records. *)
val read_order_csv : string -> order list

(** Reads an order item CSV file and returns a list of order items.
    @param path The file path of the CSV.
    @return A list of [order_item] records. *)
val read_order_item_csv : string -> order_item list

(** Reads an order CSV file from a URL and returns a list of orders.
    @param url The URL pointing to the CSV file.
    @return A list of [order] records. *)
val read_order_url : string -> order list

(** Reads an order item CSV file from a URL and returns a list of order items.
    @param url The URL pointing to the CSV file.
    @return A list of [order_item] records. *)
val read_order_item_url : string -> order_item list

(** Filters an [item_join_order] record based on command-line parameters.
    Filters by order status and origin if provided.
    @param item The [item_join_order] record to filter.
    @return [true] if the record passes the filters, otherwise [false]. *)
val process_filter: item_join_order -> bool

(** Performs an inner join between a list of orders and a list of order items.
    @param order_list The list of orders.
    @param item_list The list of order items.
    @return A list of [item_join_order] records.
    @raise Failure if an order item does not have a corresponding order. *)
val inner_join: order list -> order_item list -> item_join_order list