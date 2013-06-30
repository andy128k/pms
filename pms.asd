(in-package :asdf)

(defsystem "pms"
  :description "Pimp My Scripts"
  :depends-on (:alexandria
	       :cl-ppcre
	       :cl-fad
	       :iterate

	       :asdf-driver
	       :command-line-arguments

	       :closure-template
	       :cl-uglify-js
	       :parenscript)
  :serial t
  :components ((:file "src/package")
	       (:file "src/file")
	       (:file "src/file-js")
	       (:file "src/file-tmpl")
	       (:file "src/pms")))

