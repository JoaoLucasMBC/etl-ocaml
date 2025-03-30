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

(** Represents the total amount and taxes for an order. *)
type order_total = {
  order_id: int;  (** Unique identifier for the order. *)
  total_amout: float;  (** Total amount spent on the order. *)
  total_taxes: float;  (** Total taxes applied to the order. *)
  order_date: Ptime.t
} ;;

(** Record to store the average income and average tax by a month-year *)
type avg_income_tax = {
  month_year: string;  (** The month-year for the record. *)
  avg_income: float;  (** The average income for the month-year. *)
  avg_tax: float  (** The average tax for the month-year. *)
} ;;