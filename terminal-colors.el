;;; terminal-colors.el --- Apply unified terminal color schemes palettes across vterm, eat, and term. -*- lexical-binding: t; -*-

;; Copyright (C) 2026 James Cherti

;; Author: James Cherti <https://www.jamescherti.com/contact/>
;; Version: 0.9.9
;; URL: https://github.com/jamescherti/terminal-colors.el
;; Keywords: convenience
;; Package-Requires: ((emacs "24.1"))
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
;; Apply unified terminal color schemes palettes across vterm, eat, and term..

;;; Code:

(defgroup terminal-colors nil
  "Apply unified terminal color schemes palettes across vterm, eat, and term."
  :group 'convenience ; TODO
  :prefix "terminal-colors-"
  :link '(url-link
          :tag "Github"
          "https://github.com/jamescherti/terminal-colors.el"))

(defcustom terminal-colors-verbose nil
  "Enable displaying verbose messages."
  :type 'boolean
  :group 'terminal-colors)

(defun terminal-colors--message (&rest args)
  "Display a message with the same ARGS arguments as `message'."
  (apply #'message (concat "[terminal-colors] " (car args)) (cdr args)))

(defmacro terminal-colors--verbose-message (&rest args)
  "Display a verbose message with the same ARGS arguments as `message'."
  (declare (indent 0) (debug t))
  `(when terminal-colors-verbose
     (terminal-colors--message ,@args)))

(defun terminal-colors--enable ()
  "Enable `terminal-colors-mode'."
  ;; TODO
  t)

(defun terminal-colors--disable ()
  "Disable `terminal-colors-mode'."
  ;; TODO
  t)

;;;###autoload
(define-minor-mode terminal-colors-mode
  "Toggle `terminal-colors-mode'."
  :global t
  :lighter " terminal-colors"
  :group 'terminal-colors
  (if terminal-colors-mode
      (condition-case err
          (terminal-colors--enable)
        (error
         (setq terminal-colors-mode nil)
         (terminal-colors--disable)
         (signal (car err) (cdr err))))
    (terminal-colors--disable)))

(provide 'terminal-colors)

;;; terminal-colors.el ends here
