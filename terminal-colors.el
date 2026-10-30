;;; terminal-colors.el --- Unified color schemes for vterm, Eat, and term -*- lexical-binding: t -*-

;; Copyright (C) 2024-2026 James Cherti | https://www.jamescherti.com/contact/

;; Author: James Cherti <https://www.jamescherti.com/contact/>
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
;; The `terminal-colors' package provides unified color schemes for Emacs
;; terminal emulators, including `vterm', `eat', and `term' (`ansi-term').
;;
;; It decouples terminal buffer colors from the active Emacs color theme,
;; allowing terminal buffers to use dedicated 16-color ANSI palettes and
;; buffer-local foreground/background colors modeled after standalone
;; terminal emulators such as GNOME Terminal, Konsole, and Terminator.
;;
;; Usage:
;;   (setq terminal-colors-default-theme "gnome-terminal-tango-dark")
;;   (terminal-colors-vterm-mode 1)
;;   (terminal-colors-eat-mode 1)
;;   (terminal-colors-term-mode 1)
;;
;; You can also switch themes interactively at any time using:
;;   M-x terminal-colors-load

;;; Code:

;;; Require

(require 'ansi-color)
(require 'face-remap)

;;; Variables

(defgroup terminal-colors nil
  "Unified color schemes for terminal emulators."
  :group 'faces)

(defcustom terminal-colors-default-theme "gnome-terminal-tango-dark"
  "The default theme."
  :type 'string
  :group 'terminal-colors)

(defvar terminal-colors--before-load-hook nil
  "Hook run before a terminal theme is loaded.")

(defvar terminal-colors--after-load-hook nil
  "Hook run after a terminal theme is loaded.")

(defvar terminal-colors--reset-hook nil
  "Hook run after a terminal theme is unloaded.")

(defvar terminal-colors--current-theme-name nil
  "The name of the currently loaded terminal theme.")

(defvar terminal-colors--background nil)
(defvar terminal-colors--foreground nil)
(defvar terminal-colors--cursor nil)

(defvar-local terminal-colors--remap-cookies nil
  "Buffer-local list of face remapping cookies.")

(defvar terminal-colors--color-black nil)
(defvar terminal-colors--color-red nil)
(defvar terminal-colors--color-green nil)
(defvar terminal-colors--color-yellow nil)
(defvar terminal-colors--color-blue nil)
(defvar terminal-colors--color-magenta nil)
(defvar terminal-colors--color-cyan nil)
(defvar terminal-colors--color-white nil)
(defvar terminal-colors--color-bright-black nil)
(defvar terminal-colors--color-bright-red nil)
(defvar terminal-colors--color-bright-green nil)
(defvar terminal-colors--color-bright-yellow nil)
(defvar terminal-colors--color-bright-blue nil)
(defvar terminal-colors--color-bright-magenta nil)
(defvar terminal-colors--color-bright-cyan nil)
(defvar terminal-colors--color-bright-white nil)
(defvar terminal-colors-default-foreground-background
  '(("white-on-black" . (("foreground" . "#ffffff")
                         ("background" . "#000000")
                         ("cursor" . "#ffffff")))
    ("black-on-white" . (("foreground" . "#000000")
                         ("background" . "#ffffff")
                         ("cursor" . "#000000")))
    ("terminator-orange-on-black" . (("foreground" . "#e53c00")
                                     ("background" . "#000000")
                                     ("cursor" . "#e53c00")))
    ("terminator-ambience" . (("foreground" . "#ffffff")
                              ("background" . "#300a24")
                              ("cursor" . "#ffffff")))
    ("terminator-solarized-dark" . (("foreground" . "#839496")
                                    ("background" . "#002b36")
                                    ("cursor" . "#839496")))
    ("terminator-solarized-light" . (("foreground" . "#657b83")
                                     ("background" . "#fdf6e3")
                                     ("cursor" . "#657b83")))
    ("terminator-gruvbox-light" . (("foreground" . "#3c3836")
                                   ("background" . "#fbf1c7")
                                   ("cursor" . "#3c3836")))
    ("terminator-gruvbox-dark" . (("foreground" . "#ebdbb2")
                                  ("background" . "#282828")
                                  ("cursor" . "#ebdbb2"))))
  "Default foreground, background, and cursor colors for terminal themes.")

(defvar terminal-colors-colors
  '(("gnome-terminal-tango-dark" .
     (("default-colors" . "white-on-black")
      ("colors" . (("black" . "#2e3436")
                   ("red" . "#cc0000")
                   ("green" . "#4e9a06")
                   ("yellow" . "#c4a000")
                   ("blue" . "#3465a4")
                   ("magenta" . "#75507b")
                   ("cyan" . "#06989a")
                   ("white" . "#d3d7cf")
                   ("bright-black" . "#555753")
                   ("bright-red" . "#ef2929")
                   ("bright-green" . "#8ae234")
                   ("bright-yellow" . "#fce94f")
                   ("bright-blue" . "#729fcf")
                   ("bright-magenta" . "#ad7fa8")
                   ("bright-cyan" . "#34e2e2")
                   ("bright-white" . "#eeeeec")))))

    ("gnome-terminal-tango-light" . (("default-colors" . "black-on-white")
                                     ("colors" . (("black" . "#2E3436")
                                                  ("red" . "#CC0000")
                                                  ("green" . "#4E9A06")
                                                  ("yellow" . "#C4A000")
                                                  ("blue" . "#3465A4")
                                                  ("magenta" . "#75507B")
                                                  ("cyan" . "#06989A")
                                                  ("white" . "#D3D7CF")
                                                  ("bright-black" . "#555753")
                                                  ("bright-red" . "#EF2929")
                                                  ("bright-green" . "#8AE234")
                                                  ("bright-yellow" . "#FCE94F")
                                                  ("bright-blue" . "#729FCF")
                                                  ("bright-magenta" . "#AD7FA8")
                                                  ("bright-cyan" . "#34E2E2")
                                                  ("bright-white" . "#EEEEEC")))))

    ("konsole-white-on-black" . (("default-colors" . "white-on-black")
                                 ("colors" . (("black" . "#000000")
                                              ("red" . "#b21818")
                                              ("green" . "#18b218")
                                              ("yellow" . "#b26818")
                                              ("blue" . "#1818b2")
                                              ("magenta" . "#b218b2")
                                              ("cyan" . "#18b2b2")
                                              ("white" . "#b2b2b2")
                                              ("bright-black" . "#686868")
                                              ("bright-red" . "#ff5454")
                                              ("bright-green" . "#54ff54")
                                              ("bright-yellow" . "#ffff54")
                                              ("bright-blue" . "#5454ff")
                                              ("bright-magenta" . "#ff54ff")
                                              ("bright-cyan" . "#54ffff")
                                              ("bright-white" . "#ffffff")))))
    ("terminator-tango" . (("default-colors" . "white-on-black")
                           ("colors" . (("black" . "#000000")
                                        ("red" . "#cc0000")
                                        ("green" . "#4e9a06")
                                        ("yellow" . "#c4a000")
                                        ("blue" . "#3465a4")
                                        ("magenta" . "#75507b")
                                        ("cyan" . "#06989a")
                                        ("white" . "#d3d7cf")
                                        ("bright-black" . "#555753")
                                        ("bright-red" . "#ef2929")
                                        ("bright-green" . "#8ae234")
                                        ("bright-yellow" . "#fce94f")
                                        ("bright-blue" . "#729fcf")
                                        ("bright-magenta" . "#ad7fa8")
                                        ("bright-cyan" . "#34e2e2")
                                        ("bright-white" . "#eeeeec")))))
    ("terminator-rxvt" . (("default-colors" . "white-on-black")
                          ("colors" . (("black" . "#000000")
                                       ("red" . "#cd0000")
                                       ("green" . "#00cd00")
                                       ("yellow" . "#cdcd00")
                                       ("blue" . "#0000cd")
                                       ("magenta" . "#cd00cd")
                                       ("cyan" . "#00cdcd")
                                       ("white" . "#faebd7")
                                       ("bright-black" . "#404040")
                                       ("bright-red" . "#ff0000")
                                       ("bright-green" . "#00ff00")
                                       ("bright-yellow" . "#ffff00")
                                       ("bright-blue" . "#0000ff")
                                       ("bright-magenta" . "#ff00ff")
                                       ("bright-cyan" . "#00ffff")
                                       ("bright-white" . "#ffffff")))))
    ("terminator-ambience" . (("default-colors" . "terminator-ambience")
                              ("colors" . (("black" . "#2e3436")
                                           ("red" . "#cc0000")
                                           ("green" . "#4e9a06")
                                           ("yellow" . "#c4a000")
                                           ("blue" . "#3465a4")
                                           ("magenta" . "#75507b")
                                           ("cyan" . "#06989a")
                                           ("white" . "#d3d7cf")
                                           ("bright-black" . "#555753")
                                           ("bright-red" . "#ef2929")
                                           ("bright-green" . "#8ae234")
                                           ("bright-yellow" . "#fce94f")
                                           ("bright-blue" . "#729fcf")
                                           ("bright-magenta" . "#ad7fa8")
                                           ("bright-cyan" . "#34e2e2")
                                           ("bright-white" . "#eeeeec")))))
    ("terminator-solarized" . (("default-colors" . "terminator-solarized-dark")
                               ("colors" . (("black" . "#073642")
                                            ("red" . "#dc322f")
                                            ("green" . "#859900")
                                            ("yellow" . "#b58900")
                                            ("blue" . "#268bd2")
                                            ("magenta" . "#d33682")
                                            ("cyan" . "#2aa198")
                                            ("white" . "#eee8d5")
                                            ("bright-black" . "#002b36")
                                            ("bright-red" . "#cb4b16")
                                            ("bright-green" . "#586e75")
                                            ("bright-yellow" . "#657b83")
                                            ("bright-blue" . "#839496")
                                            ("bright-magenta" . "#6c71c4")
                                            ("bright-cyan" . "#93a1a1")
                                            ("bright-white" . "#fdf6e3")))))
    ("terminator-gruvbox-light" . (("default-colors" . "terminator-gruvbox-light")
                                   ("colors" . (("black" . "#fbf1c7")
                                                ("red" . "#cc241d")
                                                ("green" . "#98971a")
                                                ("yellow" . "#d79921")
                                                ("blue" . "#458588")
                                                ("magenta" . "#b16286")
                                                ("cyan" . "#689d6a")
                                                ("white" . "#7c6f64")
                                                ("bright-black" . "#928374")
                                                ("bright-red" . "#9d0006")
                                                ("bright-green" . "#79740e")
                                                ("bright-yellow" . "#b57614")
                                                ("bright-blue" . "#076678")
                                                ("bright-magenta" . "#8f3f71")
                                                ("bright-cyan" . "#427b58")
                                                ("bright-white" . "#3c3836")))))
    ("terminator-gruvbox-dark" . (("default-colors" . "terminator-gruvbox-dark")
                                  ("colors" . (("black" . "#282828")
                                               ("red" . "#cc241d")
                                               ("green" . "#98971a")
                                               ("yellow" . "#d79921")
                                               ("blue" . "#458588")
                                               ("magenta" . "#b16286")
                                               ("cyan" . "#689d6a")
                                               ("white" . "#a89984")
                                               ("bright-black" . "#928374")
                                               ("bright-red" . "#fb4934")
                                               ("bright-green" . "#b8bb26")
                                               ("bright-yellow" . "#fabd2f")
                                               ("bright-blue" . "#83a598")
                                               ("bright-magenta" . "#d3869b")
                                               ("bright-cyan" . "#8ec07c")
                                               ("bright-white" . "#ebdbb2"))))))
  "Colors for different terminal themes.")

