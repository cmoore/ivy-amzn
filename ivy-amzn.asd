
(asdf:defsystem #:ivy-amzn
  :description "Tool for querying the Amazon PA API"
  :author "Clint Moore <clint@ivy.io>"
  :license "Specify license here"

  :depends-on (#:ironclad
               #:drakma
               #:s-base64
               #:local-time
               #:do-urlencode)
  
  :serial t
  :components ((:file "ivy-amzn")))
