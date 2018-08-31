;;; urweb-flycheck.el --- Flycheck: Ur/Web support   -*- lexical-binding: t; -*-

;; Copyright (C) 2018 Artyom Shalkhakov <artyom.shalkhakov@gmail.com>

;; Author:
;;   Artyom Shalkhakov <artyom.shalkhakov@gmail.com>
;;   David Christiansen <david@davidchristiansen.dk>
;;
;; Keywords: tools, languages, convenience
;; Version: 0.1
;; Package-Requires: ((emacs "24.1") (flycheck "0.22"))

;; This file is not part of GNU Emacs, but it is distributed under the
;; same conditions.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING. If not, write to the
;; Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;; This Flycheck extension provides an 'urweb' syntax checker.
;;
;; # Setup
;;
;; Put the following into your 'init' file:
;;
;; (with-eval-after-load 'flycheck (urweb-flycheck-setup))
;;
;; Ensure that the Ur/Web compiler is in your PATH
;;

;;; Code:

(require 'flycheck)

(flycheck-define-checker urweb
  "Ur/Web checker"
  :command ("urweb" "-tc"
            (eval (file-name-sans-extension
                   (car (flycheck-substitute-argument 'source-original
                                                 'urweb)))))
  ;; filename:1:0: (to 1:0) syntax error found at SYMBOL
  ;; /home/artyom/projects/urweb-test/test.ur:1:0: (to 1:38) Some constructor unification variables are undetermined in declaration
  ;; (look for them as "<UNIF:...>")
  ;; Decl:
  ;; val rec
  ;;  help :
  ;;   {} -> <UNIF:E::Type -> Type> (xml <UNIF:G::{Unit}> <UNIF:H::{Type}> ([])) =
  ;;   fn $x : {} =>
  ;;    case $x of
  ;;     {} =>
  ;;      return [<UNIF:E::Type -> Type>]
  ;;       [xml <UNIF:G::{Unit}> <UNIF:H::{Type}> ([])] _
  ;;       (Basis.cdata [<UNIF:G::{Unit}>] [<UNIF:H::{Type}>] "Hello!")

  :error-patterns
  ((error line-start (file-name) ":" line ":" column ":"
          " (to " (1+ num) ?: (1+ num) ")"
          ;; AS: indebted to David Christiansen for this rx expression!
          (message (and (* nonl) (* "\n" (not (any "/" "~")) (* nonl))))))
  :modes (urweb-mode))

;;;###autoload
(defun urweb-flycheck-setup ()
  "Setup Flycheck Ur/Web.

Add `urweb' to `flycheck-checkers'."
  (interactive)
  (add-to-list 'flycheck-checkers 'urweb))

(provide 'urweb-flycheck)
;;; urweb-flycheck.el ends here
