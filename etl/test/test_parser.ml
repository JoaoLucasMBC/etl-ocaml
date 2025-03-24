open OUnit2 ;;
open Etl.Helper ;;
open Etl.Extractor ;;


let test_parse_id _ =
  assert_equal 123 (parse_id "123")

let test_parse_client_id _ =
  assert_equal 456 (parse_client_id "456")

let test_parse_order_date _ =
  let date = parse_order_date "2025-03-24T12:34:56" in
  let expected_date =
    match Ptime.of_rfc3339 "2025-03-24T12:34:56Z" with
    | Ok (t, _, _) -> t
    | Error _ -> failwith "Invalid expected date"
  in
  assert_bool "Dates do not match" (Ptime.equal date expected_date)

let test_parse_order_date_invalid _ =
  assert_raises (Failure "Invalid date")
    (fun () -> ignore (parse_order_date "invalid"))

let test_parse_order_status _ =
  assert_equal 0 (parse_order_status "Pending");
  assert_equal 1 (parse_order_status "Complete");
  assert_equal 2 (parse_order_status "Cancelled")

let test_parse_order_status_invalid _ =
  assert_raises (Failure "Status should be either Pending, Complete, or Cancelled")
    (fun () -> ignore (parse_order_status "Unknown"))

let test_parse_order_origin _ =
  assert_equal 0 (parse_order_origin "P");
  assert_equal 1 (parse_order_origin "O")

let test_parse_order_origin_invalid _ =
  assert_raises (Failure "Origin should be either P or O")
    (fun () -> ignore (parse_order_origin "X"))

let test_parse_order_id _ =
  assert_equal 789 (parse_order_id "789")

let test_parse_product_id _ =
  assert_equal 42 (parse_product_id "42")

let test_parse_quantity _ =
  assert_equal 10 (parse_quantity "10")

let test_parse_price _ =
  (* Using a comparison with tolerance for floats *)
  assert_equal ~cmp:(fun a b -> abs_float (a -. b) < 1e-6) 19.99 (parse_price "19.99")

let test_parse_tax _ =
  assert_equal ~cmp:(fun a b -> abs_float (a -. b) < 1e-6) 0.07 (parse_tax "0.07")

let test_unparse_order_id _ =
  assert_equal "123" (unparse_order_id 123)

let test_unparse_total_amount _ =
  assert_equal "123.45" (unparse_total_amount 123.45)

let test_unparse_total_taxes _ =
  assert_equal "12.34" (unparse_total_taxes 12.34)

let test_parse_order _ =
  let input = ["1"; "100"; "2025-03-24T12:00:00"; "Pending"; "P"] in
  let order = parse_order input in
  (* Parse the expected date value *)
  let expected_date =
    match Ptime.of_rfc3339 "2025-03-24T12:00:00Z" with
    | Ok (t, _, _) -> t
    | Error _ -> failwith "Invalid expected date"
  in
  assert_equal 1 order.id;
  assert_equal 100 order.client_id;
  assert_bool "Dates do not match" (Ptime.equal order.order_date expected_date);
  assert_equal 0 order.status;
  assert_equal 0 order.origin

let test_parse_order_invalid _ =
  let input = ["1"; "100"] in
  assert_raises (Failure "Invalid order")
    (fun () -> ignore (parse_order input))

let test_parse_order_item _ =
  let input = ["1"; "10"; "2"; "10.0"; "0.1"] in
  let order_item = parse_order_item input in
  assert_equal 1 order_item.order_id;
  assert_equal 10 order_item.product_id;
  assert_equal 2 order_item.quantity;
  assert_equal ~cmp:(fun a b -> abs_float (a -. b) < 1e-6) 10.0 order_item.price;
  assert_equal ~cmp:(fun a b -> abs_float (a -. b) < 1e-6) 0.1 order_item.tax

let test_parse_order_item_invalid _ =
  let input = ["1"; "10"; "2"] in
  assert_raises (Failure "Invalid order item")
    (fun () -> ignore (parse_order_item input))

let test_order_csv_to_record _ =
  let data = [["header"]; ["1"; "100"; "2025-03-24T12:00:00"; "Pending"; "P"]] in
  let orders = order_csv_to_record data in
  match orders with
  | [o] -> assert_equal 1 o.id
  | _ -> assert_failure "Expected one order record"

let test_order_item_csv_to_record _ =
  let data = [["header"]; ["1"; "10"; "2"; "10.0"; "0.1"]] in
  let items = order_item_csv_to_record data in
  match items with
  | [i] -> assert_equal 1 i.order_id
  | _ -> assert_failure "Expected one order_item record"


let suite =
  "PureFunctionsTestSuite" >::: [
    "test_parse_id" >:: test_parse_id;
    "test_parse_client_id" >:: test_parse_client_id;
    "test_parse_order_date" >:: test_parse_order_date;
    "test_parse_order_date_invalid" >:: test_parse_order_date_invalid;
    "test_parse_order_status" >:: test_parse_order_status;
    "test_parse_order_status_invalid" >:: test_parse_order_status_invalid;
    "test_parse_order_origin" >:: test_parse_order_origin;
    "test_parse_order_origin_invalid" >:: test_parse_order_origin_invalid;
    "test_parse_order_id" >:: test_parse_order_id;
    "test_parse_product_id" >:: test_parse_product_id;
    "test_parse_quantity" >:: test_parse_quantity;
    "test_parse_price" >:: test_parse_price;
    "test_parse_tax" >:: test_parse_tax;
    "test_unparse_order_id" >:: test_unparse_order_id;
    "test_unparse_total_amount" >:: test_unparse_total_amount;
    "test_unparse_total_taxes" >:: test_unparse_total_taxes;
    "test_parse_order" >:: test_parse_order;
    "test_parse_order_invalid" >:: test_parse_order_invalid;
    "test_parse_order_item" >:: test_parse_order_item;
    "test_parse_order_item_invalid" >:: test_parse_order_item_invalid;
    "test_order_csv_to_record" >:: test_order_csv_to_record;
    "test_order_item_csv_to_record" >:: test_order_item_csv_to_record;
  ]

let () =
  run_test_tt_main suite ;;