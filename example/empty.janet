(import ahttp)

(defn handler 
  [req]
  @{:status 404
    :body "not found!"
    :headers {"Content-Type" "text/plain"}})

(defn main
  [&]
  (ahttp/server "localhost" 8080 handler))
