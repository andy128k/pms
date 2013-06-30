(in-package :pms)

(defun output-to-file% (filename body)
  (if filename
      (with-open-file (out filename
			   :direction :output
			   :if-exists :supersede
			   :if-does-not-exist :create)
	(funcall body out))
      (funcall body *standard-output*)))

(defmacro output-to-file ((stream filename) &body body)
  `(output-to-file% ,filename (lambda (,stream)
				,@body)))

(defun save-file (filename content)
  (if filename
      (with-open-file (out filename
			   :direction :output
			   :if-exists :supersede
			   :if-does-not-exist :create)
	(write-string content out)) 
      (write-string content *standard-output*)))

(defmacro catch-all (&body body)
  `(handler-case
       (progn
	 ,@body)
     #+clozure (ccl:process-reset ())
     (t (se)
       (format t "~A~%" se)
       (asdf/image:quit))))

(defparameter *opt-spec*
  '((("output" #\o) :type string :documentation "Write to file instead of standard output.")
    (("help" #\h) :type nil :documentation "Display this help.")))

(defun print-usage-and-die (&optional error &rest params)
  (when error
    (apply #'format t error params)
    (format t "~%~%"))
  (format t "Usage: pms [options] <input-file>~%~%Options:~%")
  (command-line-arguments:show-option-help *opt-spec*)
  (asdf/image:quit))

(defun main ()
  (catch-all

    (multiple-value-bind (options arguments)
	(command-line-arguments:compute-and-process-command-line-options *opt-spec*)

      (when (or (member :help options)
		(/= (length arguments) 1))
	(print-usage-and-die))
      
      (let ((input (first arguments)))
	(output-to-file (stream (second (member :output options)))
	  (write-string (process-file input) stream)))))

  (asdf/image:quit))

