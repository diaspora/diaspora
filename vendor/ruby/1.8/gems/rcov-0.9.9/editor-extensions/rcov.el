;;; rcov.el -- Ruby Coverage Analysis Tool

;;; Copyright (c) 2006 rubikitch <rubikitch@ruby-lang.org>
;;;
;;; Use and distribution subject to the terms of the rcov license.

(defvar rcov-xref-before-visit-source-hook nil
  "Hook executed before jump.")
(defvar rcov-xref-after-visit-source-hook nil
  "Hook executed after jump.")
(defvar rcov-command-line "rake rcov RCOVOPTS='--gcc --no-html'"
  "Rcov command line to find uncovered code.
It is good to use rcov with Rake because it `cd's appropriate directory.
`--gcc' option is strongly recommended because `rcov' uses compilation-mode.")
(defvar rcovsave-command-line "rake rcov RCOVOPTS='--gcc --no-html --save=coverage.info'"
  "Rcov command line to save coverage status. See also `rcov-command-line'.")
(defvar rcovdiff-command-line "rake rcov RCOVOPTS='-D --gcc --no-html'"
  "Rcov command line to find new uncovered code. See also `rcov-command-line'.")

;;;; rcov-xref-mode
(define-derived-mode rcov-xref-mode ruby-mode "Rxref"
  "Major mode for annotated Ruby scripts (coverage/*.rb) by rcov."
  (setq truncate-lines t)
  ;; ruby-electric-mode / pabbrev-mode hijacks TAB binding.
  (and ruby-electric-mode (ruby-electric-mode -1))
  (and (boundp 'pabbrev-mode) pabbrev-mode (pabbrev-mode -1))
  (suppress-keymap rcov-xref-mode-map)
  (define-key rcov-xref-mode-map "\C-i" 'rcov-xref-next-tag)
  (define-key rcov-xref-mode-map "\M-\C-i" 'rcov-xref-previous-tag)
  (define-key rcov-xref-mode-map "\C-m" 'rcov-xref-visit-source)
  (set (make-local-variable 'automatic-hscrolling) nil)
  )
  
(defvar rcov-xref-tag-regexp "\\[\\[\\(.*?\\)\\]\\]")

(defun rcov-xref-next-tag (n)
  "Go to next LINK."
  (interactive "p")
  (when (looking-at rcov-xref-tag-regexp)
    (goto-char (match-end 0)))
  (when (re-search-forward rcov-xref-tag-regexp nil t n)
    (goto-char (match-beginning 0)))
  (rcov-xref-show-link))

(defun rcov-xref-previous-tag (n)
  "Go to previous LINK."
  (interactive "p")
  (re-search-backward rcov-xref-tag-regexp nil t n)
  (rcov-xref-show-link))

(defvar rcov-xref-link-tempbuffer " *rcov-link*")
(defun rcov-xref-show-link ()
  "Follow current LINK."
  (let ((link (match-string 1))
        (eol (point-at-eol)))
    (save-excursion
      (when (and link
                 (re-search-backward "# \\(>>\\|<<\\) " (point-at-bol) t))
        (while (re-search-forward rcov-xref-tag-regexp eol t)
          (let ((matched (match-string 1)))
            (when (string= link matched)
              (add-text-properties 0 (length matched) '(face highlight) matched))
            (with-current-buffer (get-buffer-create rcov-xref-link-tempbuffer)
              (insert matched "\n"))))
        (let (message-log-max)          ; inhibit *Messages*
          (message "%s" (with-current-buffer rcov-xref-link-tempbuffer
                          (substring (buffer-string) 0 -1)))) ; chomp
        (kill-buffer rcov-xref-link-tempbuffer)))))


;; copied from jw-visit-source
(defun rcov-xref-extract-file-lines (line)
  "Extract a list of file/line pairs from the given line of text."
  (let*
      ((unix_fn "[^ \t\n\r\"'([<{]+")
       (dos_fn  "[a-zA-Z]:[^ \t\n\r\"'([<{]+")
       (flre (concat "\\(" unix_fn "\\|" dos_fn "\\):\\([0-9]+\\)"))
       (start nil)
       (result nil))
    (while (string-match flre line start)
      (setq start (match-end 0))
      (setq result
            (cons (list
                   (substring line (match-beginning 1) (match-end 1))
                   (string-to-int (substring line (match-beginning 2) (match-end 2))))
                  result)))
    result))

(defun rcov-xref-select-file-line (candidates)
  "Select a file/line candidate that references an existing file."
  (cond ((null candidates) nil)
        ((file-readable-p (caar candidates)) (car candidates))
        (t (rcov-xref-select-file-line (cdr candidates))) ))

(defun rcov-xref-visit-source ()
  "If the current line contains text like '../src/program.rb:34', visit
  that file in the other window and position point on that line."
  (interactive)
  (let* ((line (progn (looking-at rcov-xref-tag-regexp) (match-string 1)))
         (candidates (rcov-xref-extract-file-lines line))
         (file-line (rcov-xref-select-file-line candidates)))
    (cond (file-line
           (run-hooks 'rcov-xref-before-visit-source-hook)
           (find-file (car file-line))
           (goto-line (cadr file-line))
           (run-hooks 'rcov-xref-after-visit-source-hook))
          (t
           (error "No source location on line.")) )))

;;;; Running rcov with various options.
(defun rcov-internal (cmdline)
  "Run rcov with various options."
  (compile-internal cmdline ""
                    nil nil nil (lambda (x) "*rcov*")))

(defun rcov ()
  "Run rcov to find uncovered code."
  (interactive)
  (rcov-internal rcov-command-line))

(defun rcovsave ()
  "Run rcov to save coverage status."
  (interactive)
  (rcov-internal rcovsave-command-line))

(defun rcovdiff ()
  "Run rcov to find new uncovered code."
  (interactive)
  (rcov-internal rcovdiff-command-line))

(provide 'rcov)
