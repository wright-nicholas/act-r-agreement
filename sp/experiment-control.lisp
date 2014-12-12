;;;  -*- mode: LISP; Syntax: COMMON-LISP;  Base: 10 -*-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; ACT-R Sentence Parsing Model
;;;      
;;; Copyright (C) 2006 Shravan Vasishth, Rick Lewis
;;; 
;;; Extended by Felix Engelmann 2012/2013 to work with the EMMA eye 
;;; movement model in ACT-R 6
;;;
;;; Includes the ACT-R Sentence Parsing Model processing
;;; German negative and positive polarity items as described in the
;;; Cognitive Science article Vasishth, Bruessow & Lewis (2007).
;;; 
;;; The original English model is described in the Cognitive Science
;;; article Lewis & Vasishth (2004). 
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; Filename    : 
;;; 
;;; Bugs        : 
;;;
;;; To do       : 
;;;             : [x] collect traces and write later
;;; 
;;; ----- History -----
;;; 
;;;             : * 
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(defun run-paramset-em (name &optional (iterations 1) (params nil))
  (suppress-warnings (reload))
  ; (when (null params)
  ;   (setf params '(:v nil)))
  ; (delete-output)
  (if (numberp *paramset*)
      (setf *paramset* (1+ *paramset*))
      (setf *paramset* 1))
  ;; clean-up procedure to prevent process from slowing down 
  (suppress-warnings (reload))
  (when (= (rem *paramset* 10) 0)
    (sleep 60))
  (let* ((location (concatenate 'string *output-dir* "/../paramsearch/" (string *experiment*) "/"))
         (fixfile (concatenate 'string location (write-to-string *paramset*) "-fixations.txt"))
         (trialmfile (concatenate 'string location (write-to-string *paramset*) "-trialmessages.txt"))
         (successes 0))
    ;(setf *experiment* name)
    (setf *simulation* 0)
    (setf *traces* nil)
    (setf *fixation-data* nil)
    (setf *attachment-data* nil)
    (setf *encoding-data* nil)
    (setf *timeout-data* nil)
    (setf *trialmessage-data* nil)

  (with-open-file (infofile (ensure-directories-exist (concatenate 'string location "paramsearch.txt")) :direction :output :if-exists :append :if-does-not-exist :create)
                  (format infofile "~A ~A ~A \"~A\"~%" (string name) *paramset* fixfile params))
  (sgp :cmdt t)
  (with-open-file (*standard-output* (ensure-directories-exist (concatenate 'string location "params.txt")) :direction :output :if-exists :rename :if-does-not-exist :create)
                  (print-params))
  (sgp :cmdt nil)
  
  (setf params (append '(:randomize-time t :ncnar nil :dcnn nil :SAVE-P-HISTORY nil :SAVE-BUFFER-HISTORY nil) params))
  (format t "~%_________________________________~%Run paramset: ~A, ~A~%" *paramset* params)
  (dotimes (j iterations)
    (setf *simulation* (1+ j))
    (format t "Iteration ~A~%" (1+ j))
    (let ((exp-trace nil))
      (if (null *read-corpus*)
            (setf exp-trace (run-experiment-em-fct name params))
            (setf exp-trace (run-experiment-em-corpus-fct *sentences* params)))
      (when exp-trace
        (setf successes (+ successes 1))
        (if (null *read-corpus*)
            (push-last (list name params exp-trace) *exp-traces*)))))
  (write-table *fixation-data* fixfile)
  (write-table *trialmessage-data* trialmfile)
  ; (write-table *attachment-data*)
  ; (write-table *encoding-data*)
  ; (write-table *timeout-data*)
  ))


(defun run-paramset-subjects-em (name &optional (iterations 1) (subjects 1) (location *output-dir*) (ga nil) (params nil) (script nil) (notes nil))
  (reload-sp)
  (set-estimating)
  (setprint off)
  ; (when (null params)
  ;   (setf params '(:v nil)))
  ; (delete-output)
  (if (numberp *paramset*)
      (setf *paramset* (1+ *paramset*))
      (setf *paramset* 1))
  ;(setf *RUNTIME-START* (get-internal-real-time))
  ;; clean-up procedure to prevent process from slowing down 
  ; (suppress-warnings (reload))
  (when (= (rem *paramset* 10) 0)
    (format t "~%Pausing...")
    (sleep 30))
  (let* (;(location (concatenate 'string *output-dir* "/../paramsearch/" (string *experiment*) "/"))
         (fixfile (concatenate 'string location (write-to-string *paramset*) "-fixations.txt"))
         (subjfile (concatenate 'string location (write-to-string *paramset*) "-subjects.txt"))
         (trialmfile (concatenate 'string location (write-to-string *paramset*) "-trialmessages.txt"))
         (successes 0)
         (subject 0)
         ; (params (append '(:v nil :dcnn nil) params))
         (params1 nil)
         (goal-act 1)
         (start-time (get-internal-real-time))
         (mytime nil))

    ;(setf *experiment* name)
    (setf *simulation* 0)
    (setf *traces* nil)
    (setf *fixation-data* nil)
    (setf *attachment-data* nil)
    (setf *encoding-data* nil)
    (setf *timeout-data* nil)
    (setf *trialmessage-data* nil)

  (with-open-file (infofile (ensure-directories-exist (concatenate 'string location "paramsearch.txt")) :direction :output :if-exists :append :if-does-not-exist :create)
                  (format infofile "~A ~A ~A \"~A\"~%" (string name) *paramset* fixfile params))
  (sgp :cmdt t)
  (with-open-file (*standard-output* (ensure-directories-exist (concatenate 'string location "params.txt")) :direction :output :if-exists :rename :if-does-not-exist :create)
                  (format t "Experiment ~A~%Subjects ~A~%Iterations ~A~%Results-script ~A~%Notes ~A~%" name subjects iterations script notes)
                  (print-params))
  (sgp :cmdt nil)
  
  ; (setf params (append '(:randomize-time t :ncnar nil :dcnn nil :SAVE-P-HISTORY nil :SAVE-BUFFER-HISTORY nil) params))
  (format t "~%================================================
RUNNING PARAMSET ~A ~A~%" *paramset* params)

  (dotimes (s subjects "ALL DONE")
        (reload-sp)
        (set-estimating)
        (setprint off)
        (setf subject (1+ s))
        (if (listp ga) (setf goal-act (nth s ga)))
        (if (not ga) (setf goal-act (1+ (* (sqrt (* -2 (log (random 1.0)))) (cos (* 2 pi (random 1.0))) 0.25)))) ;; normal with sd=0.25 (Daily, Lovett, Reder, 2011)
        ; (setf goal-act (1+ (* (sqrt (* -2 (log (random 1.0)))) (cos (* 2 pi (random 1.0))) 0.15)))  ;; normal with sd=0.15 (Daily, Lovett, Reder, 2011)
        ; (setf goal-act (* (act-r-random 100) 0.01)) ;; uniform 0 - 1
        ; (setf goal-act (rand-time 1))  ;; uniform of 1 +/- 1/3
        ; (setf goal-act (+ 1 (* (- (act-r-random 200) 100) 0.01)))  ;; 0 - 2
        (setf *experiment* (concatenate 'string (string name) "-" (write-to-string subject)))
        (with-open-file (*standard-output* (ensure-directories-exist subjfile) :direction :output :if-exists :append :if-does-not-exist :create)
                        (format t "~S ~D ~2,2F~%" *experiment* subject goal-act))
        ; (setf goal-act (- goal-act 0.3))  ;; adjust goal activation mean
          
        ; (setf *fixation-data* nil)
        ; (setf *attachment-data* nil)
        ; (setf *encoding-data* nil)
        ; (setf *timeout-data* nil)
        ; (setf *trialmessage-data* nil)
        ; (setf *exp-traces* nil)
        (setf *simulation* 0)
        (setf params1 (append (list :ga goal-act) params))
        ; (setf *paramset* params1)

        (format t "   Experiment: ~A, ~A~%   " *experiment* goal-act)
        
        (dotimes (j iterations "DONE subject")
          (setf *simulation* (1+ j))
          ; (format t "..~A" (1+ j))
          
          (let ((exp-trace nil))
            (if (null *read-corpus*)
                (setf exp-trace (run-experiment-em-fct name params1))
                (setf exp-trace (run-experiment-em-corpus-fct *sentences* params1)))
            (when exp-trace
              (setf successes (+ successes 1))
              ; (push result results)
              (push-last (list name params1 exp-trace) *exp-traces*))))
          (format t "~%"))
      (write-table *fixation-data* fixfile)
      (write-table *trialmessage-data* trialmfile)
      (setf mytime (/ (- (get-internal-real-time) start-time) INTERNAL-TIME-UNITS-PER-SECOND))
      (setf *RUNTIMES* (append (list mytime) *RUNTIMES*))
      (format t "   Time needed: ~5,2F min, Mean: ~5,2F min, Range: [~5,2F ~5,2F], Total: ~5,2F~%" (/ mytime 60) (/ (mymean *RUNTIMES*) 60) (/ (reduce #'min *RUNTIMES*) 60) (/ (reduce #'max *RUNTIMES*) 60) (/ (sum *RUNTIMES*) 60))
      )) 



;;;  RUN EXPERIMENT EM
(defun re (name &optional (iterations 1) params)
  (run-experiment-em name iterations params))

(defun run-experiment-em (name &optional (iterations 1) params)
  (suppress-warnings (reload-sp))
  (when (null params)
    (setf params '(:v nil)))
  
  (if params
      (sgp-fct params))
  (print-params)
  (print-interface-params)
  (delete-output)
  
  (with-open-file (*standard-output* (ensure-directories-exist (concatenate 'string *output-dir* "/params.txt")) :direction :output :if-exists :rename :if-does-not-exist :create)
    (print-params)
    )
  
  (setprint off)
  (setf *VERBOSE* nil)
  (setf *show-window* nil)
  (setf *record-times* nil)
  (setf *trace-to-file* nil)
  (setf *real-time* nil)
  ;
  (setf *fixation-data* nil)
  (setf *attachment-data* nil)
  (setf *encoding-data* nil)
  (setf *timeout-data* nil)
  (setf *trialmessage-data* nil)
  (setf *visloc-activations-data* nil)
  (setf *exp-traces* nil)
  (setf *experiment* name)
  (setf *simulation* 0)
  (setf *correct-responses* nil)
  (setf *responses* nil)
  (setf *paramset* params)
  (setf params (append '(:v nil :dcnn nil) params))
  
  (let ((successes 0))
    (format t "~%_____________________________________________________________________
~%Experiment: ~A, ~A~%" name params)
    
    (dotimes (j iterations "DONE")
      (setf *simulation* (1+ j))
      (format t "Iteration ~A~%" (1+ j))
      
      (let ((exp-trace nil))
        (if (null *read-corpus*)
            (setf exp-trace (run-experiment-em-fct name params))
            (setf exp-trace (run-experiment-em-corpus-fct *sentences* params)))
        (when exp-trace
          (setf successes (+ successes 1))
          ; (push result results)
          (push-last (list name params exp-trace) *exp-traces*))))
    (write-headers)
    (write-data)
    (setprint on)
    (setf *VERBOSE* t)
    (setf *show-window* t)
    (setf *record-times* t)
    ))




(defun res (name &optional (iterations 2) (subjects 2) &key (ga nil) params (script "spinresults.R") notes)
  (run-subjects-em name iterations subjects ga params script notes))

(defun run-subjects-em (name &optional (iterations 2) (subjects 2) (ga nil) params (script "spinresults.R") notes)
  ; (suppress-warnings (reload))
  (when (null params)
    (setf params '(:v nil)))
  
  (if params
      (sgp-fct params))
  (print-params)
  (print-interface-params)
  (delete-output)
  
  (write-headers)
  (with-open-file (*standard-output* (ensure-directories-exist (concatenate 'string *output-dir* "/params.txt")) :direction :output :if-exists :rename :if-does-not-exist :create)
    (format t "Experiment ~A~%Subjects ~A~%Iterations ~A~%Results-script ~A~%Notes ~A~%" name subjects iterations script notes)
    (print-params)
    )
  
  (setprint off)
  (setf *VERBOSE* nil)
  (setf *show-window* nil)
  (setf *record-times* nil)
  (setf *trace-to-file* nil)
  (setf *real-time* nil)
  ;

  (let ((successes 0)
        (subject 0)
        (params1 (append '(:v nil :dcnn nil) params))
        (params nil)
        (goal-act 1)
        ; (outpath (make-pathname :name *output-dir* :defaults *default-pathname-defaults*))
        (currentpath (current-directory)))
    
    (dotimes (s subjects "ALL DONE")
        (reset-sp)
        (setf subject (1+ s))
        ; (setf goal-act (rand-time 1))  ;; uniform of 1 +/- 1/3
        ; (setf goal-act (+ 1 (* (- (act-r-random 200) 100) 0.01)))  ;; 0 - 2
        (if (listp ga) (setf goal-act (nth s ga)))
        (if (not ga) (setf goal-act (1+ (* (sqrt (* -2 (log (random 1.0)))) (cos (* 2 pi (random 1.0))) 0.25)))) ;; normal with sd=0.25 (Daily, Lovett, Reder, 2011)

        ; (setf goal-act (1+ (* (sqrt (* -2 (log (random 1.0)))) (cos (* 2 pi (random 1.0))) 0.15)))  ;; normal with sd=0.15 (Daily, Lovett, Reder, 2011)
        ; (setf goal-act (* (act-r-random 100) 0.01)) ;; uniform 0 - 1
        (setf *subject* subject)
        (setf *experiment* (concatenate 'string (string name) "-" (write-to-string subject)))
        (with-open-file (*standard-output* (ensure-directories-exist (concatenate 'string *output-dir* "/subjects.txt")) :direction :output :if-exists :append :if-does-not-exist :create)
                        (format t "~S ~D ~2,2F~%" *experiment* subject goal-act))
        ; (setf goal-act (- goal-act 0.3))  ;; adjust goal activation mean
          
        ;; TODO: combine in a reset-data-collectors function
        (setf *fixation-data* nil)
        (setf *attachment-data* nil)
        (setf *encoding-data* nil)
        (setf *timeout-data* nil)
        (setf *trialmessage-data* nil)
        (setf *visloc-activations-data* nil)
        (setf *exp-traces* nil)
        (setf *simulation* 0)
        (setf *correct-responses* nil)
        (setf *responses* nil)
        (setf params (append (list :ga goal-act) params1))
        (setf *paramset* params)
        

        (format t "~%_____________________________________________________________________
    ~%Experiment: ~A, ~A" *experiment* params)
        
        (dotimes (j iterations "DONE subject")
          (setf *simulation* (1+ j))
          (format t "~%Iteration ~A" (1+ j))
          
          (let ((exp-trace nil))
            (if (null *read-corpus*)
                (setf exp-trace (run-experiment-em-fct name params))
                (setf exp-trace (run-experiment-em-corpus-fct *sentences* params)))
            (when exp-trace
              (setf successes (+ successes 1))
              ; (push result results)
              (push-last (list name params exp-trace) *exp-traces*))))
      (write-data)
    )
    (setprint on)
    (setf *VERBOSE* t)
    (setf *show-window* t)
    (setf *record-times* t)
    
    ; (cwd outpath)
    (cwd *output-dir*)
    (run-program "Rscript" (list script) :output *standard-output*)
    (cwd currentpath)
    )
 )



(defun write-headers nil
  (table-header "experiment simulation item wn word fixdur" *fixations-file*)
  (table-header "experiment simulation item wn word attachtime" *attachments-file*)
  (table-header "experiment simulation item wn word enctime ecc freq1" *encodings-file*)
  (table-header "experiment simulation item wn word timeout.eyeloc" *timeouts-file*)
  )

(defun write-data nil
  (write-table *fixation-data* *fixations-file*)
  (write-table *attachment-data* *attachments-file*)
  (write-table *encoding-data* *encodings-file*)
  (write-table *timeout-data* *timeouts-file*)
  (write-table *trialmessage-data* *trialmessages-file*)
  (when *record-visloc-activations*
    (write-table *visloc-activations-data* *visloc-activations-file*))
  )

(defun write-data-old nil
  (write-fixations-table *fixation-data*)
  (write-attachments-table *attachment-data*)
  (write-encodings-table *encoding-data*)
  (write-timeouts-table *timeout-data*)
  (write-trialmessage-table *trialmessage-data*)
  )


(defun run-experiment-em-fct (name params)
  (setf *item* 0)
  (let ((conditions (first (get '*experiments* name)))
        (exp-trace nil))
    ;; Loop over conditions....
    (dolist (c conditions)
      (let* ((cname (pop c))
             (sent (eval (pop c)))
             ;(regions c)
             (success nil)
             )
        (setf *item* cname)
        ;;; --------------------------------------------------------- ;;;
        (setf success (present-whole-sentence sent *max-time* params t))
        ;;; --------------------------------------------------------- ;;;
        (when (null success)
          (format t "(F:~s)" cname)
          (trialmessage "fail" "T")
          ; (return nil)
          )
        (push-last (list cname *fixation-trace*) exp-trace)
        ;; store fixations
        ;; (pos fixtime)
        (setf *fixation-data* (append *fixation-data* (fixations-table *fixation-trace*)))
        ; (dolist (fix *fixation-trace*)
        ;   (if (>= (first fix) 0)
        ;   (push-last (list *experiment* *simulation* *item* (1+ (first fix)) 
        ;                    (format nil "~a" (word-name (nth (first fix) *sentence-plist*))) (second fix)) 
        ;              *fixation-data*)))
        ;; store encoding times
        ;; (pos word enctime eccentricity freq)
        (setf *encoding-data* (append *encoding-data* (encodings-table *encoded-items*)))
        ; (dolist (x *encoded-items*)
        ;   (push-last (list *experiment* *simulation* *item* (1+ (first x))
        ;                    (second x) (third x) (fourth x) (fifth x))
        ;              *encoding-data*))
        ;; store attachment times
        ;; (pos word time)
        (setf *attachment-data* (append *attachment-data* (attachments-table *attached-items*)))
        ; (dolist (x *attached-items*)
        ;   (push-last (list *experiment* *simulation* *item* (1+ (first x))
        ;                    (second x) (third x))
        ;              *attachment-data*))
        ;; store time-outs
        ;; (cause-pos wordname eye-pos)
        (setf *timeout-data* (append *timeout-data* (timeouts-table *timeout-items*)))
        ; (dolist (x *timeout-items*)
        ;   (push-last (list *experiment* *simulation* *item* (1+ (first x))
        ;                    (second x) (1+ (third x)))
        ;              *timeout-data*))
        ;; store trialmessages
        (setf *trialmessage-data* (append *trialmessage-data* *trialmessages*))
        ; (dolist (x *trialmessages*)
        ;   (push-last x *trialmessage-data*))
        (when *record-visloc-activations*
          (setf *visloc-activations-data* (append *visloc-activations-data* (table *visloc-activations*))))
        ))
    exp-trace
    ))









(defun run-experiment-em-corpus-fct (&optional (set *sentences*) (params nil))
  (setf *item* 0)
  (let ((exp-trace nil))
    ;; Loop over conditions....
    (dolist (sent set)
      (let* ((success nil)
             )
        (incf *item*)
        ;;; --------------------------------------------------------- ;;;
        (setf success (present-whole-sentence sent *max-time* params))
        ;;; --------------------------------------------------------- ;;;
        (when (null success)
          (format t "~%   .....FAILURE.....~%")
          (return nil))
        (push-last (list *item* *fixation-trace*) exp-trace)
        ;; store fixations
        ;; (pos fixtime)
        (dolist (fix *fixation-trace*)
          (if (>= (first fix) 0)
          (push-last (list *experiment* *simulation* *item* (1+ (first fix)) 
                           (format nil "~a" (word-name (nth (first fix) *sentence-plist*))) (second fix)) 
                     *fixation-data*)))
        ; ;; store encoding times
        ; ;; (pos word enctime eccentricity freq)
        ; (dolist (x *encoded-items*)
        ;   (push-last (list *experiment* *simulation* *item* (1+ (first x))
        ;                    (second x) (third x) (fourth x) (fifth x))
        ;              *encoding-data*))
        ; ;; store attachment times
        ; ;; (pos word time)
        ; (dolist (x *attached-items*)
        ;   (push-last (list *experiment* *simulation* *item* (1+ (first x))
        ;                    (second x) (third x))
        ;              *attachment-data*))
        ; ;; store time-outs
        ; ;; (cause-pos wordname eye-pos)
        ; (dolist (x *timeout-items*)
        ;   (push-last (list *experiment* *simulation* *item* (1+ (first x))
        ;                    (second x) (1+ (third x)))
        ;              *timeout-data*))
        ))
    exp-trace
    ))


;; BUG: Defining a pspace and then running the function does not work;
;;   It always uses pre-compiled *pspace1*. 
;; It works, however when the file with the function call is compiled after defining
;;   the new pspace.
(defmacro search-param-space-em (experiment iterations &optional (pspace '*pspace1*))
  (suppress-warnings (reload-sp))
  (print-params)
  (print-interface-params)
  (setprint off)
  (setf *VERBOSE* nil)
  (setf *show-window* nil)
  (setf *record-times* nil)
  (setf *trace-to-file* nil)
  (setf *real-time* nil)
  (setf *exp-traces* nil)
  (setf *simulation* 0)
  (setf *paramset* 0)
  (setf *correct-responses* nil)
  (setf *responses* nil)
  (setf *experiment-results* nil)
  (setf *experiment* (concatenate 'string (string experiment) "-" (datetimestamp)))
  (delete-output)

  (let ((code `(run-paramset-em ',experiment ,iterations))
  (param-vars nil)
; (parameters '(list :v nil)))
  ;(parameters '(list :ans nil :randomize-time nil)))
  (parameters '(list )))

    (dolist (p (eval pspace))
      (let ((new-var (gensym))
      (parameter (first p)))
  (push (cons parameter new-var) param-vars)
  (push-last parameter parameters)
  (push-last new-var parameters)))
        
    (push-last parameters code)
    
    (dolist (p (eval pspace))
      (let* ((new-var (cdr (assoc (first p) param-vars)))
       (init-val (second p))
       (final-val (third p))
       (step-val (fourth p))
       (do-code `(do ((,new-var ,init-val (+ ,new-var
               ,step-val)))
         ((> ,new-var ,final-val)))))
  (setf code (push-last code do-code))
  ))
    ; code)
    `(progn 
       ,code
       (setprint on)
       (setf *VERBOSE* t)
       (setf *show-window* t)
       (setf *record-times* t)
       "FINISHED"))
)



(defun set-estimating ()
  (setf *VERBOSE* nil)
  (setf *show-window* nil)
  (setf *record-times* nil)
  (setf *trace-to-file* nil)
  (setf *real-time* nil)
  )

(defun set-estimating-off ()
  (setf *VERBOSE* t)
  (setf *show-window* t)
  (setf *record-times* t)
  (setf *trace-to-file* t)
  )


(defmacro search-param-space-subjects-em (experiment iterations &optional (subjects 1) (pspace '*pspace1*) &key (ga nil) (parameters '(list )))
  ; (format t "~a" parameters)
  (suppress-warnings (reload-sp))
  (if (> (length (cdr parameters)) 0) (setf *params* (cdr parameters)))
  (reset-sp)
  (setf *VERBOSE* nil)
  (setf *show-window* nil)
  (setf *record-times* nil)
  (setf *trace-to-file* nil)
  (setf *real-time* nil)
  (setf *exp-traces* nil)
  (setf *simulation* 0)
  (setf *paramset* 0)
  (setf *RUNTIMES* nil)
  (setf *correct-responses* nil)
  (setf *responses* nil)
  (setf *experiment-results* nil)
  (print-params)
  (setprint off)
  (print-interface-params)
  ; (setf *experiment* (concatenate 'string (string experiment) "-" (datetimestamp)))
  
  ; (delete-output)

  (let* ((location (concatenate 'string *output-dir* "/../paramsearch/" (string experiment) "-" (datetimestamp) "/"))
        (code `(run-paramset-subjects-em ',experiment ,iterations ,subjects ,location ,ga))
        (param-vars nil)
      ; (parameters '(list :v nil)))
      ; (parameters '(list :ans nil :randomize-time nil)))
        ; (parameters '(list ))
        )

    (dolist (p (eval pspace))
      (let ((new-var (gensym))
      (parameter (first p)))
  (push (cons parameter new-var) param-vars)
  (push-last parameter parameters)
  (push-last new-var parameters)))
        
    (push-last parameters code)
    
    (dolist (p (eval pspace))
      (let* ((new-var (cdr (assoc (first p) param-vars)))
       (init-val (second p))
       (final-val (third p))
       (step-val (fourth p))
       (do-code `(do ((,new-var ,init-val (+ ,new-var
               ,step-val)))
         ((> ,new-var ,final-val)))))
  (setf code (push-last code do-code))
  ))
    ; code)
    `(progn 
       ,code
       (setprint on)
       (setf *VERBOSE* t)
       (setf *show-window* t)
       (setf *record-times* t)
       (format t "~%FINISHED ~%Total time: ~5,2F min" (/ (sum *RUNTIMES*) 60)))
))




;;; ======= H E L P E R S ======= ;;;
(defun table-header (header location)
  (with-open-file (outfile (ensure-directories-exist location) :direction :output :if-exists :append :if-does-not-exist :create)
                  (format outfile "~A~%" header)))
                  

;; TODO: Eventually remove
(defun write-fixations-table (data &optional (location (concatenate 'string *output-dir* "/fixations.txt")))
  (with-open-file (outfile (ensure-directories-exist location) :direction :output :if-exists :append :if-does-not-exist :create)
                  (format outfile "~:{~&~S ~D ~S ~D ~S ~D~}" data)
                  (format outfile "~%")
                  ;; data must contain:
                  ; experiment simulation item wordnum wordname dur
                  ))

(defun write-attachments-table (data &optional (location (concatenate 'string *output-dir* "/attachments.txt")))
  (with-open-file (outfile (ensure-directories-exist location) :direction :output :if-exists :append :if-does-not-exist :create)
                  (format outfile "~:{~&~S ~D ~S ~D ~S ~D~}" data)
                  (format outfile "~%")
                  ;; data must contain:
                  ; experiment simulation item wordnum wordname dur
                  ))

(defun write-encodings-table (data &optional (location (concatenate 'string *output-dir* "/enctimes.txt")))
  (with-open-file (outfile (ensure-directories-exist location) :direction :output :if-exists :append :if-does-not-exist :create)
                  (format outfile "~:{~&~S ~D ~S ~D ~S ~D ~5,3F ~5,5F~}" data)
                  (format outfile "~%")
                  ;; data must contain:
                  ; experiment simulation item wordnum wordname enctime
                  ;   ecc freq
                  ))

(defun write-timeouts-table (data &optional (location (concatenate 'string *output-dir* "/timeouts.txt")))
  (with-open-file (outfile (ensure-directories-exist location) :direction :output :if-exists :append :if-does-not-exist :create)
                  (format outfile "~:{~&~S ~D ~S ~D ~S ~D~}" data)
                  (format outfile "~%")
                  ;; data must contain:
                  ; experiment simulation item wordnum wordname eye-pos
                  ))

(defun write-trialmessage-table (data &optional (location (concatenate 'string *output-dir* "/trialmessages.txt")))
  (with-open-file (outfile (ensure-directories-exist location) :direction :output :if-exists :append :if-does-not-exist :create)
                  (format outfile "~:{~&~S ~D ~S ~D ~S ~S ~S~}" data)
                  (format outfile "~%")
                  ;; data must contain:
                  ; experiment simulation item wordnum word var val
                  ))




;;; (MACROS:
;;; The simplest way to generate a form in the body of your macro expander is to use 
;;; the backquote (`) reader macro. This behaves like the quote (') reader macro, 
;;; except for when a comma (,) appears in the backquoted form.
;;; Like quote, backquote suppresses evaluation. But a comma within a backquoted form 
;;; "unsuppresses" evaluation for just the following subform.)