;;; terminal-colors-vterm.el --- Terminal color schemes for vterm -*- lexical-binding: t -*-

;; Copyright (C) 2024-2026 James Cherti | https://www.jamescherti.com/contact/

;; Author: James Cherti <https://www.jamescherti.com/contact/>
;; URL: https://github.com/jamescherti/terminal-colors.el
;; Package-Requires: ((emacs "29.1") (vterm "0.0.2"))
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
;; This library integrates `terminal-colors' with the `vterm' terminal
;; emulator.
;;
;; Enable `terminal-colors-vterm-mode' to apply unified terminal color schemes
;; to all `vterm-mode' buffers:
;;
;;   (terminal-colors-vterm-mode 1)

;;; Code:

(require 'terminal-colors)
;; (require 'term)
(require 'vterm)
(require 'terminal-colors-frame-color)

(defgroup terminal-colors-vterm nil
  "Terminal color schemes for `vterm'."
  :group 'terminal-colors)

(defvar terminal-colors-vterm--backup-color-palette nil
  "A backup of the vterm color palette.")

(defun terminal-colors-vterm--set-foreground-background ()
  "Set the `vterm' foreground and background color."
  ;; (terminal-colors-frame-color--auto-change)
  (when (derived-mode-p 'vterm-mode)
    (terminal-colors--set-foreground-background)))

(defun terminal-colors-vterm--set-face-attribute ()
  "Set the face attributes of `vterm'."
  (when (featurep 'vterm)
    (set-face-attribute 'vterm-color-black nil
                        :foreground terminal-colors--color-black
                        :background terminal-colors--color-black)
    (set-face-attribute 'vterm-color-red nil
                        :foreground terminal-colors--color-red
                        :background terminal-colors--color-red)
    (set-face-attribute 'vterm-color-green nil
                        :foreground terminal-colors--color-green
                        :background terminal-colors--color-green)
    (set-face-attribute 'vterm-color-yellow nil
                        :foreground terminal-colors--color-yellow
                        :background terminal-colors--color-yellow)
    (set-face-attribute 'vterm-color-blue nil
                        :foreground terminal-colors--color-blue
                        :background terminal-colors--color-blue)
    (set-face-attribute 'vterm-color-magenta nil
                        :foreground terminal-colors--color-magenta
                        :background terminal-colors--color-magenta)
    (set-face-attribute 'vterm-color-cyan nil
                        :foreground terminal-colors--color-cyan
                        :background terminal-colors--color-cyan)
    (set-face-attribute 'vterm-color-white nil
                        :foreground terminal-colors--color-white
                        :background terminal-colors--color-white)
    (set-face-attribute 'vterm-color-bright-black nil
                        :foreground terminal-colors--color-bright-black
                        :background terminal-colors--color-bright-black)
    (set-face-attribute 'vterm-color-bright-red nil
                        :foreground terminal-colors--color-bright-red
                        :background terminal-colors--color-bright-red)
    (set-face-attribute 'vterm-color-bright-green nil
                        :foreground terminal-colors--color-bright-green
                        :background terminal-colors--color-bright-green)
    (set-face-attribute 'vterm-color-bright-yellow nil
                        :foreground terminal-colors--color-bright-yellow
                        :background terminal-colors--color-bright-yellow)
    (set-face-attribute 'vterm-color-bright-blue nil
                        :foreground terminal-colors--color-bright-blue
                        :background terminal-colors--color-bright-blue)
    (set-face-attribute 'vterm-color-bright-magenta nil
                        :foreground terminal-colors--color-bright-magenta
                        :background terminal-colors--color-bright-magenta)
    (set-face-attribute 'vterm-color-bright-cyan nil
                        :foreground terminal-colors--color-bright-cyan
                        :background terminal-colors--color-bright-cyan)
    (set-face-attribute 'vterm-color-bright-white nil
                        :foreground terminal-colors--color-bright-white
                        :background terminal-colors--color-bright-white)))

(defun terminal-colors-vterm--get-color-override (orig-fun index &rest args)
  "Override `vterm--get-color' to use `terminal-colors' variables.

ORIG-FUN is the original color function being advised.
INDEX is the terminal color index (e.g., -1 for default, 0 for black).
ARGS are additional property keywords like :foreground or :inverse-video."
  (let ((is-foreground (member :foreground args))
        (is-inverse (member :inverse-video args)))
    (cond
     ;; Why handle background for Index -1 or 0?
     ;; 1. We only override when `terminal-colors-vterm-mode' is active.
     ;; 2. We step aside if `is-inverse' is true to maintain legible highlights.
     ;; 3. Index -1 represents the default background face.
     ;; 4. Index 0 prevents applications from drawing hardcoded black blocks
     ;;    over the intended theme background.
     ((and terminal-colors-vterm-mode
           (not is-foreground)
           (not is-inverse)
           (or (= index -1) (= index 0))
           (bound-and-true-p terminal-colors--background))
      terminal-colors--background)

     ;; Why handle foreground for Index -1?
     ;; 1. We only override when `terminal-colors-vterm-mode' is active.
     ;; 2. We step aside if `is-inverse' is true.
     ;; 3. Index -1 represents the default foreground text color. We intercept
     ;;    this to apply the theme's specific foreground color.
     ((and terminal-colors-vterm-mode
           is-foreground
           (not is-inverse)
           (= index -1)
           (bound-and-true-p terminal-colors--foreground))
      terminal-colors--foreground)

     ;; Why do we have this default fallback?
     ;; This passes the request back to the original `vterm--get-color' function
     ;; when our mode is disabled, when inverse video is requested, or for
     ;; standard ANSI colors (indices 1-15).
     (t
      (apply orig-fun index args)))))

;; (defun terminal-colors-vterm--get-color-override (orig-fun index &rest args)
;;    "Override `vterm--get-color' to use `terminal-colors' variables.
;;
;; ORIG-FUN is the original color function being advised.
;; INDEX is the terminal color index (e.g., -1 for default, 0 for black).
;; ARGS are additional property keywords like :foreground or :inverse-video."
;;    (let ((is-foreground (member :foreground args))
;;          (is-inverse (member :inverse-video args)))
;;      (cond
;;       ((and terminal-colors-vterm-mode
;;             (not is-foreground)
;;             (not is-inverse)
;;             (or (= index -1) (= index 0))
;;             (bound-and-true-p terminal-colors--background))
;;        terminal-colors--background)
;;
;;       ((and terminal-colors-vterm-mode
;;             is-foreground
;;             (not is-inverse)
;;             (= index -1)
;;             (bound-and-true-p terminal-colors--foreground))
;;        terminal-colors--foreground)
;;
;;       ;; Default to original behavior for everything else
;;       (t
;;        (apply orig-fun index args)))))

;; (defun terminal-colors-vterm--get-color-override (orig-fun index &rest args)
;;    "Override `vterm--get-color' to use `terminal-colors--background'."
;;    (let ((is-foreground (member :foreground args))
;;          (is-inverse (member :inverse-video args)))
;;      ;; Intercept requests for the default (-1) or black (0) background
;;      (if (and terminal-colors-vterm-mode
;;               (not is-foreground)
;;               (not is-inverse)
;;               (or (= index -1) (= index 0))
;;               (bound-and-true-p terminal-colors--background))
;;          terminal-colors--background
;;        (apply orig-fun index args))))

(defun terminal-colors-vterm--reset ()
  "Reset the Terminal Theme."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (derived-mode-p 'vterm-mode)
                 terminal-colors--remap-cookies)
        (mapc #'face-remap-remove-relative terminal-colors--remap-cookies)
        (setq terminal-colors--remap-cookies nil))))
  (when terminal-colors-vterm--backup-color-palette
    (setq vterm-color-palette terminal-colors-vterm--backup-color-palette)
    (setq terminal-colors-vterm--backup-color-palette nil))
  (dolist (window (window-list))
    (with-current-buffer (window-buffer window)
      (when (and (derived-mode-p 'vterm-mode)
                 (bound-and-true-p vterm--term))
        (vterm--redraw vterm--term)))))

(defun terminal-colors-vterm--apply ()
  "Apply the Terminal Theme and refresh visible vterm buffers."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (terminal-colors-vterm--set-foreground-background)))
  (when (and (featurep 'vterm)
             (not terminal-colors-vterm--backup-color-palette))
    (setq terminal-colors-vterm--backup-color-palette vterm-color-palette)
    (setq vterm-color-palette [terminal-colors-term-color-black
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
                               terminal-colors-term-color-bright-white]))
  (terminal-colors-vterm--set-face-attribute)
  ;; Force active vterm buffers to redraw to display the new theme immediately
  (dolist (window (window-list))
    (with-current-buffer (window-buffer window)
      (when (and (derived-mode-p 'vterm-mode)
                 (bound-and-true-p vterm--term))
        (vterm--redraw vterm--term)))))

;;;###autoload
(define-minor-mode terminal-colors-vterm-mode
  "Toggle `terminal-colors-vterm-mode'."
  :global t
  :lighter " TVTerm"
  :group 'terminal-colors-vterm
  (if terminal-colors-vterm-mode
      (progn
        (advice-add 'vterm--get-color :around #'terminal-colors-vterm--get-color-override)
        (add-hook 'terminal-colors--after-load-hook
                  #'terminal-colors-vterm--apply)
        (add-hook 'terminal-colors--reset-hook
                  #'terminal-colors-vterm--reset)
        (add-hook 'vterm-mode-hook
                  #'terminal-colors-vterm--set-foreground-background)
        ;; (add-hook 'window-configuration-change-hook
        ;;           #'terminal-colors-vterm--set-foreground-background)
        (terminal-colors--init))
    ;; Disable
    (advice-remove 'vterm--get-color #'terminal-colors-vterm--get-color-override)
    (remove-hook 'terminal-colors--after-load-hook
                 #'terminal-colors-vterm--apply)
    (remove-hook 'terminal-colors--reset-hook
                 #'terminal-colors-vterm--reset)
    (remove-hook 'vterm-mode-hook
                 #'terminal-colors-vterm--set-foreground-background)
    ;; (remove-hook 'window-configuration-change-hook
    ;;              #'terminal-colors-vterm--set-foreground-background)

    (terminal-colors-vterm--reset)))

(provide 'terminal-colors-vterm)

;; Local variables:
;; byte-compile-warnings: (not free-vars)
;; End:

;;; terminal-colors-vterm.el ends here
