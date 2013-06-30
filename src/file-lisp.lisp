(in-package :pms)

(defclass parenscript-file (input-file)
  ())

(defmethod parse-requires ((input-file parenscript-file))
  (let ((path (file-path input-file)))
    (mapcar (lambda (f)
	      (when f
		(fad:canonical-pathname (merge-pathnames f path))))
	    (match-all-first-groups ";\\s*require\\s*(\\S+)\\s*"
				    (read-file-into-string path)))))

(register-file-type "lisp" 'parenscript-file)

