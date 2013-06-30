(in-package :pms)

(defclass input-file ()
  ((path :initarg :path :accessor file-path)
   (depends-on :initform nil :accessor file-depends-on)))

(defgeneric parse-requires (input-file))

(defmethod print-object ((file input-file) stream)
  (print-unreadable-object (file stream)
    (format stream "~A depends-on:~{~%    ~A~}" (file-path file)
	    (iter (for d in (file-depends-on file))
		  (collect
		      (if (typep d 'input-file)
			  (file-path d)
			  (format nil "{~A: ~A}" (type-of d) d)))))))

(defvar *file-types* (make-hash-table :test #'equal))

(defun register-file-type (type class)
  (setf (gethash (string-downcase type) *file-types*)
	class))

(defun get-file-class (type)
  (or (gethash (string-downcase type) *file-types*)
      (error "Unknown file type '~A'." type)))


(defun make-input-file (pathname)
  (make-instance (get-file-class (pathname-type pathname))
		 :path pathname))



(defun match-all-first-groups (regex target-string)
  (let (result)
    (do-register-groups (f) (regex target-string)
      (push f result))
    (nreverse result)))

(defmacro with-hash ((hash arg) &body body)
  (let ((result (gensym)))
    `(let ((,result (gethash ,arg ,hash)))
       (if ,result
	   ,result
	   (progn
	     (setf (gethash ,arg ,hash) ,arg)
	     (setf (gethash ,arg ,hash)
		   (progn
		     ,@body)))))))

(defmacro once ((hash arg) &body body)
  `(unless (gethash ,arg ,hash)
     (setf (gethash ,arg ,hash) t)
     ,@body))

(defun process-file (filename)
  (let ((files (make-hash-table :test #'equal)))

    ;; load
    (labels ((make-file (pathname)
	       (with-hash (files pathname)
		 (let* ((file (make-input-file pathname))
			(required (parse-requires file)))
		   (setf (file-depends-on file)
			 (mapcar #'make-file required))
		   file))))
      (let ((root (make-file (fad:canonical-pathname (parse-namestring filename)))))

	;; link dependencies
	(dolist (file (hash-table-values files))
	  (when (typep file 'input-file)
	    (setf (file-depends-on file)
		  (mapcar (lambda (f)
			    (if (typep f 'input-file)
				f
				(gethash f files)))
			  (file-depends-on file)))))

	;; linearize
	(let ((s (make-hash-table :test #'equal))
	      result)
	  (labels ((traverse (file)
		     (once (s file)
		       (dolist (f (file-depends-on file))
			 (traverse f))
		       (push file result))))
	    (traverse root)
	    (nreverse result)))))))

