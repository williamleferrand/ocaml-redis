Redis client library for Ocaml
==============================

ocaml-redis implements the client spec of the [Redis key-value store](http://code.google.com/p/redis/).

It currently only implements the commands listed in the following subsection of the [Redis Command Reference](http://code.google.com/p/redis/wiki/CommandReference) for Redis 1.2.5:

 * Connection handling
 * Commands operating on all the kind of values
 * Commands operating on string values
 * Commands operating on lists
 * Commands operating on sets
 * Commands operating on sorted sets (zsets)
 * Sorting
 * Persistence control commands
 * Remote server control commands
  * INFO
  * SLAVEOF

### Missing:

* Remote server control commands
    * MONITOR

Example Usage
-------------

    >> let conn = Redis.create_connection ()
    in
    begin
        Redis.lpush "redis" "works" conn;
        Redis.lpush "redis" "fast" conn;
        Redis.lpush "redis" "simple" conn;
        List.map Redis.string_of_bulk_data
            (Redis.lrange "redis" 0 2 conn);
    end;;
    ["simple"; "fast"; "works"]

Building
--------

To build the library,

    rake library

should do the trick. From there, you will have to statically link build/redis.cmx, build/redis.cmo and build/redis.cmi with your code.

Testing
-------

To run all the unit tests, execute:

    rake test

To run a simple smoke test on a redis server *you do not mind completely wiping* running on your localhost, execute:

    rake smoke_test

Todo
----

 * Docs
     * Split up docs, provide examples
     * Document testing, both unit tests and smoke tests
 * Building
     * Move away from Rake and use Ocaml Make

 * Implement all missing keywords from 1.2.5:
     * Remote server control commands
         * MONITOR
