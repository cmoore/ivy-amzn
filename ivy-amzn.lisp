;; -*- mode: Lisp; Syntax: COMMON-LISP; Base: 10; eval: (hs-hide-all) -*-

(defpackage #:ivy-amzn
  (:use #:cl)
  (:export #:find-products
           *amzn-access-key*
           *amzn-secret-key*
           *amzn-associate-tag*))

(in-package #:ivy-amzn)

(defparameter *amzn-access-key* nil)
(defparameter *amzn-secret-key* nil)
(defparameter *amzn-associate-tag* nil)


(defun intermediate-message (qstring timestamp)
  (format nil "GET
webservices.amazon.com
/onca/xml
~a&Timestamp=~a"
          qstring
          (ppcre:regex-replace-all #\: timestamp "%3A")))

(defun hmac-sign-string (key message)
  (let ((hmac (ironclad:make-hmac (ironclad:ascii-string-to-byte-array key) :sha256)))
    (ironclad:update-hmac hmac (ironclad:ascii-string-to-byte-array message))
    (with-output-to-string (sink)
      (s-base64:encode-base64-bytes (ironclad:hmac-digest hmac) sink))))

(defun make-query-string (keywords operation item-attributes search-index)
  (assert (listp item-attributes))
  (let ((url-item-attributes (ppcre:regex-replace
                              "%2C$"
                              (format nil "~{~A%2C~}" item-attributes)
                              "")))
    (format nil "AWSAccessKeyId=~a&AssociateTag=~a&Keywords=~a&Operation=~a&ResponseGroup=~a&SearchIndex=~a&Service=AWSECommerce"
            *amzn-access-key*
            *amzn-associate-tag*
            keywords
            operation
            url-item-attributes
            search-index)))

(defun find-products (&key keywords (operation "ItemSearch") (item-attributes (list "ItemAttributes")) search-index)
  (let* ((timestamp (local-time:format-timestring nil (local-time:now)))
         (qstring (make-query-string keywords operation item-attributes search-index))
         (intermediate (intermediate-message qstring timestamp))
         (signature (hmac-sign-string *amzn-secret-key* intermediate))
         (message (format nil "http://webservices.amazon.com/onca/xml?~a&Timestamp=~a&Signature=~a"
                          qstring
                          timestamp
                          (do-urlencode:urlencode signature))))
    (drakma:http-request message
                         :content-type "application/x-www-form-urlencoded; charset=utf-8"
                         :external-format-out :utf-8
                         :external-format-in :utf-8
                         :preserve-uri t
                         :method :get)))
