(in-package :asdf-user)

(defsystem "bytecurry.asdf-ext"
  :class :package-inferred-system
  :author "Thayne McCombs"
  :maintainer "Thayne McCombs"
  :mailto "bytecurry.software@gmail.com"
  :license "MIT"
  :defsystem-depends-on (:asdf-package-system)
  :depends-on (:bytecurry.asdf-ext/interface))
