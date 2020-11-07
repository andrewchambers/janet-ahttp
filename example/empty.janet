(import ahttp)

(defn handler 
  [req]
  @{:status 404
    :headers {"Content-Type" "text/plain"}}
    :body "not found!")

(defn main
  [&]
  (ahttp/server "localhost" 8080 handler))
