(* Copyright (C) 2009 Rory Geoghegan - r.geoghegan@gmail.com
   Released under the BSD license. See the LICENSE.txt file for more info.

   Main library file. *)
open Redis_util

(* Connection handling *)
let ping connection =
    (* PING *)
    (send_and_receive_command "PING" connection) = Status("PONG");;

let create_connection addr port =
    (* From a string of the address, and a port as an int, gets an input and output file discriptor *)
    let server = Unix.inet_addr_of_string addr
    in
    Unix.open_connection(
        Unix.ADDR_INET(server, port)
    )

(* Individual commands *)

(* Commands operating on string values *)
let set key value connection =
    (* SET *)
    begin
        send_text (Printf.sprintf "SET %s %d" key (String.length value)) connection;
        send_text value connection;
        match receive_answer connection with
            Status("OK") -> () |
            Status(x) -> failwith ("Received status(" ^ x ^ ") when setting " ^ key) |
            _ -> failwith "Did not recognize what I got back"
    end;;

let get key connection =
    (* GET *)
    match send_and_receive_command ("GET " ^ key) connection with
        Bulk(x) -> x |
        _ -> failwith "Did not recognize what I got back";;

let getset key new_value connection =
    (* GETSET *)
    send_text (Printf.sprintf "GETSET %s %d" key (String.length new_value)) connection;
    send_text new_value connection;
    match receive_answer connection with
        Bulk(x) -> x |
        _ -> failwith "Did not recognize what I got back";;

let mget keys connection = 
    (* MGET *)
    match send_and_receive_command (Redis_util.aggregate_command "MGET" keys) connection with
        Multibulk(l) -> l |
        _ -> failwith "Did not recognize what I got back";;

let setnx key value connection =
    (* SETNX *)
    begin
        send_text (Printf.sprintf "SETNX %s %d" key (String.length value)) connection;
        send_text value connection;
        match receive_answer connection with
            Integer(0) -> false |
            _ -> true
    end;;

let incr key connection =
    (* INCR *)
    match send_and_receive_command (Printf.sprintf "INCR %s" key) connection with
        Integer(x) -> x |
        _ -> failwith "Did not recognize what I got back";;

let incrby key value connection =
    (* INCR *)
    match send_and_receive_command (Printf.sprintf "INCRBY %s %d" key value) connection with
        Integer(x) -> x |
        _ -> failwith "Did not recognize what I got back";;

let decr key connection =
    (* DECR *)
    match send_and_receive_command (Printf.sprintf "DECR %s" key) connection with
        Integer(x) -> x |
        _ -> failwith "Did not recognize what I got back";;

let decrby key value connection =
    (* DECR *)
    match send_and_receive_command (Printf.sprintf "DECRBY %s %d" key value) connection with
        Integer(x) -> x |
        _ -> failwith "Did not recognize what I got back";;

let exists key connection =
    (* EXISTS *)
    (send_and_receive_command ("EXISTS " ^ key) connection) = Integer(1);;

let del keys connection =
    (* DEL *)
    match send_and_receive_command (Redis_util.aggregate_command "DEL" keys) connection with
        Integer(x) -> x |
        _ -> failwith "Did not recognize what I got back";;

let value_type key connection =
    (* TYPE, unfortunately type is an ocaml keyword, so it cannot be used as a function name *)
    match send_and_receive_command ("TYPE " ^ key) connection with
        Status("string") -> Redis_util.String("") |
        Status("none") -> Redis_util.None |
        _ -> failwith "Did not recognize what I got back";;
    
(* Commands operating on the key space *)

let keys pattern connection =
    (* KEYS *)
    match send_and_receive_command ("KEYS " ^ pattern) connection with
        Bulk(String(x)) -> Str.split (Str.regexp " +") x |
        _ -> failwith "Did not recognize what I got back";;

let randomkey connection =
    (* RANDOMKEY *)
    match send_and_receive_command "RANDOMKEY" connection with
        Status(x) -> x |
        _ -> failwith "Did not recognize what I got back";;
        
let rename oldkey newkey connection =
    (* RENAME *)
    match send_and_receive_command (Printf.sprintf "RENAME %s %s" oldkey newkey) connection with
        Status("OK") -> () |
        Status(x) -> failwith (Printf.sprintf "Received status(%s) when renaming %s to %s" x oldkey newkey) |
        _ -> failwith "Did not recognize what I got back"

let renamenx oldkey newkey connection =
    (* RENAMENX *)
    match send_and_receive_command (Printf.sprintf "RENAMENX %s %s" oldkey newkey) connection with
        Integer(0) -> false |
        Integer(1) -> true |
        _ -> failwith "Did not recognize what I got back";;

let dbsize connection =
    (* DBSIZE *)
    match send_and_receive_command  "DBSIZE" connection with
        Integer(x) -> x |
        _ -> failwith "Did not recognize what I got back";;

let expire key seconds connection =
    (* EXPIRE *)
    match send_and_receive_command (Printf.sprintf "EXPIRE %s %d" key seconds) connection with
        Integer(0) -> false |
        Integer(1) -> true | 
        _ -> failwith "Did not recognize what I got back";;

let ttl key connection =
    (* TTL *)
    match send_and_receive_command ("TTL " ^ key) connection with
        Integer(x) -> x |
        _ -> failwith "Did not recognize what I got back";;

(* Commands operating on lists *)
let rpush key value connection =
    (* RPUSH *)
    begin
        send_text (Printf.sprintf "RPUSH %s %d" key (String.length value)) connection;
        send_text value connection;
        match receive_answer connection with
            Status("OK") -> () |
            Status(x) -> failwith ("Received status(" ^ x ^ ") when setting " ^ key) |
            _ -> failwith "Did not recognize what I got back"
    end;;

let lpush key value connection =
    (* RPUSH *)
    begin
        send_text (Printf.sprintf "LPUSH %s %d" key (String.length value)) connection;
        send_text value connection;
        match receive_answer connection with
            Status("OK") -> () |
            Status(x) -> failwith ("Received status(" ^ x ^ ") when setting " ^ key) |
            _ -> failwith "Did not recognize what I got back"
    end;;

let llen key connection =
    (* LLEN *)
    match send_and_receive_command ("LLEN " ^ key) connection with
        Integer(x) -> x |
        _ -> failwith "Did not recognize what I got back";;

(* Multiple databases handling commands *)
let flushdb connection =
    (* FLUSHDB *)
    (send_and_receive_command "FLUSHDB" connection) = Status("OK");;
