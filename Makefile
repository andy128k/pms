sbcl:
	sbcl --noinform --load make.lisp

ccl:
	lx86cl -l make.lisp

ccl64:
	lx86cl64 -l make.lisp

clisp:
	clisp -q -x '(load "make.lisp")'