;;; Faces

(defface terminal-colors-term-color-black
  '((t :inherit ansi-color-black))
  "Face used to render black color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-red
  '((t :inherit ansi-color-red))
  "Face used to render red color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-green
  '((t :inherit ansi-color-green))
  "Face used to render green color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-yellow
  '((t :inherit ansi-color-yellow))
  "Face used to render yellow color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-blue
  '((t :inherit ansi-color-blue))
  "Face used to render blue color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-magenta
  '((t :inherit ansi-color-magenta))
  "Face used to render magenta color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-cyan
  '((t :inherit ansi-color-cyan))
  "Face used to render cyan color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-white
  '((t :inherit ansi-color-white))
  "Face used to render white color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-black
  '((t :inherit ansi-color-bright-black))
  "Face used to render bright black color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-red
  '((t :inherit ansi-color-bright-red))
  "Face used to render bright red color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-green
  '((t :inherit ansi-color-bright-green))
  "Face used to render bright green color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-yellow
  '((t :inherit ansi-color-bright-yellow))
  "Face used to render bright yellow color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-blue
  '((t :inherit ansi-color-bright-blue))
  "Face used to render bright blue color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-magenta
  '((t :inherit ansi-color-bright-magenta))
  "Face used to render bright magenta color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-cyan
  '((t :inherit ansi-color-bright-cyan))
  "Face used to render bright cyan color code."
  :group 'terminal-colors
  :version "28.1")

