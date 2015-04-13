(uiop:define-package :bytecurry.asdf-ext/atdoc
    (:use :cl :asdf)
  (:import-from :bytecurry.asdf-ext/doc-op #:doc-op)
  (:import-from :uiop #:symbol-call #:subpathname #:ensure-list)
  (:export #:atdoc-docs
           #:atdoc-html))

(in-package :bytecurry.asdf-ext/atdoc)

(defclass atdoc-docs (child-component)
  ((packages :initarg :packages :accessor atdoc-packages)
   (title :initarg :title :initform nil))
  (:documentation "Operation to create atdoc documentation for a system."))

(defmethod source-file-type ((comp atdoc-docs) sys)
  "The pathname of the docs should be the directory to store the documentation in."
  :directory)

(defun atdoc-docs-title (comp)
  "Get the title to use for the atdoc documentations."
  (or (slot-value comp 'title)
      (component-name (component-system comp))))

(defmethod perform ((op compile-op) (c atdoc-docs))
  nil)

(defmethod perform ((op load-op) (c atdoc-docs))
  nil)

(defmethod component-depends-on ((op doc-op) (c atdoc-docs))
  (cons (list 'load-op (find-system :atdoc)) (call-next-method)))

(defclass atdoc-html (atdoc-docs)
  ((single-page-p :initarg :single-page-p :initform nil :type boolean)
   (css :initarg :css :initform :default
        :type (or symbol string pathname)
        :documentation "This is used for the css argument to @code{generate-html-documentation}.
It can be a symbol, string, or pathname.

If it is a symbol, then the downcased name of symbol will name be used as the name of a
stylesheet in the css directory of the atdoc installation. Otherwise, the the path is resolved
relative to the path of the parent component (usually the system) with a type of \"css\".
In the latter case path resolution works the same way as for other source files.")
   (include-slot-definitions-p :initarg :include-slot-definitions
                               :initform nil :type boolean)
   (include-internal-symbols-p :initarg :include-internal-symbols-p
                               :initform t :type boolean))
  (:documentation "Component to generate HTML documentation with atdoc."))

(defmethod initialize-instance :after ((instance atdoc-html) &rest initargs)
  (declare (ignorable initargs))
  (with-slots (css) instance
    (setf css (if (symbolp css)
                  (format nil "~(~a~).css" (symbol-name css))
                  (subpathname (component-pathname (component-parent instance))
                               css :type "css")))))

(defmethod perform ((op doc-op) (c atdoc-html))
  (with-slots (packages
               single-page-p
               css
               include-internal-symbols-p
               include-slot-definitions-p) c
    (let ((doc-dir (component-pathname c))
          (title (atdoc-docs-title c)))
      (ensure-directories-exist doc-dir)
      (format *standard-output* "Generating atdoc docs")
      (symbol-call '#:atdoc '#:generate-html-documentation
                   (ensure-list packages)
                   doc-dir
                   :index-title title
                   :heading title
                   :single-page-p single-page-p
                   :css css
                   :include-slot-definitions-p include-slot-definitions-p
                   :include-internal-symbols-p include-internal-symbols-p))))

(defmethod input-files ((op doc-op) (c atdoc-html))
  (let ((inputs (call-next-method))
        (css-file (slot-value c 'css)))
    (if (pathnamep css-file)
        (cons css-file inputs)
        inputs)))

(defmethod output-files ((op doc-op) (c atdoc-html))
  (let ((doc-dir (component-pathname c)))
    (values (list doc-dir
                  (subpathname doc-dir "index.html"))
            t)))

(import 'bytecurry.asdf-ext/atdoc:atdoc-html :asdf)
