;;;; fn.asd

(asdf:defsystem #:rationalized-decimal-reader
  :description "Write a base 10 rational as a float"
  :author "Chris Bagley (Baggers) <techsnuffle@gmail.com>"
  :license "Public Domain"
  :serial t
  :depends-on (#:named-readtables)
  :components ((:file "package")
               (:file "rationalized-decimal-reader")))
