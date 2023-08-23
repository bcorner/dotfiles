;; -*- no-byte-compile: t -*-
(let* ((current-directory (file-name-directory load-file-name))
       (elpaca-setup (concat current-directory "elpaca-setup.el")))
  (load elpaca-setup))

(require 'use-package)
(setq use-package-enable-imenu-support t)

(defvar imalison:do-benchmark nil)

(let ((bench-file (concat (file-name-directory user-init-file) "benchmark.el")))
  (when (file-exists-p bench-file) (load bench-file)))

(use-package benchmark-init
  :if imalison:do-benchmark
  :demand t
  :config
  (setq max-specpdl-size 99999999))

(use-package emit
  :demand t
  :elpaca (emit :type git :host github :repo "IvanMalison/emit"))

(use-package shut-up
  :demand t
  :config
  (defun imalison:shut-up-around (function &rest args)
	(shut-up (apply function args))))

(use-package dash :demand t)
(use-package s :demand t)

(elpaca-wait)

(defvar imalison:kat-mode nil)
(setq custom-file "~/.emacs.d/custom-before.el")
(setq load-prefer-newer t)

;; If this isn't here and there's a problem with init, graphical emacs
;; is super annoying.
(when (equal system-type 'darwin)
  (setq mac-option-modifier 'meta)
  (setq mac-command-modifier 'super))

;; This seems to fix issues with helm not explicitly declaring its dependency on async
(use-package async :demand t)

;; Without this, org can behave very strangely
(use-package org
  :elpaca
  (org :type git :host github :repo "colonelpanic8/org-mode" :local-repo "org"
       :branch "add-org-agenda-transient"
       :depth full :build
       (:not autoloads) :files
       (:defaults "lisp/*.el" ("etc/styles/" "etc/styles/*")))
  :demand t
  :custom
  (org-edit-src-content-indentation 0))

(elpaca-wait)

(let ((debug-on-error t))
  (org-babel-load-file
   (concat (file-name-directory load-file-name) "README.org")))

(when imalison:kat-mode
  (let ((debug-on-error t))
    (org-babel-load-file
     (concat (file-name-directory load-file-name) "kat-mode.org"))))

(when imalison:do-benchmark (benchmark-init/deactivate))

;; Local Variables:
;; flycheck-disabled-checkers: (emacs-lisp-checkdoc)
;; End:
