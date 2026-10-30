;;; terminal-colors-term.el --- Terminal color schemes for term and ansi-term -*- lexical-binding: t -*-

;; Copyright (C) 2024-2026 James Cherti | https://www.jamescherti.com/contact/

;; Author: James Cherti
;; URL: https://github.com/jamescherti/terminal-colors.el
;; Package-Requires: ((emacs "29.1"))
;; Keywords: faces terminals
;; Version: 0.0.9
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;; This library integrates `terminal-colors' with the built-in Emacs `term'
;; and `ansi-term' terminal emulators.
;;
;; Enable `terminal-colors-term-mode' to apply unified terminal color schemes
;; to all `term-mode' buffers:
;;
;;   (terminal-colors-term-mode 1)

;;; Code:

(require 'terminal-colors)
(require 'term)
(require 'ansi-color)

(defgroup terminal-colors-term nil
  "Terminal color schemes for `term' and `ansi-term'."
  :group 'terminal-colors)

(defvar terminal-colors-term--backup-color-vector nil
  "A backup of the `ansi-term' color vector.")

(defun terminal-colors-term--set-foreground-background ()
  "Set the `term' foreground and background color."
  (when (derived-mode-p 'term-mode)
    (terminal-colors--set-foreground-background)))

(defun terminal-colors-term--reset ()
  "Reset the `term' terminal theme."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (derived-mode-p 'term-mode)
                 terminal-colors--remap-cookies)
        (mapc #'face-remap-remove-relative terminal-colors--remap-cookies)
        (setq terminal-colors--remap-cookies nil))))
  (when terminal-colors-term--backup-color-vector
    (setq ansi-term-color-vector terminal-colors-term--backup-color-vector)
    (setq terminal-colors-term--backup-color-vector nil)))

