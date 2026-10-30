;;; terminal-colors-frame-color.el --- Synchronize frame colors with terminal buffers -*- lexical-binding: t -*-

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
;; This library provides helper functions to synchronize the Emacs frame
;; foreground and background parameters with the active buffer when switching
;; between terminal buffers (`vterm-mode', `term-mode', `eat-mode') and
;; standard Emacs buffers.

;;; Code:

(defvar terminal-colors-frame-color--theme-background nil
  "The background color of the currently loaded Emacs theme.")

(defvar terminal-colors-frame-color--theme-foreground nil
  "The foreground color of the currently loaded Emacs theme.")

(defcustom terminal-colors-frame-color-vterm-update-frame-color nil
  "Update the frame background and foreground color."
  :type 'boolean
  :group 'terminal-colors-vterm)

;; (when terminal-colors-frame-color-vterm-update-frame-color
;;    (terminal-colors-frame-color--save-theme-fg-bg)
;;    (add-hook 'window-configuration-change-hook
;;              #'terminal-colors-frame-color--auto-change)
;;
;;    (add-hook 'terminal-colors--after-load-hook
;;              #'terminal-colors-frame-color--save-theme-fg-bg))

(defun terminal-colors-frame-color--auto-change (&rest _)
  "Update the frame's bg and fg colors based on the buffer's major mode."
  ;; TODO standardize detecting the major mode using a list
  (when terminal-colors-frame-color-vterm-update-frame-color
    (let* ((term-p (or (derived-mode-p 'vterm-mode)
                       (derived-mode-p 'term-mode)
                       (derived-mode-p 'eat-mode)))
           (fg-color (if (and term-p
                              (bound-and-true-p terminal-colors--foreground))
                         terminal-colors--foreground
                       terminal-colors-frame-color--theme-foreground))
           (bg-color (if (and term-p
                              (bound-and-true-p terminal-colors--background))
                         terminal-colors--background
                       terminal-colors-frame-color--theme-background)))
      (when (and fg-color (not (member fg-color
                                       '(unspecified-fg "unspecified-fg"))))
        (set-frame-parameter nil 'foreground-color fg-color))
      (when (and bg-color (not (member bg-color
                                       '(unspecified-bg "unspecified-bg"))))
        (set-frame-parameter nil 'background-color bg-color)))))

(defun terminal-colors-frame-color--save-theme-fg-bg (&rest _)
  "Save the foreground and background color of the current theme."
  (setq terminal-colors-frame-color--theme-background
        (face-background 'default))
  (setq terminal-colors-frame-color--theme-foreground
        (face-foreground 'default)))

(provide 'terminal-colors-frame-color)

;; Local variables:
;; byte-compile-warnings: (not free-vars)
;; End:

;;; terminal-colors-frame-color.el ends here
