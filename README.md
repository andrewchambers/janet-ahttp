# Janet ahttp

ahttp is an async aware http server for janet. Requests may happen concurrently using
janets native coroutines.

Documentation pending...

# Example

```
(import ahttp)

(defn handler 
  [req]
  @{:status 404
    :body "not found!"
    :headers {"Content-Type" "text/plain"}})

(defn main
  [&]
  (ahttp/server "localhost" 8080 handler))
```

