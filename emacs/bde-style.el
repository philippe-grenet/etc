;;; bde-style.el --- Provide BDE-style C++ indentation

;;; Authors: Philippe Grenet (pgrenet)

;;; Usage ---------------------------------------------------------------------
;;; First create a symbolic link from ~/.emacs.d/lisp/bde-style.el to this
;;; file.  Alternatively you can add the location of this file in your .emacs
;;; with: (add-to-list 'load-path "/path/to/this/file/")
;;;
;;; Then add this in your .emacs:
;;;     (require 'bde-style)
;;;
;;;     ;; Match parentheses:
;;;     (global-set-key [(control %)] 'bde-goto-match-paren)
;;;
;;;     ;; Mini-mode for creating a class header:
;;;     (global-set-key [(control c)(=)] 'bde-insert-define-class-header)
;;;     (global-set-key [(control c)(-)] 'bde-insert-declare-class-header)

;;; TODO ----------------------------------------------------------------------
;;; - Enums are not correct
;;; - Add a function to align function arguments (with * and &)
;;; - Add a function to generate a snippet based on the word under the cursor.
;;;   For example "info" + F1 ==> BAEL_LOG_INFO << {cursor} << BAEL_LOG_END;

;;; History -------------------------------------------------------------------
;;;   + 2014-02-12: first version
;;;   + 2014-02-18: added class header and match parentheses

(require 'cl)

;;; Indentation ---------------------------------------------------------------

(defun bde-in-member-documentation ()
  "Check if we are looking at a line that is the end of a chain
of comments following a line that ends in a semi-colon,
immediately inside a class or namespace scope."
  (case (caar c-syntactic-context)
    ((inclass innamespace)
     (save-excursion
       (loop
        (beginning-of-line)
        (cond ((= (point) (point-min))
               (return nil))
              ((re-search-forward "^ *//" (point-at-eol) t)
               (next-line -1))
              ((re-search-forward "; *$" (point-at-eol) t)
               (return t))
              (t
               (return nil))))))
    (t nil)))

(defun bde-comment-offset (element)
  "Return a symbol for the correct indentation level at the
current cursor position."
  (if (bde-in-member-documentation)
      '+
    nil))

;;; The offset specifications in c-offset-alist can be any of the following:
;;; - An integer -> specifies a relative offset. All relative offsets will be
;;;   added together and used to calculate the indentation relative to an
;;;   anchor position earlier in the buffer.
;;; - One of the symbols +, -, ++, --, *, or /
;;;   +   c-basic-offset times 1
;;;   -   c-basic-offset times −1
;;;   ++  c-basic-offset times 2
;;;   --  c-basic-offset times −2
;;;   *   c-basic-offset times 0.5
;;;   /   c-basic-offset times −0.5

(c-add-style
 "bde"
 '((c-basic-offset . 4)
   (c-comment-only-line-offset . 0)
   (c-offsets-alist
    (comment-intro         . bde-comment-offset)
    (defun-open            . 0)
    (defun-close           . 0)
    (statement-block-intro . +)
    (substatement-open     . 0)
    (substatement-label    . 0)
    (label                 . 0)
    (access-label          . /)
    (statement-cont        . +)
    (inline-open           . 0)
    (inline-close          . 0)
    (innamespace           . 0)
    (member-init-intro     . 0)
    (extern-lang-open      . 0)
    (brace-list-entry      . /)
    (extern-lang-close     . 0))))

(setq c-default-style
      '((java-mode . "java")
        (awk-mode  . "awk")
        (c++-mode  . "bde")
        (other     . "gnu")))

;;; Enable auto indent
(setq-default c-tab-always-indent t)

;;; Use M-i to go to the next 4-character tab position
(setq tab-stop-list
      '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80))

;;; These two make backspace eat all whitespaces. Why would you want that???
;;(add-hook 'c-mode-common-hook '(lambda () (c-toggle-auto-state 0)))
;;(add-hook 'c-mode-common-hook '(lambda () (c-toggle-auto-hungry-state 1)))

;; Make Emacs use "newline-and-indent" when you hit the Enter key so
;; that you don't need to keep using TAB to align yourself when coding.
(global-set-key "\C-m" 'newline-and-indent)

;; Allow tab in Makefile
(add-hook 'makefile-mode-hook (lambda () (setq indent-tabs-mode t)))


;;; Match parentheses ---------------------------------------------------------

(defun bde-goto-match-paren (arg)
  "Go to the matching parenthesis if on parenthesis. Else go to
the opening parenthesis one level up."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1))
        (t
         (backward-char 1)
         (cond ((looking-at "\\s\)")
                (forward-char 1) (backward-list 1))
               (t
                (while (not (looking-at "\\s("))
                  (backward-char 1)
                  (cond ((looking-at "\\s\)")
                         (message "->> )")
                         (forward-char 1)
                         (backward-list 1)
                         (backward-char 1)))
                  ))))))
;; Suggested binding:
;;(global-set-key [(control %)] 'bde-goto-match-paren)

;;; Insert class header -------------------------------------------------------

;;; Note: left-char and right-char pnly exist in emacs 24, so we use
;;; backward-char and forward-char instead.
(defun bde-insert-class-header (header-char)
  (let ((erase-hint t))
    (flet ((delete-header-char (n)
             (save-excursion
               (previous-line 1)
               (end-of-line)
               (backward-delete-char n)
               (next-line 2)
               (end-of-line)
               (backward-delete-char n)))
           (center-header ()
             (save-excursion
               (previous-line 1)
               (center-line 3))))
      ;; Get started
      (dotimes (i 3)
        (insert "// ")
        (newline))
      (previous-line 2)
      (end-of-line)
      (center-header)
      (insert " <class name>")
      (backward-char 12)
      ;; Read and process input
      (loop
       (let ((c (read-event "Inserting header")))
         (cond ((integerp c)
                (when erase-hint (kill-line))
                (insert-char c 1)
                (save-excursion
                  (previous-line 1)
                  (when erase-hint
                    (end-of-line)
                    (insert " "))
                  (insert-char header-char 1)
                  (next-line 2)
                  (when erase-hint
                    (end-of-line)
                    (insert " "))
                  (insert-char header-char 1))
                (unless (= c 32)
                  (center-header)))
               ((eq c 'backspace)
                (backward-delete-char 1)
                (delete-header-char 1))
               ((eq c 'kp-delete)
                (delete-char 1)
                (delete-header-char 1))
               ((eq c 'left)
                (backward-char 1))
               ((eq c 'right)
                (forward-char 1))
               (t
                (return nil)))
         (setq erase-hint nil))))))


(defun bde-insert-define-class-header ()
  "Mini-mode for creating a BDE-style class definition
header (e.g. ===). Exit the mode with enter, or anything that is
not a character, backspace, delete, left or right."
  (interactive)
  (bde-insert-class-header ?=))

(defun bde-insert-declare-class-header ()
  "Mini-mode for creating a BDE-style class implementation header (e.g. ---).
Exit the mode with enter, or anything that is not a character,
backspace, delete, left or right."
  (interactive)
  (bde-insert-class-header ?-))

;;; Suggested bindings:
;;(global-set-key [(control c)(=)] 'bde-insert-define-class-header)
;;(global-set-key [(control c)(-)] 'bde-insert-declare-class-header)

;;; End of file
(provide 'bde-style)
