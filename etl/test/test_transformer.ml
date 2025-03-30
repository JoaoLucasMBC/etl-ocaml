open OUnit2 ;;
open Etl.Transformer ;;
open Etl.Extractor ;;
open Etl.Helper ;;
open Etl.Types ;;

let test_transform_orders _ =
  let date = parse_order_date "2025-03-24T12:00:00" in
  let item1 = { 
    order_id = 1; client_id = 100; order_date = date; 
    status = 0; origin = 0; product_id = 10; 
    quantity = 2; price = 10.0; tax = 0.1 
  } in
  let item2 = { 
    order_id = 1; client_id = 100; order_date = date; 
    status = 0; origin = 0; product_id = 20; 
    quantity = 3; price = 20.0; tax = 0.2 
  } in
  let results = transform_orders [item1; item2] in
  match results with
  | [ot] ->
      assert_equal 1 ot.order_id;
      assert_equal ~cmp:(fun a b -> abs_float (a -. b) < 1e-6) 80.0 ot.total_amout;
      assert_equal ~cmp:(fun a b -> abs_float (a -. b) < 1e-6) 14.0 ot.total_taxes;
      assert_equal (Ptime.to_rfc3339 date) (Ptime.to_rfc3339 ot.order_date)
  | _ -> assert_failure "Expected a single order_total record"

let test_transform_orders_filter _ =
  let date = parse_order_date "2025-03-24T12:00:00" in
  let item = { 
    order_id = 1; client_id = 100; order_date = date; 
    status = 0; origin = 0; product_id = 10; 
    quantity = 2; price = 10.0; tax = 0.1 
  } in
  let results = transform_orders ~filter:(fun _ -> false) [item] in
  assert_equal [] results

let test_group_by_date _ =
  let date1 = parse_order_date "2025-03-24T12:00:00" in
  let date2 = parse_order_date "2025-04-01T00:00:00" in
  let ot1 = { order_id = 1; total_amout = 100.0; total_taxes = 10.0; order_date = date1 } in
  let ot2 = { order_id = 2; total_amout = 200.0; total_taxes = 20.0; order_date = date1 } in
  let ot3 = { order_id = 3; total_amout = 300.0; total_taxes = 30.0; order_date = date2 } in
  let table = group_by_date [ot1; ot2; ot3] in
  assert_equal 2 (Hashtbl.length table);
  let march = Hashtbl.find table "2025-03" in
  let april = Hashtbl.find table "2025-04" in
  assert_equal 2 (List.length march);
  assert_equal 1 (List.length april)

let test_calculate_avg_income_and_tax_by_year_month _ =
  let date1 = parse_order_date "2025-03-24T12:00:00" in
  let date2 = parse_order_date "2025-04-01T00:00:00" in
  let ot1 = { order_id = 1; total_amout = 100.0; total_taxes = 10.0; order_date = date1 } in
  let ot2 = { order_id = 2; total_amout = 200.0; total_taxes = 20.0; order_date = date1 } in
  let ot3 = { order_id = 3; total_amout = 300.0; total_taxes = 30.0; order_date = date2 } in
  let averages = calculate_avg_income_and_tax_by_year_month [ot1; ot2; ot3] in
  (* Create an association list for easier lookup *)
  let avg_map = List.fold_left (fun acc r -> (r.month_year, r) :: acc) [] averages in
  let find_avg month =
    try List.assoc month avg_map
    with Not_found -> failwith ("Missing month " ^ month)
  in
  let march = find_avg "2025-03" in
  let april = find_avg "2025-04" in
  assert_equal ~cmp:(fun a b -> abs_float (a -. b) < 1e-6) 150.0 march.avg_income;
  assert_equal ~cmp:(fun a b -> abs_float (a -. b) < 1e-6) 15.0 march.avg_tax;
  assert_equal ~cmp:(fun a b -> abs_float (a -. b) < 1e-6) 300.0 april.avg_income;
  assert_equal ~cmp:(fun a b -> abs_float (a -. b) < 1e-6) 30.0 april.avg_tax

let test_inner_join _ =
  let order_date = parse_order_date "2025-03-24T12:00:00" in
  let order_rec = { id = 1; client_id = 100; order_date; status = 0; origin = 0 } in
  let order_item_rec = { order_id = 1; product_id = 10; quantity = 2; price = 10.0; tax = 0.1 } in
  let joined = inner_join [order_rec] [order_item_rec] in
  match joined with
  | [j] ->
      assert_equal 1 j.order_id;
      assert_equal 100 j.client_id;
      (* Compare dates directly *)
      let expected_date =
        match Ptime.of_rfc3339 "2025-03-24T12:00:00Z" with
        | Ok (t, _, _) -> t
        | Error _ -> failwith "Invalid expected date"
      in
      assert_bool "Dates do not match" (Ptime.equal j.order_date expected_date);
      assert_equal 0 j.status;
      assert_equal 0 j.origin;
      assert_equal 10 j.product_id;
      assert_equal 2 j.quantity
  | _ -> assert_failure "Expected one joined record"
  

let test_inner_join_no_order _ =
  let order_date = parse_order_date "2025-03-24T12:00:00" in
  let order_rec = { id = 1; client_id = 100; order_date = order_date; status = 0; origin = 0 } in
  let order_item_rec = { order_id = 2; product_id = 10; quantity = 2; price = 10.0; tax = 0.1 } in
  assert_raises (Failure "Every item must have an order")
    (fun () -> ignore (inner_join [order_rec] [order_item_rec]))


let suite =
  "PureFunctionsTestSuite" >::: [
    "test_transform_orders" >:: test_transform_orders;
    "test_transform_orders_filter" >:: test_transform_orders_filter;
    "test_group_by_date" >:: test_group_by_date;
    "test_calculate_avg_income_and_tax_by_year_month" >:: test_calculate_avg_income_and_tax_by_year_month;
    "test_inner_join" >:: test_inner_join;
    "test_inner_join_no_order" >:: test_inner_join_no_order;
  ]

let () =
  run_test_tt_main suite ;;