(defun terminal-colors-term--apply ()
  "Apply the `term' theme."
  (unless terminal-colors-term--backup-color-vector
    (setq terminal-colors-term--backup-color-vector ansi-term-color-vector))

  (setq ansi-term-color-vector [term terminal-colors-term-color-black
                                     terminal-colors-term-color-red
                                     terminal-colors-term-color-green
                                     terminal-colors-term-color-yellow
                                     terminal-colors-term-color-blue
                                     terminal-colors-term-color-magenta
                                     terminal-colors-term-color-cyan
                                     terminal-colors-term-color-white
                                     terminal-colors-term-color-bright-black
                                     terminal-colors-term-color-bright-red
                                     terminal-colors-term-color-bright-green
                                     terminal-colors-term-color-bright-yellow
                                     terminal-colors-term-color-bright-blue
                                     terminal-colors-term-color-bright-magenta
                                     terminal-colors-term-color-bright-cyan
                                     terminal-colors-term-color-bright-white])

  ;; term
  (set-face-attribute 'term nil
                      :foreground terminal-colors--foreground
                      :background terminal-colors--background)

  (set-face-attribute 'term-color-black nil
                      :foreground terminal-colors--color-black
                      :background terminal-colors--color-black)

  (set-face-attribute 'term-color-red nil
                      :foreground terminal-colors--color-red
                      :background terminal-colors--color-red)

  (set-face-attribute 'term-color-green nil
                      :foreground terminal-colors--color-green
                      :background terminal-colors--color-green)

  (set-face-attribute 'term-color-yellow nil
                      :foreground terminal-colors--color-yellow
                      :background terminal-colors--color-yellow)

  (set-face-attribute 'term-color-blue nil
                      :foreground terminal-colors--color-blue
                      :background terminal-colors--color-blue)

  (set-face-attribute 'term-color-magenta nil
                      :foreground terminal-colors--color-magenta
                      :background terminal-colors--color-magenta)

  (set-face-attribute 'term-color-cyan nil
                      :foreground terminal-colors--color-cyan
                      :background terminal-colors--color-cyan)

  (set-face-attribute 'term-color-white nil
                      :foreground terminal-colors--color-white
                      :background terminal-colors--color-white)

  (set-face-attribute 'term-color-bright-black nil
                      :foreground terminal-colors--color-bright-black
                      :background terminal-colors--color-bright-black)

  (set-face-attribute 'term-color-bright-red nil
                      :foreground terminal-colors--color-bright-red
                      :background terminal-colors--color-bright-red)

  (set-face-attribute 'term-color-bright-green nil
                      :foreground terminal-colors--color-bright-green
                      :background terminal-colors--color-bright-green)

  (set-face-attribute 'term-color-bright-yellow nil
                      :foreground terminal-colors--color-bright-yellow
                      :background terminal-colors--color-bright-yellow)

  (set-face-attribute 'term-color-bright-blue nil
                      :foreground terminal-colors--color-bright-blue
                      :background terminal-colors--color-bright-blue)

  (set-face-attribute 'term-color-bright-magenta nil
                      :foreground terminal-colors--color-bright-magenta
                      :background terminal-colors--color-bright-magenta)

  (set-face-attribute 'term-color-bright-cyan nil
                      :foreground terminal-colors--color-bright-cyan
                      :background terminal-colors--color-bright-cyan)

  (set-face-attribute 'term-color-bright-white nil
                      :foreground terminal-colors--color-bright-white
                      :background terminal-colors--color-bright-white)

  ;; ansi-color
  ;; (set-face-attribute 'ansi-color-black nil
  ;;                     :foreground terminal-colors--color-black
  ;;                     :background terminal-colors--color-black)
  ;;
  ;; (set-face-attribute 'ansi-color-red nil
  ;;                     :foreground terminal-colors--color-red
  ;;                     :background terminal-colors--color-red)
  ;;
  ;; (set-face-attribute 'ansi-color-green nil
  ;;                     :foreground terminal-colors--color-green
  ;;                     :background terminal-colors--color-green)
  ;;
  ;; (set-face-attribute 'ansi-color-yellow nil
  ;;                     :foreground terminal-colors--color-yellow
  ;;                     :background terminal-colors--color-yellow)
  ;;
  ;; (set-face-attribute 'ansi-color-blue nil
  ;;                     :foreground terminal-colors--color-blue
  ;;                     :background terminal-colors--color-blue)
  ;;
  ;; (set-face-attribute 'ansi-color-magenta nil
  ;;                     :foreground terminal-colors--color-magenta
  ;;                     :background terminal-colors--color-magenta)
  ;;
  ;; (set-face-attribute 'ansi-color-cyan nil
  ;;                     :foreground terminal-colors--color-cyan
  ;;                     :background terminal-colors--color-cyan)
  ;;
  ;; (set-face-attribute 'ansi-color-white nil
  ;;                     :foreground terminal-colors--color-white
  ;;                     :background terminal-colors--color-white)
  ;;
  ;; (set-face-attribute 'ansi-color-bright-black nil
  ;;                     :foreground terminal-colors--color-bright-black
  ;;                     :background terminal-colors--color-bright-black)
  ;;
  ;; (set-face-attribute 'ansi-color-bright-red nil
  ;;                     :foreground terminal-colors--color-bright-red
  ;;                     :background terminal-colors--color-bright-red)
  ;;
  ;; (set-face-attribute 'ansi-color-bright-green nil
  ;;                     :foreground terminal-colors--color-bright-green
  ;;                     :background terminal-colors--color-bright-green)
  ;;
  ;; (set-face-attribute 'ansi-color-bright-yellow nil
  ;;                     :foreground terminal-colors--color-bright-yellow
  ;;                     :background terminal-colors--color-bright-yellow)
  ;;
  ;; (set-face-attribute 'ansi-color-bright-blue nil
  ;;                     :foreground terminal-colors--color-bright-blue
  ;;                     :background terminal-colors--color-bright-blue)
  ;;
  ;; (set-face-attribute 'ansi-color-bright-magenta nil
  ;;                     :foreground terminal-colors--color-bright-magenta
  ;;                     :background terminal-colors--color-bright-magenta)
  ;;
  ;; (set-face-attribute 'ansi-color-bright-cyan nil
  ;;                     :foreground terminal-colors--color-bright-cyan
  ;;                     :background terminal-colors--color-bright-cyan)
  ;;
  ;; (set-face-attribute 'ansi-color-bright-white nil
  ;;                     :foreground terminal-colors--color-bright-white
  ;;                     :background terminal-colors--color-bright-white)

  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (terminal-colors-term--set-foreground-background))))

;;;###autoload
(define-minor-mode terminal-colors-term-mode
  "Toggle `terminal-colors-term-mode'."
  :global t
  :lighter " TThemesAnsi-Color"
  :group 'terminal-colors-term
  (if terminal-colors-term-mode
      (progn
        (add-hook 'terminal-colors--after-load-hook
                  #'terminal-colors-term--apply)
        (add-hook 'terminal-colors--reset-hook
                  #'terminal-colors-term--reset)
        (add-hook 'term-mode-hook
                  #'terminal-colors-term--set-foreground-background)
        ;; (add-hook 'window-configuration-change-hook
        ;;           #'terminal-colors-term--set-foreground-background)
        (terminal-colors--init))
    ;; Remove
    (remove-hook 'terminal-colors--after-load-hook
                 #'terminal-colors-term--apply)
    (remove-hook 'terminal-colors--reset-hook
                 #'terminal-colors-term--reset)
    (remove-hook 'term-mode-hook
                 #'terminal-colors-term--set-foreground-background)
    ;; (remove-hook 'window-configuration-change-hook
    ;;              #'terminal-colors-term--set-foreground-background)
    (terminal-colors-term--reset)))

(provide 'terminal-colors-term)

;; Local variables:
;; byte-compile-warnings: (not free-vars)
;; End:

;;; terminal-colors-term.el ends here
