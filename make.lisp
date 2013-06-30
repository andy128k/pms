(ql:quickload :pms)
(setf asdf/image:*image-entry-point* 'pms:main)
(asdf/image:dump-image "pms" :executable t)