(defface terminal-colors-term-color-bright-white
  '((t :inherit ansi-color-bright-white))
  "Face used to render bright white color code."
  :group 'terminal-colors
  :version "28.1")

;;; Functions

(defun terminal-colors--apply ()
  "Update the Terminal Themes faces."
  (set-face-attribute 'terminal-colors-term-color-black nil
                      :foreground terminal-colors--color-black
                      :background terminal-colors--color-black)

  (set-face-attribute 'terminal-colors-term-color-red nil
                      :foreground terminal-colors--color-red
                      :background terminal-colors--color-red)

  (set-face-attribute 'terminal-colors-term-color-green nil
                      :foreground terminal-colors--color-green
                      :background terminal-colors--color-green)

  (set-face-attribute 'terminal-colors-term-color-yellow nil
                      :foreground terminal-colors--color-yellow
                      :background terminal-colors--color-yellow)

  (set-face-attribute 'terminal-colors-term-color-blue nil
                      :foreground terminal-colors--color-blue
                      :background terminal-colors--color-blue)

  (set-face-attribute 'terminal-colors-term-color-magenta nil
                      :foreground terminal-colors--color-magenta
                      :background terminal-colors--color-magenta)

  (set-face-attribute 'terminal-colors-term-color-cyan nil
                      :foreground terminal-colors--color-cyan
                      :background terminal-colors--color-cyan)

  (set-face-attribute 'terminal-colors-term-color-white nil
                      :foreground terminal-colors--color-white
                      :background terminal-colors--color-white)

  (set-face-attribute 'terminal-colors-term-color-bright-black nil
                      :foreground terminal-colors--color-bright-black
                      :background terminal-colors--color-bright-black)

  (set-face-attribute 'terminal-colors-term-color-bright-red nil
                      :foreground terminal-colors--color-bright-red
                      :background terminal-colors--color-bright-red)

  (set-face-attribute 'terminal-colors-term-color-bright-green nil
                      :foreground terminal-colors--color-bright-green
                      :background terminal-colors--color-bright-green)

  (set-face-attribute 'terminal-colors-term-color-bright-yellow nil
                      :foreground terminal-colors--color-bright-yellow
                      :background terminal-colors--color-bright-yellow)

  (set-face-attribute 'terminal-colors-term-color-bright-blue nil
                      :foreground terminal-colors--color-bright-blue
                      :background terminal-colors--color-bright-blue)

  (set-face-attribute 'terminal-colors-term-color-bright-magenta nil
                      :foreground terminal-colors--color-bright-magenta
                      :background terminal-colors--color-bright-magenta)

  (set-face-attribute 'terminal-colors-term-color-bright-cyan nil
                      :foreground terminal-colors--color-bright-cyan
                      :background terminal-colors--color-bright-cyan)

  (set-face-attribute 'terminal-colors-term-color-bright-white nil
                      :foreground terminal-colors--color-bright-white
                      :background terminal-colors--color-bright-white))

