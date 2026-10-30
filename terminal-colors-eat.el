;;; terminal-colors-eat.el --- Terminal color schemes for Eat -*- lexical-binding: t -*-

;; Copyright (C) 2024-2026 James Cherti | https://www.jamescherti.com/contact/

;; Author: James Cherti <https://www.jamescherti.com/contact/>
;; URL: https://github.com/jamescherti/terminal-colors.el
;; Package-Requires: ((emacs "29.1") (eat "0.9.4"))
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
;; This library integrates `terminal-colors' with the Eat terminal emulator.
;;
;; Enable `terminal-colors-eat-mode' to apply unified terminal color schemes
;; to all `eat-mode' buffers:
;;
;;   (terminal-colors-eat-mode 1)

;;; Code:

(require 'terminal-colors)
(require 'eat)

(defgroup terminal-colors-eat nil
  "Terminal color schemes for Eat."
  :group 'terminal-colors)

(defun terminal-colors-eat--set-foreground-background ()
  "Set the terminal theme foreground and background color."
  (when (derived-mode-p 'eat-mode)
    (terminal-colors--set-foreground-background)))

(defun terminal-colors-eat--reset ()
  "Reset eat terminal theme."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (derived-mode-p 'eat-mode)
                 terminal-colors--remap-cookies)
        (mapc #'face-remap-remove-relative terminal-colors--remap-cookies)
        (setq terminal-colors--remap-cookies nil)))))

(defun terminal-colors-eat--apply ()
  "Apply eat terminal theme."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (terminal-colors-eat--set-foreground-background)))

  (face-spec-set 'eat-term-color-0
                 `((t (:foreground ,terminal-colors--color-black
                                   :background ,terminal-colors--color-black))))

  (face-spec-set 'eat-term-color-1
                 `((t (:foreground ,terminal-colors--color-red
                                   :background ,terminal-colors--color-red))))

  (face-spec-set 'eat-term-color-2
                 `((t (:foreground ,terminal-colors--color-green
                                   :background ,terminal-colors--color-green))))

  (face-spec-set 'eat-term-color-3
                 `((t (:foreground ,terminal-colors--color-yellow
                                   :background ,terminal-colors--color-yellow))))

  (face-spec-set 'eat-term-color-4
                 `((t (:foreground ,terminal-colors--color-blue
                                   :background ,terminal-colors--color-blue))))

  (face-spec-set 'eat-term-color-5
                 `((t (:foreground ,terminal-colors--color-magenta
                                   :background ,terminal-colors--color-magenta))))

  (face-spec-set 'eat-term-color-6
                 `((t (:foreground ,terminal-colors--color-cyan
                                   :background ,terminal-colors--color-cyan))))

  (face-spec-set 'eat-term-color-7
                 `((t (:foreground ,terminal-colors--color-white
                                   :background ,terminal-colors--color-white))))

  (face-spec-set 'eat-term-color-8
                 `((t (:foreground ,terminal-colors--color-bright-black
                                   :background ,terminal-colors--color-bright-black))))

  (face-spec-set 'eat-term-color-9
                 `((t (:foreground ,terminal-colors--color-bright-red
                                   :background ,terminal-colors--color-bright-red))))

  (face-spec-set 'eat-term-color-10
                 `((t (:foreground ,terminal-colors--color-bright-green
                                   :background ,terminal-colors--color-bright-green))))

  (face-spec-set 'eat-term-color-11
                 `((t (:foreground ,terminal-colors--color-bright-yellow
                                   :background ,terminal-colors--color-bright-yellow))))

  (face-spec-set 'eat-term-color-12
                 `((t (:foreground ,terminal-colors--color-bright-blue
                                   :background ,terminal-colors--color-bright-blue))))

  (face-spec-set 'eat-term-color-13
                 `((t (:foreground ,terminal-colors--color-bright-magenta
                                   :background ,terminal-colors--color-bright-magenta))))

  (face-spec-set 'eat-term-color-14
                 `((t (:foreground ,terminal-colors--color-bright-cyan
                                   :background ,terminal-colors--color-bright-cyan))))

  (face-spec-set 'eat-term-color-15
                 `((t (:foreground ,terminal-colors--color-bright-white
                                   :background ,terminal-colors--color-bright-white))))

  (face-spec-set 'eat-term-color-black
                 `((t (:foreground ,terminal-colors--color-black
                                   :background ,terminal-colors--color-black))))

  (face-spec-set 'eat-term-color-red
                 `((t (:foreground ,terminal-colors--color-red
                                   :background ,terminal-colors--color-red))))

  (face-spec-set 'eat-term-color-green
                 `((t (:foreground ,terminal-colors--color-green
                                   :background ,terminal-colors--color-green))))

  (face-spec-set 'eat-term-color-yellow
                 `((t (:foreground ,terminal-colors--color-yellow
                                   :background ,terminal-colors--color-yellow))))

  (face-spec-set 'eat-term-color-blue
                 `((t (:foreground ,terminal-colors--color-blue
                                   :background ,terminal-colors--color-blue))))

  (face-spec-set 'eat-term-color-magenta
                 `((t (:foreground ,terminal-colors--color-magenta
                                   :background ,terminal-colors--color-magenta))))

  (face-spec-set 'eat-term-color-cyan
                 `((t (:foreground ,terminal-colors--color-cyan
                                   :background ,terminal-colors--color-cyan))))

  (face-spec-set 'eat-term-color-white
                 `((t (:foreground ,terminal-colors--color-white
                                   :background ,terminal-colors--color-white))))

  (face-spec-set 'eat-term-color-bright-black
                 `((t (:foreground ,terminal-colors--color-bright-black
                                   :background ,terminal-colors--color-bright-black))))

  (face-spec-set 'eat-term-color-bright-red
                 `((t (:foreground ,terminal-colors--color-bright-red
                                   :background ,terminal-colors--color-bright-red))))

  (face-spec-set 'eat-term-color-bright-green
                 `((t (:foreground ,terminal-colors--color-bright-green
                                   :background ,terminal-colors--color-bright-green))))

  (face-spec-set 'eat-term-color-bright-yellow
                 `((t (:foreground ,terminal-colors--color-bright-yellow
                                   :background ,terminal-colors--color-bright-yellow))))

  (face-spec-set 'eat-term-color-bright-blue
                 `((t (:foreground ,terminal-colors--color-bright-blue
                                   :background ,terminal-colors--color-bright-blue))))

  (face-spec-set 'eat-term-color-bright-magenta
                 `((t (:foreground ,terminal-colors--color-bright-magenta
                                   :background ,terminal-colors--color-bright-magenta))))

  (face-spec-set 'eat-term-color-bright-cyan
                 `((t (:foreground ,terminal-colors--color-bright-cyan
                                   :background ,terminal-colors--color-bright-cyan))))

  (face-spec-set 'eat-term-color-bright-white
                 `((t (:foreground ,terminal-colors--color-bright-white
                                   :background ,terminal-colors--color-bright-white)))))

;;;###autoload
(define-minor-mode terminal-colors-eat-mode
  "Toggle `terminal-colors-eat-mode'."
  :global t
  :lighter " TThemesEat"
  :group 'terminal-colors-eat
  (if terminal-colors-eat-mode
      (progn
        (add-hook 'terminal-colors--after-load-hook
                  #'terminal-colors-eat--apply)
        (add-hook 'terminal-colors--reset-hook #'terminal-colors-eat--reset)
        (add-hook 'eat-mode-hook
                  #'terminal-colors-eat--set-foreground-background)
        ;; (add-hook 'window-configuration-change-hook
        ;;           #'terminal-colors-eat--set-foreground-background)
        (terminal-colors--init))
    (remove-hook 'terminal-colors--after-load-hook
                 #'terminal-colors-eat--apply)
    (remove-hook 'terminal-colors--reset-hook
                 #'terminal-colors-eat--reset)
    (remove-hook 'eat-mode-hook
                 #'terminal-colors-eat--set-foreground-background)
    ;; (remove-hook 'window-configuration-change-hook
    ;;              #'terminal-colors-eat--set-foreground-background)
    (terminal-colors-eat--reset)))

(provide 'terminal-colors-eat)

;; Local variables:
;; byte-compile-warnings: (not free-vars)
;; End:

;;; terminal-colors-eat.el ends here
