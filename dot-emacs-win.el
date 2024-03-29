;; initfile --- Summary:
;; Commentary:
;; Emacs 27.1 and newer tested
;; Date: Augunst 25, 2019
;; Author: Thomas Tang
;; Configuration/Customization:
;; Defines global variables that are later used to customize and set
;; up packages.

(defun executable-find (command)
  "Search for COMMAND in `exec-path' and return the absolute file name.
Return nil if COMMAND is not found anywhere in `exec-path'."
  ;; Use 1 rather than file-executable-p to better match the behavior of
  ;; call-process.
  (locate-file command exec-path exec-suffixes 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set packages to install
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq package-archives '(("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")
                         ("gnu" . "http://elpa.gnu.org/packages/")))

<<<<<<< HEAD
;; Disable package initialize after us.  We either initialize it
;; anyway in case of interpreted .emacs, or we don't want slow
;; initizlization in case of byte-compiled .emacs.elc.
=======
(unless (package-installed-p 'quelpa)
  (with-temp-buffer
    (url-insert-file-contents "https://raw.githubusercontent.com/quelpa/quelpa/master/quelpa.el")
    (eval-buffer)
    (quelpa-self-upgrade)))


>>>>>>> 481c38631e0f9e3db30ad272016a335a333cbabe
(setq package-enable-at-startup nil)
;; Ask package.el to not add (package-initialize) to .emacs.
(setq package--init-file-ensured t)
;; set use-package-verbose to t for interpreted .emacs,
;; and to nil for byte-compiled .emacs.elc
(eval-and-compile
  (setq use-package-verbose (not (bound-and-true-p byte-compile-current-file))))
;; Add the macro generated list of package.el loadpaths to load-path.
(mapc #'(lambda (add) (add-to-list 'load-path add))
      (eval-when-compile
        (require 'package)
        (package-initialize)
        ;; Install use-package if not installed yet.
        (unless (package-installed-p 'use-package)
          (package-refresh-contents)
          (package-install 'use-package))
        ;; (require 'use-package)
        (let ((package-user-dir-real (file-truename package-user-dir)))
          ;; The reverse is necessary, because outside we mapc
          ;; add-to-list element-by-element, which reverses.
          (nreverse (apply #'nconc
			   ;; Only keep package.el provided loadpaths.
			   (mapcar #'(lambda (path)
				       (if (string-prefix-p package-user-dir-real path)
					   (list path)
					 nil))
				   load-path))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; By default Emacs triggers garbage collection at ~0.8MB which makes
;; startup really slow. Since most systems have at least 64MB of memory,
;; we increase it during initialization.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq gc-cons-threshold 64000000)
(add-hook 'after-init-hook #'(lambda ()
	;; restore after startup
  (setq gc-cons-threshold 800000)))

;; Extra plugins and config files are stored here
(add-to-list 'load-path (expand-file-name "~/.emacs.d/plugins"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start emacs server if not already running
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(if (and (fboundp 'server-running-p)
         (not (server-running-p)))
    (server-start))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General Tweaks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(show-paren-mode t)

(delete-selection-mode t)

(setq js-indent-level 2)
(setq-default js2-basic-offset 2)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq indent-line-function 'insert-tab)

(setq column-number-mode t)

;; (setq cua-mode t)
;; (setq cua-enable-cua-keys nil)

(setq make-backup-files nil)

(setq-default case-fold-search t ;case insensitive searches by default
              search-highlight t) ;hilit matches when searching

(global-hl-line-mode t)

;; (if (functionp 'tool-bar-mode) (tool-bar-mode -1))

;; Remove trailing white space upon saving
(add-hook 'before-save-hook
          (lambda ()
            (when (not (derived-mode-p 'ein:notebook-multilang-mode))
              (delete-trailing-whitespace))))

;; Auto-wrap at 92 characters
(setq-default auto-fill-function 'do-auto-fill)
(setq-default fill-column 92)

(turn-on-auto-fill)

(add-hook 'prog-mode-hook (lambda () (auto-fill-mode -1)))

;; Global Keyboard Shortcuts
(global-set-key (kbd "C-?") 'help-command)
(global-set-key (kbd "M-?") 'mark-paragraph)
(global-set-key (kbd "C-h") 'delete-backward-char)
(global-set-key (kbd "M-h") 'backward-kill-word)
(global-set-key (kbd "M-TAB") 'dabbrev-expand)
(global-set-key (kbd "C-/") 'undo)
(global-set-key (kbd "C-c ;") 'comment-or-uncomment-region)
(global-set-key (kbd "C-m") 'newline-and-indent)
(global-set-key (kbd "C-c C-c") 'compile)
(global-set-key (kbd "C-/") 'undo)
(global-set-key (kbd "C-x M-f") 'project-find-file)
(global-set-key (kbd "M-x") 'smex)

(defalias 'yes-or-no-p 'y-or-n-p)

(setq auto-save-default nil)

(when (and (not (eq system-type 'darwin)) (fboundp 'menu-bar-mode))
  (menu-bar-mode -1))

(setq ring-bell-function 'ignore)
(setq x-stretch-cursor t)

(setq vc-follow-symlinks t)

;; Check (on save) whether the file edited contains a shebang, if yes,
;; make it executable from
;; http://mbork.pl/2015-01-10_A_few_random_Emacs_tips
(add-hook 'after-save-hook #'executable-make-buffer-file-executable-if-script-p)

;; Highlight some keywords in prog-mode
(add-hook 'prog-mode-hook
<<<<<<< HEAD
          (lambda ()
            ;; Highlighting in cmake-mode this way interferes with
            ;; cmake-font-lock, which is something I don't yet understand.
            (when (not (derived-mode-p 'cmake-mode))
              (font-lock-add-keywords
               nil
               '(("\\<\\(FIXME\\|TODO\\|BUG\\|DONE\\)"
                  1 font-lock-warning-face t))))
            )
          )
=======
	  (lambda ()
	    ;; Highlighting in cmake-mode this way interferes with
	    ;; cmake-font-lock, which is something I don't yet understand.
	    (when (not (derived-mode-p 'cmake-mode))
	      (font-lock-add-keywords
	       nil
	       '(("\\<\\(FIXME\\|TODO\\|BUG\\|DONE\\)"
		  1 font-lock-warning-face t))))
	    )
	  )
>>>>>>> 481c38631e0f9e3db30ad272016a335a333cbabe

;; Setup use-package
(eval-when-compile
  (require 'use-package))

(use-package bind-key
  :ensure t)

(use-package use-package
  :commands use-package-autoload-keymap)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable terminal emacs to copy and paste from system clipboard
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun my-copy-to-xclipboard(arg)
  (interactive "P")
  (cond
   ((not (use-region-p))
    (message "Nothing to yank to X-clipboard"))
   ((and (not (display-graphic-p))
         (/= 0 (shell-command-on-region
                (region-beginning) (region-end) "xsel -i -b")))
    (message "Error: Is program `xsel' installed?"))
   (t
    (when (display-graphic-p)
      (call-interactively 'clipboard-kill-ring-save))
    (message "Yanked region to X-clipboard")
    (when arg
      (kill-region  (region-beginning) (region-end)))
    (deactivate-mark))))

(defun my-cut-to-xclipboard()
  (interactive)
  (my-copy-to-xclipboard t))

(defun my-paste-from-xclipboard()
  (interactive)
  (if (display-graphic-p)
      (clipboard-yank)
    (insert (shell-command-to-string "xsel -o -b"))))

(global-set-key (kbd "C-c C-w") 'my-cut-to-xclipboard)
(global-set-key (kbd "C-c M-w") 'my-copy-to-xclipboard)
(global-set-key (kbd "C-c C-y") 'my-paste-from-xclipboard)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; text scale - apply text scale to all buffers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defadvice text-scale-increase (around all-buffers (arg) activate)
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      ad-do-it)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; async - library for async/thread processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package async
  :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; s is used by ycmd, origami, etc and sometimes during Emacs
;; upgrades disappears so we try to install it on its own.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (use-package s
;;   :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Automatically compile and save ~/.emacs.el
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun byte-compile-init-files (file)
  "Automatically compile FILE."
  (interactive)
  (save-restriction
    ;; Suppress the warning when you setq an undefined variable.
    (if (>= emacs-major-version 23)
        (setq byte-compile-warnings '(not free-vars obsolete))
      (setq byte-compile-warnings
            '(unresolved
              callargs
              redefine
              obsolete
              noruntime
              cl-warnings
              interactive-only)))
    (byte-compile-file (expand-file-name file)))
  )

(add-hook
 'after-save-hook
 (function
  (lambda ()
    (if (string= (file-truename "~/.emacs.el")
                 (file-truename (buffer-file-name)))
        (byte-compile-init-files (file-truename "~/.emacs.el")))
    )
  )
 )

;; Byte-compile again to ~/.emacs.elc if it is outdated
(if (file-newer-than-file-p
     (file-truename "~/.emacs.el")
     (file-truename "~/.emacs.elc"))
    (byte-compile-init-files "~/.emacs.el"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auto-package-update
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Auto update packages once a week
(use-package auto-package-update
  :ensure t
  :commands (auto-package-update-maybe)
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe)
  (add-hook 'auto-package-update-before-hook
<<<<<<< HEAD
          (lambda () (message "I will update packages now")))
=======
	    (lambda () (message "I will update packages now")))
>>>>>>> 481c38631e0f9e3db30ad272016a335a333cbabe
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; hide dot files in dired mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package dired-hide-dotfiles
  :ensure t)

(defun my-dired-mode-hook ()
  "My `dired' mode hook."
  ;; To hide dot-files by default
  (dired-hide-dotfiles-mode)

  ;; To toggle hiding
  (define-key dired-mode-map "." #'dired-hide-dotfiles-mode))

(add-hook 'dired-mode-hook #'my-dired-mode-hook)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; evil-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package evil :ensure t)
(evil-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Find file packages
;; https://www.howtoforge.com/linux-locate-command/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package ag
  :ensure t)

(use-package fzf
  :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Buffer Search
;; Ivy / Swiper / Counsel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package ivy
  :ensure t
  :commands (ivy-mode)
  :config
  (require 'ivy)
  (ivy-mode t)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-wrap t)
  (global-set-key (kbd "C-c C-r") 'ivy-resume)
  ;; Show #/total when scrolling buffers
  (setq ivy-count-format "%d/%d ")
  )

(use-package swiper
  :ensure t
  :bind (("C-s" . swiper)
         ("C-r" . swiper))
  )

(use-package counsel
  :ensure t
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("<f1> f" . counsel-describe-function)
         ("<f1> v" . counsel-describe-variable)
         ("<f1> l" . counsel-find-library)
         ("<f2> i" . counsel-info-lookup-symbol)
         ("<f2> u" . counsel-unicode-char)
         ("C-c g" . counsel-git-grep)
         ("C-c j" . counsel-git)
         ("C-c k" . counsel-ag)
         ("C-c r" . counsel-rg)
         ("C-x l" . fzf)
         :map minibuffer-local-map
         ("C-r" . counsel-minibuffer-add)
         )
  :config
  (if (executable-find "rg")
      ;; use ripgrep instead of grep because it's way faster
      (setq counsel-grep-base-command
            "rg -i -M 120 --no-heading --line-number --color never '%s' %s"
            counsel-rg-base-command
            "rg -i -M 120 --no-heading --line-number --color never %s ."
            )
    (warn "\nWARNING: Could not find the ripgrep executable. It "
          "is recommended you install ripgrep.")
    )
  )

;; Use universal ctags to build the tags database for the project.
;; When you first want to build a TAGS database run 'touch TAGS'
;; in the root directory of your project.
(use-package counsel-etags
  :ensure t
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function counsel-etags-virtual-update-tags "counsel-etags.el")
    (declare-function counsel-etags-guess-program "counsel-etags.el")
    (declare-function counsel-etags-locate-tags-file "counsel-etags.el"))
  :bind (
         ("M-t" . counsel-etags-find-tag-at-point)
         ("M-a" . counsel-etags-grep-symbol-at-point)
         ("M-f" . counsel-etags-find-tag))
  :config
  ;; Ignore files above 800kb
  (setq counsel-etags-max-file-size 800)
  ;; Ignore build directories for tagging
  (add-to-list 'counsel-etags-ignore-directories '"build*")
  (add-to-list 'counsel-etags-ignore-directories '"Build*")
  (add-to-list 'counsel-etags-ignore-directories '"CMakefile*")
  (add-to-list 'counsel-etags-ignore-directories '".vscode")
  (add-to-list 'counsel-etags-ignore-filenames '".clang-format")
  ;; Don't ask before rereading the TAGS files if they have changed
  (setq tags-revert-without-query t)
  ;; Don't warn when TAGS files are large
  (setq large-file-warning-threshold nil)
  ;; How many seconds to wait before rerunning tags for auto-update
  (setq counsel-etags-update-interval 180)
  ;; Set up auto-update
  (add-hook
   'prog-mode-hook
   (lambda () (add-hook 'after-save-hook
<<<<<<< HEAD
                        (lambda ()
                          (counsel-etags-virtual-update-tags))))
=======
			(lambda ()
			  (counsel-etags-virtual-update-tags))))
>>>>>>> 481c38631e0f9e3db30ad272016a335a333cbabe
   )

  ;; The function provided by counsel-etags is broken (at least on Linux)
  ;; and doesn't correctly exclude directories, leading to an excessive
  ;; amount of incorrect tags. The issue seems to be that the trailing '/'
  ;; in e.g. '*dirname/*' causes 'find' to not correctly exclude all files
  ;; in that directory, only files in sub-directories of the dir set to be
  ;; ignore.
  (defun my-scan-dir (src-dir &optional force)
    "Create tags file from SRC-DIR. \
     If FORCE is t, the commmand is executed without \
     checking the timer."
    (let* ((find-pg (or
                     counsel-etags-find-program
                     (counsel-etags-guess-program "find")))
           (ctags-pg (or
                      counsel-etags-tags-program
                      (format "%s -e -L" (counsel-etags-guess-program
                                          "ctags"))))
           (default-directory src-dir)
           ;; run find&ctags to create TAGS
           (cmd (format
                 "%s . \\( %s \\) -prune -o -type f -not -size +%sk %s | %s -"
                 find-pg
                 (mapconcat
                  (lambda (p)
                    (format "-iwholename \"*%s*\"" p))
                  counsel-etags-ignore-directories " -or ")
                 counsel-etags-max-file-size
                 (mapconcat (lambda (n)
                              (format "-not -name \"%s\"" n))
                            counsel-etags-ignore-filenames " ")
                 ctags-pg))
           (tags-file (concat (file-name-as-directory src-dir) "TAGS"))
           (doit (or force (not (file-exists-p tags-file)))))
      ;; always update cli options
      (when doit
        (message "%s at %s" cmd default-directory)
        (shell-command cmd)
        (visit-tags-table tags-file t)
        )
      )
    )

  (setq counsel-etags-update-tags-backend
        (lambda ()
          (interactive)
          (let* ((tags-file (counsel-etags-locate-tags-file)))
            (when tags-file
              (my-scan-dir (file-name-directory tags-file) t)
              (run-hook-with-args
               'counsel-etags-after-update-tags-hook tags-file)
              (unless counsel-etags-quiet-when-updating-tags
                (message "%s is updated!" tags-file))))
          )
        )
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Counsel Projectile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package projectile
  :ensure t
  :config
  (projectile-global-mode)
  (setq projectile-completion-system 'ivy))

(use-package counsel-projectile
  :ensure t
  :config
  (global-set-key (kbd "C-c pf") 'counsel-projectile-find-file)
  (global-set-key (kbd "C-c ps") 'counsel-projectile-switch-project)
  (global-set-key (kbd "C-c pa") 'counsel-projectile-ag)
  (global-set-key (kbd "C-c pr") 'counsel-projectile-rg)
  (global-set-key (kbd "C-c pd") 'counsel-projectile-find-dir)
  (global-set-key (kbd "C-c pb") 'counsel-projectile-switch-to-buffer)
  (global-set-key (kbd "C-c pg") 'counsel-projectile-grep)
  (global-set-key (kbd "C-c pm") 'counsel-projectile-mode)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; avy: always fast jump to char inside the current view buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package avy
  :ensure t
  :bind (("M-c" . avy-goto-char)
         ("M-s" . avy-goto-word-1))
  ;; Set keys for Dvorak mode instead of qwerty
  :init (setq avy-keys '(?a ?o ?e ?u ?i ?d ?h ?t ?n ?s
                            ?A ?O ?E ?U ?I ?D ?H ?T ?N ?S
                            ?p ?y ?f ?g ?c ?r ?l
                            ?P ?Y ?F ?G ?C ?R ?L)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; string-inflection
;; ;; used for switching between different cases, eg CamelCase,
;; ;; lowerCamelCase, snake_case, and SCREAMING_SNAKE_CASE
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (use-package string-inflection
;;   :ensure t
;;   :defer t
;;   :bind (("C-c c i" . string-inflection-cycle)
;;          ("C-c c l" . string-inflection-lower-camelcase)
;;          ("C-c c c" . string-inflection-camelcase)
;;          ("C-c c s" . string-inflection-underscore)
;;          ("C-c c u" . string-inflection-upcase)
;;          )
;;   )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; multiple-cursors  - https://github.com/magnars/multiple-cursors.el
;; Allows you to have multiple cursors on different lines so you can
;; easily edit multiple lines at once.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package multiple-cursors
  :ensure t
  :bind (("M-n" . mc/mark-next-like-this)
         ("M-p" . mc/mark-previous-like-this)
         ("C-c a" . mc/mark-all-like-this)
         ("C-c e" . mc/edit-lines))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dumb Jump to definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package dumb-jump
  :ensure t
  :bind (("M-g o" . dumb-jump-go-other-window)
	 ("M-g j" . dumb-jump-go)
	 ("M-g b" . dumb-jump-back)
	 ("M-g i" . dumb-jump-go-prompt)
	 ("M-g x" . dumb-jump-go-prefer-external)
	 ("M-g z" . dumb-jump-go-prefer-external-other-window))
  :config (setq dumb-jump-selector 'ivy) ;; (setq dumb-jump-selector 'helm)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Window numbering
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package window-numbering installed from package list
;; Allows switching between buffers using meta-(# key)
;; (use-package window-numbering
;;   :ensure t
;;   :config
;;   (eval-when-compile
;;     ;; Silence missing function warnings
;;     (declare-function window-numbering-mode "window-numbering.el"))
;;   (window-numbering-mode t)
;;   )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; wgrep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; wgrep allows you to edit all files in a grep result. For example,
;; you can use C-c g or C-c r to search all files in a project, then
;; use C-c C-o to enter ivy-occur mode, followed by 'w' to make
;; the grep results buffer editable, then you can edit the results
;; however you wish.
(use-package wgrep
  :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Edit server to allow editing of things in Chrome with Emacs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (use-package edit-server
;;   :ensure t
;;   :config
;;   (progn
;;     (eval-when-compile
;;       ;; Silence missing function warnings
;;       (declare-function edit-server-start "edit-server-start.el"))
;;     (when (daemonp)
;;       (edit-server-start)
;;       )
;;     (add-hook 'edit-server-start-hook
;;               (lambda ()
;;                 (when (string-match "github.com" (buffer-name))
;;                   (markdown-mode))))
;;     )
;;   )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rainbow Delimiters -  have delimiters be colored by their depth
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (use-package rainbow-delimiters
;;   :ensure t
;;   :init
;;   (eval-when-compile
;;     ;; Silence missing function warnings
;;     (declare-function rainbow-delimiters-mode "rainbow-delimiters.el"))
;;   (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Beacon-mode: flash the cursor when switching buffers or scrolling
;;              the goal is to make it easy to find the cursor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (use-package beacon
;;   :ensure t
;;   :init
;;   (eval-when-compile
;;     ;; Silence missing function warnings
;;     (declare-function beacon-mode "beacon.el"))
;;   :config
;;   (beacon-mode t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; which-key: when you pause on a keyboard shortcut it provides
;;            suggestions in a popup buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package which-key
  :ensure t
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function which-key-mode "which-key.el"))
  :config
  (which-key-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; zzz-to-char: replaces the built-in zap-to-char with avy-like
;;              replacement options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (use-package zzz-to-char
;;   :ensure t
;;   :bind ("M-z" . zzz-up-to-char))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RealGud - https://github.com/realgud/realgud
;; A rewrite of GUD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package realgud
  :ensure t
  :init
  (setenv "TERM" "dumb")
  :config
  (setq realgud:pdb-command-name "python -m pdb"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use markdown-mode for markdown files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package markdown-mode
  :ensure t
  :mode (".md" ".markdown"))
<<<<<<< HEAD
=======
:init (setq markdown-command "/usr/bin/markdown")
>>>>>>> 481c38631e0f9e3db30ad272016a335a333cbabe

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org-Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq org-log-done 'time
      org-todo-keywords '((sequence "TODO" "INPROGRESS" "DONE"))
      org-todo-keyword-faces '(("INPROGRESS" . (:foreground "blue" :weight bold))))
(use-package writegood-mode
  :ensure t
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function writegood-mode "writegood-mode.el"))
  (add-hook 'org-mode-hook #'writegood-mode)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; vlf - handle open very large files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package vlf
  :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; markdown-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode))
  :init (setq markdown-command "/usr/bin/markdown"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load hungry Delete, caus we're lazy
;; conflict with find-file in emacs 28.2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set hungry delete:
;; (use-package hungry-delete
;;   :ensure t
;;   :init
;;   (eval-when-compile
;;     ;; Silence missing function warnings
;;     (declare-function global-hungry-delete-mode "hungry-delete.el"))
;;   :config
;;   (global-hungry-delete-mode t)
;;   )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Syntax Highlighting in CUDA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load CUDA mode so we get syntax highlighting in .cu files
;; (use-package cuda-mode
;;   :ensure t
;;   :mode (("\\.cu\\'" . cuda-mode)
;;          ("\\.cuh\\'" . cuda-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; autopair
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Automatically at closing brace, bracket and quote
;; (use-package autopair
;;   :ensure t
;;   :init
;;   (eval-when-compile
;;     ;; Silence missing function warnings
;;     (declare-function autopair-global-mode "autopair.el"))
;;   :config
;;   (autopair-global-mode t)
;;   )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flyspell Mode for Spelling Corrections
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (use-package flyspell
;;   :ensure t
;;   :init
;;   (eval-when-compile
;;     ;; Silence missing function warnings
;;     (declare-function flyspell-goto-next-error "flyspell.el")
;;     (declare-function flyspell-mode "flyspell.el")
;;     (declare-function flyspell-prog-mode "flyspell.el"))
;;   (setq flyspell-issue-welcome-flag nil)
;;   :config
;;   (defun flyspell-check-next-highlighted-word ()
;;     "Custom function to spell check next highlighted word."
;;     (interactive)
;;     (flyspell-goto-next-error)
;;     (ispell-word))

;;   (global-set-key (kbd "<f7>") 'flyspell-buffer)
;;   (global-set-key (kbd "<f8>") 'flyspell-correct-previous)
;;   (global-set-key (kbd "<f9>") 'flyspell-correct-previous)

;;   (add-hook 'text-mode-hook #'flyspell-mode)
;;   (add-hook 'prog-mode-hook #'flyspell-prog-mode)
;;   (add-hook 'org-mode-hook #'flyspell-mode)
;;   )
;; (use-package flyspell-correct-ivy
;;   :ensure t
;;   :after flyspell)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Magit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package magit
  :ensure t
  :requires dash
  :after (ivy)
  :commands (magit-checkout)
  :bind (("M-g M-s" . magit-status)
         ("M-g M-c" . 'magit-checkout))
  :config
  (add-hook 'magit-mode-hook (lambda () (setq whitespace-mode -1)))
  (setq magit-completing-read-function 'ivy-completing-read))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GitGutter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package git-gutter
  :ensure t
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function global-git-gutter-mode "git-gutter.el"))
  :config
  ;; If you enable global minor mode
  (global-git-gutter-mode t)
  ;; Auto update every 5 seconds
  (custom-set-variables
   '(git-gutter:update-interval 5))

  ;; Set the foreground color of modified lines to something obvious
  (set-face-foreground 'git-gutter:modified "purple")
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; web-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package web-mode
  :ensure t
  :mode (("\\.phtml\\'" . web-mode)
         ("\\.tpl\\.php\\'" . web-mode)
         ("\\.[agj]sp\\'" . web-mode)
         ("\\.as[cp]x\\'" . web-mode)
         ("\\.erb\\'" . web-mode)
         ("\\.mustache\\'" . web-mode)
         ("\\.djhtml\\'" . web-mode)
         ("\\.html?\\'" . web-mode))
  )

(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
<<<<<<< HEAD
)
(add-hook 'web-mode-hook  'my-web-mode-hook)

=======
  )

(add-hook 'web-mode-hook  'my-web-mode-hook)


>>>>>>> 481c38631e0f9e3db30ad272016a335a333cbabe
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; yaml-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package yaml-mode
  :ensure t
  :mode (".yml" ".yaml"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; json-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package json-mode
  :ensure t
  :mode (".json" ".imp"))


<<<<<<< HEAD
;; For completions at cursor, use company-mode
;; (use-package company
;;   :config
;;   (setq company-idle-delay 0.3)
=======
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cmake mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package cmake-mode
  :ensure t
  :mode ("CMakeLists.txt" ".cmake")
  :hook (cmake-mode . (lambda ()
                        (add-to-list 'company-backends 'company-cmake)))
  :config
  (use-package cmake-font-lock
    :ensure t
    :defer t
    :commands (cmake-font-lock-activate)
    :hook (cmake-mode . (lambda ()
                          (cmake-font-lock-activate)
                          (font-lock-add-keywords
                           nil '(("\\<\\(FIXME\\|TODO\\|BUG\\|DONE\\)"
                                  1 font-lock-warning-face t)))
                          ))
    )
  )
>>>>>>> 481c38631e0f9e3db30ad272016a335a333cbabe

;;   (global-company-mode 1)
;;   (global-set-key (kbd "C-<tab>") 'company-complete))

<<<<<<< HEAD
=======
;;(global-flycheck-mode t)
;;(add-hook 'after-init-hook #'global-flycheck-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RJSX mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package rjsx-mode
  :ensure t
  :mode (("\\.js\\'" . rjsx-mode)
         ("\\.ts\\'" . rjsx-mode)
         ("\\.tsx\\'" . rjsx-mode)
         ("\\.jsx\\'" . rjsx-mode))
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Packages for javascript and typescript
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package tree-sitter
  :ensure t
  :config
  ;; activate tree-sitter on any buffer containing code for which it has a parser available
  (global-tree-sitter-mode)
  ;; you can easily see the difference tree-sitter-hl-mode makes for python, ts or tsx
  ;; by switching on and off
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package tree-sitter-langs
  :ensure t
  :after tree-sitter)



(use-package typescript-mode
  :after tree-sitter
  :config
  ;; we choose this instead of tsx-mode so that eglot can automatically figure out language for server
  ;; see https://github.com/joaotavora/eglot/issues/624 and https://github.com/joaotavora/eglot#handling-quirky-servers
  (define-derived-mode typescriptreact-mode typescript-mode
    "TypeScript TSX")

  ;; use our derived mode for tsx files
  (add-to-list 'auto-mode-alist '("\\.tsx?\\'" . typescriptreact-mode))
  ;; by default, typescript-mode is mapped to the treesitter typescript parser
  ;; use our derived mode to map both .tsx AND .ts -> typescriptreact-mode -> treesitter tsx
  (add-to-list 'tree-sitter-major-mode-language-alist '(typescriptreact-mode . tsx)))


;; https://github.com/orzechowskid/tsi.el/
;; great tree-sitter-based indentation for typescript/tsx, css, json
(use-package tsi
  :after tree-sitter
  :quelpa (tsi :fetcher github :repo "orzechowskid/tsi.el")
  ;; define autoload definitions which when actually invoked will cause package to be loaded
  :commands (tsi-typescript-mode tsi-json-mode tsi-css-mode)
  :init
  (add-hook 'typescript-mode-hook (lambda () (tsi-typescript-mode 1)))
  (add-hook 'json-mode-hook (lambda () (tsi-json-mode 1)))
  (add-hook 'css-mode-hook (lambda () (tsi-css-mode 1)))
  (add-hook 'scss-mode-hook (lambda () (tsi-scss-mode 1))))


;; auto-format different source code files extremely intelligently
;; https://github.com/radian-software/apheleia
(use-package apheleia
  :ensure t
  :config
  (apheleia-global-mode +1))


;; lsp language server
(use-package eglot
  :ensure t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tide
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun setup-tide-mode()
  "Setup function for tide."
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (tide-hl-identifier-mode +1)
  (company-mode +1))


(use-package tide
  :ensure t
  :after (rjsx-mode company flycheck)
  :hook (rjsx-mode . setup-tide-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Prettier
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package prettier-js
  :ensure t
  :after (rjsx-mode)
  :hook (rjsx-mode . prettier-js-mode))
>>>>>>> 481c38631e0f9e3db30ad272016a335a333cbabe

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package: yasnippet
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (use-package yasnippet
;;   :ensure t
;;   :commands (yas-reload-all)
;;   :init
;;   (eval-when-compile
;;     ;; Silence missing function warnings
;;     (declare-function yas-global-mode "yasnippet.el"))
;;   :defer 5
;;   :config
;;   (yas-global-mode t)
;;   (yas-reload-all))

;; (use-package yasnippet-snippets
;;   :ensure t
;;   :after yasnippet
;;   :config
;;   (yas-reload-all))

;; Apparently the company-yasnippet backend shadows all backends that
;; come after it. To work around this we assign yasnippet to a different
;; keybind since actual source completion is vital.
;; (use-package company-yasnippet
;;   :bind ("C-M-y" . company-yasnippet)
;;   :after (yasnippet))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Appearance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The deeper blue is loaded but the resulting text
;; appears black in Aquamacs. This can be fixed by setting
;; the font color under Menu Bar->Options->Appearance->Font For...
;; and then setting "Adopt Face and Frame Parameter as Frame Default"
;; (use-package sourcerer-theme
;;   :ensure t
;;   :config
;;   (load-theme 'sourcerer t))

;; (use-package zenburn-theme
;;     :ensure t
;;     :config (load-theme 'zenburn t))

;; (load-theme 'wombat t)

(use-package doom-themes
  :ensure t
  :config (load-theme 'doom-vibrant t))

(set-face-background 'hl-line "#372E2D")
;; The minibuffer default colors with my theme are impossible to read, so change


;; them to something better using ivy-minibuffer-match-face.
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((((type tty) (background dark)) (:background "nil"))))
 '(company-preview ((t (:background "#073642" :foreground "#2aa198"))))
 '(company-preview-common ((t (:foreground "#93a1a1" :underline t))))
 '(company-scrollbar-bg ((t (:background "#073642" :foreground "#2aa198"))))
 '(company-scrollbar-fg ((t (:foreground "#002b36" :background "#839496"))))
 '(company-template-field ((t (:background "#7B6000" :foreground "#073642"))))
 '(company-tooltip ((t (:background "black" :foreground "DeepSkyBlue1"))))
 '(company-tooltip-annotation ((t (:foreground "#93a1a1" :background "#073642"))))
 '(company-tooltip-common ((t (:foreground "#93a1a1" :underline t))))
 '(company-tooltip-common-selection ((t (:foreground "#93a1a1" :underline t))))
 '(company-tooltip-mouse ((t (:background "DodgerBlue4" :foreground "CadetBlue1"))))
 '(company-tooltip-selection ((t (:background "DodgerBlue4" :foreground "CadetBlue1"))))
 '(header-line ((t (:background "#003366"))))
 '(ivy-minibuffer-match-face-1 ((((class color) (background light)) (:background "#555555")) (((class color) (background dark)) (:background "#555555"))))
 '(ivy-minibuffer-match-face-2 ((t (:background "#314f30" :weight bold))))
 '(ivy-minibuffer-match-face-3 ((t (:background "#48225b" :weight bold))))
 '(ivy-minibuffer-match-face-4 ((t (:background "#680a0a" :weight bold))))
 '(lsp-ui-doc-background ((t (:background nil))))
 '(lsp-ui-doc-header ((t (:inherit (font-lock-string-face italic)))))
 '(which-func ((t (:foreground "#8fb28f")))))

;; I don't care to see the splash screen
(setq inhibit-splash-screen t)

;; Hide the scroll bar
(scroll-bar-mode -1)
(defvar my-font-size 120)
(set-face-attribute 'mode-line nil  :height my-font-size)
(set-face-attribute 'header-line nil  :height my-font-size)
(setq default-frame-alist
      '((top . 0) (left . 0) ;; position
        (width . 110) (height . 45) ;; size
        ))

(global-linum-mode -1)
(set-face-attribute 'default nil :height my-font-size)

(setq-default indicate-empty-lines t)
(when (not indicate-empty-lines)
  (toggle-indicate-empty-lines))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable which function mode and set the header line to display both the
;; path and the function we're in
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (which-function-mode t)

;; ;; Remove function from mode bar
;; (setq mode-line-misc-info
;;       (delete (assoc 'which-func-mode
;;                      mode-line-misc-info) mode-line-misc-info))


;; (defmacro with-face
;;     (str &rest properties)
;;   `(propertize ,str 'face (list ,@properties)))

;; (defun sl/make-header ()
;;   "."
;;   (let* ((sl/full-header (abbreviate-file-name buffer-file-name))
;;          (sl/header (file-name-directory sl/full-header))
;;          (sl/drop-str "[...]")
;;          )
;;     (if (> (length sl/full-header)
;;            (window-body-width))
;;         (if (> (length sl/header)
;;                (window-body-width))
;;             (progn
;;               (concat (with-face sl/drop-str
;;                                  :background "blue"
;;                                  :weight 'bold
;;                                  )
;;                       (with-face (substring sl/header
;;                                             (+ (- (length sl/header)
;;                                                   (window-body-width))
;;                                                (length sl/drop-str))
;;                                             (length sl/header))
;;                                  ;; :background "red"
;;                                  :weight 'bold
;;                                  )))
;;           (concat
;;            (with-face sl/header
;;                       ;; :background "red"
;;                       :foreground "red"
;;                       :weight 'bold)))
;;       (concat (if window-system ;; In the terminal the green is hard to read
;;                   (with-face sl/header
;;                              ;; :background "green"
;;                              ;; :foreground "black"
;;                              :weight 'bold
;;                              :foreground "#8fb28f"
;;                              )
;;                 (with-face sl/header
;;                            ;; :background "green"
;;                            ;; :foreground "black"
;;                            :weight 'bold
;;                            :foreground "blue"
;;                            ))
;;               (with-face (file-name-nondirectory buffer-file-name)
;;                          :weight 'bold
;;                          ;; :background "red"
;;                          )))))

;; (defun sl/display-header ()
;;   "Create the header string and display it."
;;   ;; The dark blue in the header for which-func is terrible to read.
;;   ;; However, in the terminal it's quite nice
;;   (if window-system
;;       (custom-set-faces
;;        '(which-func ((t (:foreground "#8fb28f")))))
;;     (custom-set-faces
;;      '(which-func ((t (:foreground "blue"))))))
;;   ;; Set the header line
;;   (setq header-line-format

;;         (list "-"
;;               '(which-func-mode ("" which-func-format))
;;               '("" ;; invocation-name
;;                 (:eval (if (buffer-file-name)
;;                            (concat "[" (sl/make-header) "]")
;;                          "[%b]")))
;;               )
;;         )
;;   )
;; ;; Call the header line update
;; (add-hook 'buffer-list-update-hook
;;           'sl/display-header)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Powerline theme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; powerline theme where the modes are on the right side.
;; (use-package powerline
;;   :ensure t
;;   :config
;;   (defun powerline-right-theme ()
;;     "Setup a mode-line with major and minor modes on the right side."
;;     (interactive)
;;     (setq-default mode-line-format
;;                   '("%e"
;;                     (:eval
;;                      (let* ((active (powerline-selected-window-active))
;;                             (mode-line-buffer-id (if active 'mode-line-buffer-id 'mode-line-buffer-id-inactive))
;;                             (mode-line (if active 'mode-line 'mode-line-inactive))
;;                             (face0 (if active 'powerline-active0 'powerline-inactive0))
;;                             (face1 (if active 'powerline-active1 'powerline-inactive1))
;;                             (face2 (if active 'powerline-active2 'powerline-inactive2))
;;                             (separator-left (intern (format "powerline-%s-%s"
;;                                                             (powerline-current-separator)
;;                                                             (car powerline-default-separator-dir))))
;;                             (separator-right (intern (format "powerline-%s-%s"
;;                                                              (powerline-current-separator)
;;                                                              (cdr powerline-default-separator-dir))))
;;                             (lhs (list (powerline-raw "%*" face0 'l)
;;                                        (powerline-buffer-size face0 'l)
;;                                        (powerline-buffer-id `(mode-line-buffer-id ,face0) 'l)
;;                                        (powerline-raw " ")
;;                                        (funcall separator-left face0 face1)
;;                                        (powerline-narrow face1 'l)
;;                                        (powerline-vc face1)))
;;                             (center (list (powerline-raw global-mode-string face1 'r)
;;                                           (powerline-raw "%4l" face1 'r)
;;                                           (powerline-raw ":" face1)
;;                                           (powerline-raw "%3c" face1 'r)
;;                                           (funcall separator-right face1 face0)
;;                                           (powerline-raw " ")
;;                                           (powerline-raw "%6p" face0 'r)
;;                                           (powerline-hud face2 face1)
;;                                           ))
;;                             (rhs (list (powerline-raw " " face1)
;;                                        (funcall separator-left face1 face2)
;;                                        (when (and (boundp 'erc-track-minor-mode) erc-track-minor-mode)
;;                                          (powerline-raw erc-modified-channels-object face2 'l))
;;                                        (powerline-major-mode face2 'l)
;;                                        (powerline-process face2)
;;                                        (powerline-raw " :" face2)
;;                                        (powerline-minor-modes face2 'l)
;;                                        (powerline-raw " " face2)
;;                                        (funcall separator-right face2 face1)
;;                                        ))
;;                             )
;;                        (concat (powerline-render lhs)
;;                                (powerline-fill-center face1 (/ (powerline-width center) 2.0))
;;                                (powerline-render center)
;;                                (powerline-fill face1 (powerline-width rhs))
;;                                (powerline-render rhs)))))))
;;   (powerline-right-theme)
;;   )

;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Function below fix the font size increase issue in emacs 25.1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
(define-key special-event-map [config-changed-event] #'ignore)
;;(set-face-attribute 'default nil :height 165)

;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; custom setup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(custom-enabled-themes '(doom-vibrant))
 '(custom-safe-themes
   '("a3010c151dc4f42d56dec26a85ae5640afc227bece71d058e394667718b66a49" default))
 '(exwm-floating-border-color "#1c1f24")
 '(fci-rule-color "#62686E")
 '(git-gutter:update-interval 5)
 '(highlight-tail-colors
   ((("#2c3636" "#99bb66" "green")
     . 0)
    (("#293b44" "#46D9FF" "brightcyan")
     . 20)))
 '(jdee-db-active-breakpoint-face-colors (cons "#1c1f24" "#51afef"))
 '(jdee-db-requested-breakpoint-face-colors (cons "#1c1f24" "#7bc275"))
 '(jdee-db-spec-breakpoint-face-colors (cons "#1c1f24" "#484854"))
 '(objed-cursor-color "#ff665c")
 '(package-selected-packages
<<<<<<< HEAD
   '(web-beautify rust-mode doom-themes json-mode yaml-mode web-mode git-gutter magit vlf writegood-mode markdown-mode realgud which-key wgrep dumb-jump multiple-cursors avy counsel-projectile projectile counsel-etags counsel swiper ivy fzf ag evil dired-hide-dotfiles auto-package-update async use-package))
 '(pdf-view-midnight-colors (cons "#bbc2cf" "#242730"))
 '(rustic-ansi-faces
   ["#242730" "#ff665c" "#7bc275" "#FCCE7B" "#51afef" "#C57BDB" "#5cEfFF" "#bbc2cf"])
 '(vc-annotate-background "#242730")
 '(vc-annotate-color-map
   (list
    (cons 20 "#7bc275")
    (cons 40 "#a6c677")
    (cons 60 "#d1ca79")
    (cons 80 "#FCCE7B")
    (cons 100 "#f4b96e")
    (cons 120 "#eda461")
    (cons 140 "#e69055")
    (cons 160 "#db8981")
    (cons 180 "#d082ae")
    (cons 200 "#C57BDB")
    (cons 220 "#d874b0")
    (cons 240 "#eb6d86")
    (cons 260 "#ff665c")
    (cons 280 "#d15e59")
    (cons 300 "#a35758")
    (cons 320 "#754f56")
    (cons 340 "#62686E")
    (cons 360 "#62686E")))
 '(vc-annotate-very-old-color nil))
=======
   '(quelpa-use-package eglot quelpa apheleia tree-sitter-langs tree-sitter rust-mode prettier-js rjsx-mode org-roam-setup tide flycheck company company-mode org-roam doom-themes zzz-to-char yasnippet-snippets yaml-mode writegood-mode window-numbering which-key wgrep web-mode vlf use-package typescript-mode string-inflection realgud rainbow-delimiters powerline origami multiple-cursors markdown-mode magit json-mode hungry-delete git-gutter fzf evil dumb-jump dired-hide-dotfiles cuda-mode counsel-projectile counsel-etags cmake-font-lock beacon auto-package-update async ag)))
>>>>>>> 481c38631e0f9e3db30ad272016a335a333cbabe
