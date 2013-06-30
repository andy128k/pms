(in-package :pms)

(defclass closure-template-file (input-file)
  ())

(defmethod parse-requires ((input-file closure-template-file))
  (let ((path (file-path input-file)))
    (mapcar (lambda (f)
	      (when f
		(fad:canonical-pathname (merge-pathnames f path))))
	    (match-all-first-groups "//=\\s*require\\s*(\\S+)\\s*"
				    (read-file-into-string path)))))

(register-file-type "tmpl" 'closure-template-file)


#|
(closure-template:compile-template :javascript-backend input)
|#

