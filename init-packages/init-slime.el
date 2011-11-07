(setq inferior-lisp-program "sbcl")
(setq inferior-lisp-program "~/.emacs.d/ibcl")
(require 'slime)
(slime-setup '(slime-fancy slime-asdf))

(define-key (eval 'slime-mode-map) (kbd "C-c c") (lambda (&optional arg)
     "Copy/past the previous sexp to the slime buffer"
     (interactive "p")
     (kmacro-exec-ring-item (quote
			     ([67108896 134217730 134217847 24 111 25 return 24 111 134217734 134217734] 0 "%d")) arg)))


(defun build-slide ()
  (interactive)
  (with-current-buffer (current-buffer)
    (save-excursion
      (re-search-backward "^(slide")
      (mark-sexp)
      (kill-ring-save (region-beginning) (region-end))
      (with-temp-file "one-slide.tmp"
	(yank))
      (with-temp-file "compile.tmp"
	(insert "(load \"dslides.lisp\")(load \"one-slide.tmp\")(deck-real-output)"))
      (if (file-exists-p "slides-output.tex")
	  (delete-file  "slides-output.tex" nil))
      (call-process (expand-file-name "~/.emacs.d/ibcl")
		    "compile.tmp" "*Messages*" nil)
      (call-process "pdflatex" nil "*Messages*" nil "clos.tex"))))

(defun show-slide ()
  (interactive)
  (build-slide)
  (let ((directory (file-name-directory (buffer-file-name))))
    (other-window 1)
    (let ((revert-without-query '("clos\.pdf")))
      (find-file (expand-file-name (concat directory "clos.pdf"))))
    (doc-view-revert-buffer t t)
    (doc-view-fit-page-to-window)
    (doc-view-first-page)))

(define-key (eval 'slime-mode-map) (kbd "C-c v") #'show-slide)
