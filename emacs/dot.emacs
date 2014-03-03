;;; Philippe's .emacs

;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;;                                 Macros
;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(defmacro gnu-emacs-only (&rest x)
  (list 'if (string-match "GNU Emacs" (version)) (cons 'progn x)))

(defmacro xemacs-only (&rest x)
  (list 'if (string-match "XEmacs" (version)) (cons 'progn x)))

(defmacro x-windows-only (&rest x)
  (list 'if (eq window-system 'x) (cons 'progn x)))

(defmacro mac-osx-only (&rest x)
  (list 'if (eq window-system 'ns) (cons 'progn x)))

(defmacro mac-osx-or-x-windows-only (&rest x)
  (list 'if (or (eq window-system 'ns) (eq window-system 'x)) (cons 'progn x)))

(defmacro non-x-windows-only (&rest x)
  (list 'if (not (eq window-system 'x)) (cons 'progn x)))


;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;;                                  Extensions
;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;; Path for "require"
(add-to-list 'load-path "~/.emacs.d/lisp/")

;; Markdown mode
(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;; 80-column ruler
(require 'fill-column-indicator)
(setq fci-rule-use-dashes t)
(setq fci-dash-pattern 0.5)
(setq fci-rule-width 1)
(setq fci-rule-color "dim gray")
(define-key global-map [(control |)] 'fci-mode)

;;; IDO mode for everything (files and buffers)
(require 'ido)
(ido-mode 'both)

;; Display ido results vertically, rather than horizontally
;; (setq ido-decorations
;;       '("\n-> " "" "\n   " "\n   ..." "[" "]" " [No match]" " [Matched]"
;;         " [Not readable]" " [Too big]" " [Confirm]"))
;; (defun ido-disable-line-truncation ()
;;   (set (make-local-variable 'truncate-lines) nil))
;; (add-hook 'ido-minibuffer-setup-hook 'ido-disable-line-truncation)
;; (defun ido-define-keys () ;; C-n/p is more intuitive in vertical layout
;;   (define-key ido-completion-map (kbd "C-n") 'ido-next-match)
;;   (define-key ido-completion-map (kbd "C-p") 'ido-prev-match))
;; (add-hook 'ido-setup-hook 'ido-define-keys)

;;; Make arrow keys work in buffer selection with iswitch (Ctrl-X b)
(require 'edmacro)
(defun iswitchb-local-keys ()
  (mapc (lambda (K)
	      (let* ((key (car K)) (fun (cdr K)))
            (define-key iswitchb-mode-map (edmacro-parse-keys key) fun)))
	    '(("<right>" . iswitchb-next-match)
	      ("<left>"  . iswitchb-prev-match)
	      ("<up>"    . ignore             )
	      ("<down>"  . ignore             ))))
(add-hook 'iswitchb-define-mode-map-hook 'iswitchb-local-keys)


;; C-x, C-c, C-v to cut, copy and paste when mark is active.
;; Add shift or double the Ctrl-* to switch back to Emacs keys.
;; C-Ret for rectangular regions.
(cua-mode t)

;; YASnippet
;; (add-to-list 'load-path "~/.emacs.d/yasnippet")
;; (require 'yasnippet)
;; (yas-global-mode 1)

;; Autopairs
(when (fboundp 'electric-pair-mode)
  (electric-pair-mode))


;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;;                              General UI settings
;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;;; Remove the toolbar
(and (fboundp 'tool-bar-mode) (tool-bar-mode -1))

;;; Remove the menu bar
;;;(menu-bar-mode -1)

;;; Remove welcome message
(setq inhibit-startup-message t)

;;; Disable blinking cursor
(and (fboundp 'blink-cursor-mode) (blink-cursor-mode -1))

;; Use "y or n" answers instead of full words "yes or no"
(fset 'yes-or-no-p 'y-or-n-p)

;;; Display column number and line numbers
(column-number-mode 1)
(if (boundp 'global-linum-mode)
    (global-linum-mode t))

;;; Highlight cursor line and scroll only one line instead of repositioning
;;; the cursor in the middle of the screen
(global-hl-line-mode 1)
(setq scroll-step 1)

;;; Scrollbar on the right
;;;(setq scroll-bar-mode-explicit t)
;;;(set-scroll-bar-mode `right)

;;; Indent with spaces, not tabs
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

;;; Autofill at 79 characters
(setq-default fill-column 79)
;;;(global-visual-line-mode 1)            ; Wordwrap at word boundaries

;;; Syntax highlighing
(global-font-lock-mode 1)
;;;(setq font-lock-maximum-decoration t)  ; Maximum colors

;;; Better frame title with buffer name
(setq frame-title-format (concat "%b - emacs@" system-name))

;;; Disable beep
(setq visual-bell t)

;;; Colorize selection
(transient-mark-mode 'on)

;;; Show matching parentheses
(show-paren-mode t)

;;; Delete selection when typing
(delete-selection-mode t)

;;; Mouse selection
(setq x-select-enable-clipboard t)
;(if window-system
;    (setq interprogram-paste-function 'x-cut-buffer-or-selection-value))

(setq large-file-warning-threshold nil)

;;; Show trailing whitespaces
;;; Remove trailing blanks on save
(setq show-trailing-whitespace t)
(setq delete-trailing-lines nil) ;; for command delete-trailing-whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)


;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;;                                   Keys
;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(global-set-key [(meta g)] 'goto-line)
;;(global-set-key [(meta k)] 'kill-buffer)
;;(global-set-key [(control tab)] `other-window) ;; use Ctrl-X o
(define-key global-map [(control z)] 'advertised-undo)
(define-key global-map [(meta backspace)] 'backward-kill-word)
(global-set-key [f10] 'speedbar)
(global-set-key [(control escape)] 'delete-other-windows)

;;; XEmacs compatibility for Emacs
(gnu-emacs-only
 (defun switch-to-other-buffer ()
   "Alternates between the two most recent buffers"
   (interactive)
   (switch-to-buffer (other-buffer)))
 (define-key global-map [(meta control l)] 'switch-to-other-buffer))

;;; Navigate in minibuffer with C-x b
(require 'iswitchb)
(iswitchb-mode 1)

;;Use meta+arrow to move the focus between visible buffers
(require 'windmove)
(windmove-default-keybindings 'meta) ;; will be overridden
(global-set-key (kbd "<M-s-left>")  'windmove-left)
(global-set-key (kbd "<M-s-right>") 'windmove-right)
(global-set-key (kbd "<M-s-up>")    'windmove-up)
(global-set-key (kbd "<M-s-down>")  'windmove-down)


;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;;                                Functions
;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;;; Function to prevent creating backup files
(gnu-emacs-only
 (defun no-backup-files ()
   "Disable creation of backup files"
   (interactive)
   (setq make-backup-files nil))

 (no-backup-files))


;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;;                                Font size
;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(gnu-emacs-only
 (mac-osx-only
  (set-face-attribute 'default nil
                      :family "Courier" :height 120 :weight 'normal)))

;;; Default frame alist options:
;;; (width . 168) (height . 77)
;;; (horizontal-scroll-bars . nil)  doesn't seem to work
;;; (internal-border-width . 0)
;;; (menu-bar-lines . 0)  to remove menu bar
;;; (tool-bar-lines . 0)  to remove icon bar
;;; (line-spacing . 0)
;; (gnu-emacs-only
;;  (mac-osx-or-x-windows-only ;x-windows-only
;;   (setq default-frame-alist
;; 	(append
;;      '(;;(font . "Monospace 6")
;;        ;;(font . "lucidasanstypewriter-10")
;;        ;;(top . 200)
;;        ;;(left . 200)
;;        (width . 90)
;;        (height . 90)
;;        ;;(vertical-scroll-bars . right)
;;        ;;(internal-border-width . 0)
;;        ;;(border-width . 0)
;;        ;;(horizontal-scroll-bars . t)
;;        )
;;      default-frame-alist))))


;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;;                                Themes
;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(gnu-emacs-only
 (mac-osx-or-x-windows-only

  ;; Night theme
  ;; Credit is due to the Monokai theme and by Eclipse's default colors
  (defun my-colors-night (&optional frame)
    "sets the color theme for X-Windows"
    (interactive)
    (if frame
        (select-frame frame)
      (setq frame (selected-frame)))
    (set-background-color "#222222")
    (set-foreground-color "#e4e4ef")
    (set-mouse-color "#ffdd33")
    (set-cursor-color "Red")
    ;; Background
    (set-face-background 'default "#222222")
    (set-face-foreground 'default "LightGray")
    ;; Selection
    (set-face-background 'region "#484848")
    ;; Modeline
    (custom-set-faces
     '(mode-line ((t (:foreground "#e4e4ef" :overline t :underline t)))))
    ;; Trailing whitespace color
    (set-face-background 'trailing-whitespace "#f43841")
    (set-face-foreground 'trailing-whitespace "#000000")
    ;; Current line Highlighting
    (set-face-background 'highlight "#282828")
    (set-face-foreground 'highlight nil)
    ;; Match/Mismatch parenthesis
    (set-face-background 'show-paren-match-face "#52494e")
    (set-face-foreground 'show-paren-match-face "#f4f4ff")
    (set-face-background 'show-paren-mismatch-face "#c73c3f")
    (set-face-foreground 'show-paren-mismatch-face "#f4f4ff")
    ;; Other faces
    (set-face-foreground 'font-lock-keyword-face "violet")
    (set-face-bold-p 'font-lock-keyword-face t)
    (set-face-foreground 'font-lock-type-face "LightGray")
    (set-face-foreground 'font-lock-function-name-face "#a6e22e")
    (set-face-foreground 'font-lock-constant-face "#a6e22e")
    (set-face-foreground 'font-lock-variable-name-face "LightGray")
    (set-face-foreground 'font-lock-string-face "LightSkyBlue")
    ;;(set-face-foreground 'font-lock-comment-face "#75715e") ; dark aluminum
    (set-face-foreground 'font-lock-comment-face "Gray50"))

  ;; Day theme
  (defun my-colors-day (&optional frame)
    "sets the color theme for X-Windows"
    (interactive)
    (if frame
        (select-frame frame)
      (setq frame (selected-frame)))
    (set-background-color  "whitesmoke")
    (set-foreground-color  "black")
    (set-cursor-color     "black")
    (set-mouse-color      "black")
    (set-border-color      "whitesmoke")
    ;; Selection
    (set-face-background 'region "orange")
    ;; Current line Highlighting
    (set-face-background 'highlight "Gray90")
    (set-face-foreground 'highlight nil)
    ;; Match/Mismatch parenthesis
    (set-face-background 'show-paren-match-face "LightSteelBlue")
    (set-face-foreground 'show-paren-match-face "firebrick")
    (set-face-background 'show-paren-mismatch-face "DarkRed")
    (set-face-foreground 'show-paren-mismatch-face "whitesmoke")
    ;; Other faces
    (set-face-foreground 'font-lock-comment-face "DarkGreen")
    (set-face-foreground 'font-lock-string-face "#3F7F5F"))

  ;; Key bindings
  (define-key global-map [f4] 'my-colors-night)
  (define-key global-map [f3] 'my-colors-day)

  ;; Default
  (my-colors-night))

 (x-windows-only

  ;; Transparency
  ;;(set-frame-parameter (selected-frame) 'alpha '(<active> [<inactive>]))
  (defun my-colors-transparent (&optional frame)
    "Turns transparency on"
    (interactive)
    (if frame
	(select-frame frame)
      (setq frame (selected-frame)))
    (set-frame-parameter frame 'alpha '(85 50))
    (add-to-list 'default-frame-alist '(alpha 85 50)))

  ;; No transparency
  (defun my-colors-opaque (&optional frame)
    "Turns transparency off"
    (interactive)
    (if frame
	(select-frame frame)
      (setq frame (selected-frame)))
    (set-frame-parameter frame 'alpha '(100 100))
    (add-to-list 'default-frame-alist '(alpha 100 100)))

  ;; Key bindings
  (define-key global-map [f5] 'my-colors-transparent)
  (define-key global-map [f6] 'my-colors-opaque)))


;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;                              Position stack
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Maintain a stack of buffer positions, with the operations:
; Push the current position onto the stack.
; Pop the latest position off the stack and move point to it.
; This is useful when following a chain of function calls/definitions.
; Use C-c m / C-c p to push/pop position stack
(defvar postack-stack '() "The position stack")

(defun postack-goto (marker)
  "Should be marker-goto."
  (switch-to-buffer (marker-buffer pos))
  (goto-char (marker-position pos)))

(defun postack-push ()
  "Push the current position on the position stack."
  (interactive)
  (let ((pos (point-marker)))
    (setq postack-stack (cons pos postack-stack))
    (message (format "Marked: (%s:%s)"
                    (marker-buffer pos)
                    (marker-position pos))) ))

(defun postack-pop ()
  "Remove the top position from the position stack and make it current."
  (interactive)
  (let ((pos (car postack-stack)))
    (setq postack-stack (cdr postack-stack))
    (cond ((null pos)
           (message "Position stack empty"))
          ((markerp pos)
           (postack-goto pos)
           (message (format "Position: (%s:%s)"
                            (marker-buffer pos)
                            (marker-position pos))))
          (t
           (message "Invalid position in stack")) ) ))

(global-set-key "\C-cm" 'postack-push)
(global-set-key "\C-cp" 'postack-pop)


;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;                          C/C++ style and utilities
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(require 'bde-style)
(require 'bde-util);

;; Ctrl-Tab to switch between .h and .cpp
(global-set-key [(control tab)] `bde-switch-h-cpp)

;; Highlight dead code between "#if 0" and "#endif"
;;(setq *bde-highlight-dead-code-color* "darkred")
;;(add-hook 'c-mode-common-hook 'bde-highlight-dead-code)

;; Match parentheses
(define-key global-map [(control %)] 'bde-goto-match-paren)

;; Insert class header
(global-set-key [(control c)(=)] 'bde-insert-define-class-header)
(global-set-key [(control c)(-)] 'bde-insert-declare-class-header)

;; Make emacs follow camel case names in C++ files
(add-hook 'c-mode-common-hook (lambda () (subword-mode 1)))


;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; TODO work in progress
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;;; Pawel's python-based BDE-style formatter
(defun bde-format-around-point ()
  "Test Pawel's formatter"
  (interactive)
  (let ((line (- (line-number-at-pos) 1))
        (col  (current-column)))
    (compile
     (format "python /Users/phil/Code/bdeformat/pythonx/bdeformatfile.py %s %d %d"
             (shell-quote-argument (buffer-file-name))
             line col))))
