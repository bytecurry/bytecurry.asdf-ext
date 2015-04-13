(uiop:define-package :bytecurry.asdf-ext/doc-op
  (:use :asdf :cl)
  (:export #:doc-op
           #:document-system))

(in-package :bytecurry.asdf-ext/doc-op)

(defclass doc-op (selfward-operation downward-operation)
  ((selfward-operation :initform 'load-op :allocation :class)))

(defmethod perform ((o doc-op) (c component))
  nil)

(defun document-system (system &rest args &key force force-not verbose version &allow-other-keys)
  "Shorthand for `(asdf:operate 'asdf:doc-op system)' see OPERATE for details."
  (declare (ignore force force-not verbose version))
  (apply 'operate 'doc-op system args))

(import '(doc-op document-system) :asdf)

(in-package :asdf)

(export '(doc-op document-system) :asdf)