(defun terminal-colors--reset ()
  "Reset colors to their default values."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when terminal-colors--remap-cookies
        (mapc #'face-remap-remove-relative terminal-colors--remap-cookies)
        (setq terminal-colors--remap-cookies nil))))
  (run-hooks 'terminal-colors--reset-hook))

(defun terminal-colors--load-default-default-fg-bg (default-fg-bg)
  "Load default terminal background, foreground, and cursor color.
DEFAULT-FG-BG is the name of an item in
`terminal-colors-default-foreground-background'."
  (let ((colors (cdr (assoc default-fg-bg
                            terminal-colors-default-foreground-background))))
    (unless colors
      (error "No colors found for %s" default-fg-bg))
    (let ((fg (cdr (assoc "foreground" colors)))
          (bg (cdr (assoc "background" colors)))
          (cursor (cdr (assoc "cursor" colors))))
      (unless fg
        (error "Foreground color not defined for %s" default-fg-bg))
      (unless bg
        (error "Background color not defined for %s" default-fg-bg))
      (setq terminal-colors--foreground fg)
      (setq terminal-colors--background bg)
      (setq terminal-colors--cursor (or cursor fg)))))

(defun terminal-colors--set-foreground-background (&rest _)
  "Update the buffer's background, foreground, and fringe colors."
  (when terminal-colors--remap-cookies
    (mapc #'face-remap-remove-relative terminal-colors--remap-cookies)
    (setq terminal-colors--remap-cookies nil))
  (push (face-remap-add-relative 'default
                                 :foreground terminal-colors--foreground
                                 :background terminal-colors--background)
        terminal-colors--remap-cookies)
  (push (face-remap-add-relative 'fringe
                                 :foreground terminal-colors--foreground
                                 :background terminal-colors--background)
        terminal-colors--remap-cookies)
  ;; TODO Fix this. It doesn't work.
  ;; (push (face-remap-add-relative 'cursor
  ;;                                :background terminal-colors--cursor
  ;;                                :foreground terminal-colors--background)
  ;;       terminal-colors--remap-cookies)
  )

(defun terminal-colors--update-all-buffers ()
  "Apply the buffer-local face remappings to all existing terminal buffers."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (or (and (derived-mode-p 'vterm-mode)
                     (bound-and-true-p terminal-colors-vterm-mode))
                (and (derived-mode-p 'term-mode)
                     (bound-and-true-p terminal-colors-term-mode))
                (and (derived-mode-p 'eat-mode)
                     (bound-and-true-p terminal-colors-eat-mode)))
        (terminal-colors--set-foreground-background)))))

(defvar terminal-colors--init-p nil
  "Non-nil when init is done.")

(defun terminal-colors--reload-theme (&rest _)
  "Reload the terminal theme."
  (terminal-colors-load (or terminal-colors--current-theme-name
                            terminal-colors-default-theme)))

(defun terminal-colors--init ()
  "Init terminal themes."
  (if terminal-colors--init-p
      (run-hooks 'terminal-colors--after-load-hook)
    (advice-add 'load-theme :after #'terminal-colors--reload-theme)
    (setq terminal-colors--init-p t)
    (terminal-colors--reload-theme)))

(defun terminal-colors-get-all-theme-names ()
  "Return a list of all available theme names."
  (mapcar #'car terminal-colors-colors))

(defun terminal-colors-load (&optional theme)
  "Load terminal theme by THEME, applying color and default settings."
  (interactive (list (completing-read "Select theme: "
                                      (mapcar #'car terminal-colors-colors)
                                      nil t)))
  (unless theme
    (setq theme terminal-colors-default-theme))
  (let* ((theme-data (cdr (assoc theme terminal-colors-colors)))
         (default-colors (cdr (assoc "default-colors" theme-data)))
         (color-alist (cdr (assoc "colors" theme-data))))
    (unless color-alist
      (error "The terminal theme %s was not found" theme))
    (unless default-colors
      (error "The terminal theme default fg and bg %s was not found"
             theme))
    (when default-colors
      (terminal-colors--load-default-default-fg-bg default-colors))
    (mapc (lambda (color-pair)
            (let ((color-name (car color-pair))
                  (color-value (cdr color-pair)))
              (set (intern (format "terminal-colors--color-%s" color-name))
                   color-value)))  ; Set the dynamic color variable
          color-alist)
    (run-hooks 'terminal-colors--before-load-hook)
    (terminal-colors--apply)
    (terminal-colors--update-all-buffers)
    (setq terminal-colors--current-theme-name theme)
    (when (called-interactively-p 'interactive)
      (message "Theme '%s' loaded with default colors %s."
               theme default-colors))
    (run-hooks 'terminal-colors--after-load-hook)))

(provide 'terminal-colors)

;; Local variables:
;; byte-compile-warnings: (not free-vars)
;; End:

;;; terminal-colors.el ends here
