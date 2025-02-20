let () = 
  let data = Etl.Extractor.read_csv "data/order.csv" in
  List.iter (fun row -> print_endline (String.concat ", " row)) data ;;