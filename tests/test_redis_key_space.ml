(* Tests for "Commands operating on the key space" *)

let test_keys () =
    let test_func connection =
        Redis.set "rory" "cool" connection;
        Redis.set "tim" "uncool" connection;
        assert(["rory"; "tim"] = Redis.keys "*" connection)
    in
    Script.use_test_script
        [
            Script.ReadThisLine("SET rory 4");
            Script.ReadThisLine("cool");
            Script.WriteThisLine("+OK");
            Script.ReadThisLine("SET tim 6");
            Script.ReadThisLine("uncool");
            Script.WriteThisLine("+OK");
            Script.ReadThisLine("KEYS *");
            Script.WriteThisLine("$8");
            Script.WriteThisLine("rory tim")
        ]
        test_func;;

let test_randomkey () =
    let test_func connection =
        Redis.set "rory" "cool" connection;
        assert("rory" = Redis.randomkey connection)
    in
    Script.use_test_script
        [
            Script.ReadThisLine("SET rory 4");
            Script.ReadThisLine("cool");
            Script.WriteThisLine("+OK");
            Script.ReadThisLine("RANDOMKEY");
            Script.WriteThisLine("+rory")
        ]
        test_func;;

let test_rename () =
    let test_func connection = 
        Redis.set "rory" "cool" connection;
        Redis.rename "rory" "tim" connection
    in
    Script.use_test_script
        [
            Script.ReadThisLine("SET rory 4");
            Script.ReadThisLine("cool");
            Script.WriteThisLine("+OK");
            Script.ReadThisLine("RENAME rory tim");
            Script.WriteThisLine("+OK")
        ]
        test_func;;

let test_renamenx () =
    let test_func connection = 
        Redis.set "rory" "cool" connection;
        Redis.set "tim" "not cool" connection;
        assert( false == Redis.renamenx "rory" "tim" connection)
    in
    Script.use_test_script
        [
            Script.ReadThisLine("SET rory 4");
            Script.ReadThisLine("cool");
            Script.WriteThisLine("+OK");
            Script.ReadThisLine("SET tim 8");
            Script.ReadThisLine("not cool");
            Script.WriteThisLine("+OK");
            Script.ReadThisLine("RENAMENX rory tim");
            Script.WriteThisLine(":0")
        ]
        test_func;;
