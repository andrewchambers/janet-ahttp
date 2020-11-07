# Janet ahttp

ahttp is an async aware http server for janet. Requests may happen concurrently using
janet's native coroutines.

Documentation pending...

# Example

```
(import ahttp)

(defn handler 
  [req]
  @{:status 200
    :body "hello!"
    :headers {"Content-Type" "text/plain"}})

(defn main
  [&]
  (ahttp/server "localhost" 8080 handler))
```

