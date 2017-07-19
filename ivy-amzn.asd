
(asdf:defsystem #:ivy-amzn
  :description "Tool for querying the Amazon PA API"
  :author "Clint Moore <clint@ivy.io>"
  :license "Specify license here"

  :depends-on (#:cxml
               #:cxml-stp
               #:xpath

               #:ironclad
               #:drakma
               #:s-base64
               #:log4cl)
  
  :serial t
  :components ((:file "ivy-amzn")))
