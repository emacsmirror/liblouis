;;; liblouis.el --- Mode for editing liblouis braille translation tables -*- lexical-binding: t; -*-

;; Copyright (C) 2011-2022 Swiss Library for the Blind, Visually Impaired and Print Disabled

;; Author: Christian Egli <christian.egli@sbs.ch>
;; Maintainer: Christian Egli <christian.egli@sbs.ch>
;; Keywords: languages
;; Version: 0.2
;; Homepage: https://github.com/liblouis/liblouis-mode
;; Package-Requires: ((emacs "26.1"))

;; This file is not part of GNU Emacs.

;; This file is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation, either version 3 of the License,
;; or (at your option) any later version.

;; This file is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides a major mode for editing liblouis braille
;; translation tables.


;;; Code:

(require 'compile)

(defvar liblouis-mode-hook nil
  "Normal hook run when entering liblouis mode.")

(defvar liblouis-mode-abbrev-table nil
  "Abbrev table in use in liblouis mode buffers.")
(define-abbrev-table 'liblouis-mode-abbrev-table ())

(defconst liblouis-compilation-error-regexp
  ;; lou_checkyaml:./braille-specs/de-g2-sbs.yaml:372: Failure
  '("lou_checkyaml:\\(\\./[-a-z0-9/.]+\\):\\([0-9]+\\):" 1 2)
  "Specifications used for matching errors in the test suite log file.
See `compilation-error-regexp-alist' for semantics.")

(defvar liblouis-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?# "<" table)
    (modify-syntax-entry ?\n ">" table)
    (modify-syntax-entry ?\" "." table)
    table)
  "Syntax table for `liblouis-mode'.")

(defconst liblouis-font-lock-keywords
  (list
   (cons
    (regexp-opt
     '("include" "undefined" "display" "multind"
       "space" "punctuation" "digit" "grouping" "letter" "base"
       "lowercase" "uppercase" "litdigit" "sign" "math"
       "modeletter" "capsletter" "begmodeword" "begcapsword" "endcapsword"
       "capsmodechars" "begcaps" "endcaps" "begcapsphrase" "endcapsphrase"
       "lencapsphrase" "letsign" "noletsign" "noletsignbefore" "noletsignafter"
       "nocontractsign" "numsign" "numericnocontchars" "numericmodechars"
       "midendnumericmodechars" "begmodephrase" "endmodephrase" "lenmodephrase"
       "seqdelimiter" "seqbeforechars" "seqafterchars" "seqafterpattern"
       "seqafterexpression" "class" "emphclass" "begemph" "endemph" "noemphchars"
       "emphletter" "begemphword" "endemphword" "emphmodechars" "begemphphrase"
       "endemphphrase" "lenemphphrase" "decpoint" "hyphen" "capsnocont" "compbrl" "comp6"
       "nocont" "replace" "always" "repeated" "repword" "rependword" "largesign" "word"
       "syllable" "joinword" "lowword" "contraction" "sufword" "prfword" "begword"
       "begmidword" "midword" "midendword" "endword" "partword" "exactdots" "prepunc"
       "postpunc" "begnum" "midnum" "endnum" "joinnum" "begcomp" "endcomp" "attribute"
       "swapcd" "swapdd" "swapcc" "context" "pass2" "pass3" "pass4" "correct" "match" "literal") 'words)
    font-lock-builtin-face)
   (cons (regexp-opt '("before" "after" "noback" "nofor" "nocross") 'words) font-lock-type-face))
  "Default expressions to highlight in `liblouis-mode'.")

;;###autoload
(define-derived-mode liblouis-mode prog-mode "liblouis"
  "Major mode for editing liblouis translation tables.
Turning on liblouis mode runs the normal hook `liblouis-mode-hook'."
  (set-syntax-table liblouis-mode-syntax-table)
  (setq-local compile-command (concat "lou_checktable " buffer-file-name))
  (setq-local require-final-newline t)

  (add-to-list 'compilation-error-regexp-alist 'liblouis)
  (add-to-list 'compilation-error-regexp-alist-alist
	       (cons 'liblouis liblouis-compilation-error-regexp))

  (setq-local comment-start "# ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "#[ \t]*")

  (setq font-lock-defaults '(liblouis-font-lock-keywords
			     nil				; KEYWORDS-ONLY: no
			     nil				; CASE-FOLD: no
			     ((?_ . "w"))			; SYNTAX-ALIST
			     ))

  (setq-local comment-start "#")

  (run-hooks 'liblouis-mode-hook))

;;;###autoload
(add-to-list 'magic-mode-alist '("^#[[:blank:]]+liblouis: " . liblouis-mode))

(provide 'liblouis)
;;; liblouis.el ends here
