(import ahttp)

(defn handler 
  [req]
  @{:status 200
    :body "hello!"
    :headers {"Content-Type" "text/plain"}})

(defn main
  [&]
  (ahttp/server "localhost" 8080 handler))
