(import pico-http-parser :as parser)

(def- status-msgs
  {100 "Continue"
   101 "Switching Protocols"
   200 "OK"
   201 "Created"
   202 "Accepted"
   203 "Non-Authoritative Information"
   204 "No Content"
   205 "Reset Content"
   206 "Partial Content"
   300 "Multiple Choices"
   301 "Moved Permanently"
   302 "Found"
   303 "See Other"
   304 "Not Modified"
   305 "Use Proxy"
   307 "Temporary Redirect"
   400 "Bad Request"
   401 "Unauthorized"
   402 "Payment Required"
   403 "Forbidden"
   404 "Not Found"
   405 "Method Not Allowed"
   406 "Not Acceptable"
   407 "Proxy Authentication Required"
   408 "Request Time-out"
   409 "Conflict"
   410 "Gone"
   411 "Length Required"
   412 "Precondition Failed"
   413 "Request Entity Too Large"
   414 "Request-URI Too Large"
   415 "Unsupported Media Type"
   416 "Requested range not satisfiable"
   417 "Expectation Failed"
   500 "Internal Server Error"
   501 "Not Implemented"
   502 "Bad Gateway"
   503 "Service Unavailable"
   504 "Gateway Time-out"
   505 "HTTP Version not supported"})

(defn handle-http-request
  [stream handler]

  (defn read-request-head
    [stream p buf]
    (net/read stream 4096 buf)
    (printf "reading request %j" buf)
    (def req (parser/parse p buf))
    (cond
      (= req :want-more)
      (read-request-head stream p buf)
      (= req :parse-error)
      nil
      req))

  (def buf @"")

  (when-let [req (read-request-head stream (parser/new) buf)]
    (when-let [body-len (get-in req [:headers "Content-Length"])]
      (if-let [body-len (scan-number body-len)]
        (net/chunk stream (- body-len (length buf)) buf)
        (errorf "invalid request Content-Length")))
    (put req :body buf)

    (def resp (handler req))
    (def status (get resp :status 200))
    (def status-msg (get status-msgs status "Unknown Failure"))

    # Reuse buffer, messy but more efficient.
    (buffer/clear buf)
    (buffer/format buf "HTTP/1.1 %d %s\r\n" status status-msg)
    (when-let [headers (get resp :headers)]
      (eachk h headers
        (buffer/format buf "%s: %s\r\n" h (in headers h))))
    (buffer/push-string buf "\r\n")
    (net/write stream buf)
    (when-let [body (get resp :body)]
      (net/write stream body))))

(defn server
  [host port handler]
  (net/server
    host port
    (fn [stream]
      (defer (net/close stream)
        (handle-http-request stream handler)))))
