; 
;	Ferrario Christian	886230
;	Bonfanti Davide 		873293
;

(defun jsonparse (JSONString)
  (if (not (stringp JSONString)) (error "Errore nella lettura del file.")
      (let ((list (removespecialchars (coerce JSONString 'list))))
        (cond ((and (eq (car list) #\{) (eq (car (last list)) #\}))
               (cons 'jsonobj (parsemembers (removebrackets list) nil 0 0))) 
              ((and (eq (car list) #\[) (eq (car (last list)) #\])) 
               (cons 'jsonarray (arrayparse (removebrackets list) nil 0 0)))
              (T (error "Errore di sintassi."))))))

(defun parsemembers (tokenlist accumulator aperte chiuse)
  (cond ((and (null tokenlist) (null accumulator)) nil)
        ((null tokenlist) (list (parsepair accumulator)))
        ((eq (car (last tokenlist)) #\,) (error "Argomento mancante."))
        ((and (eq (car tokenlist) #\,) (= aperte chiuse))
         (cons (parsepair accumulator)
               (parsemembers (cdr tokenlist) nil aperte chiuse)))
        ((or (eq (car tokenlist) #\{) (eq (car tokenlist) #\[)) 
         (parsemembers (cdr tokenlist)
                       (arraypush (car tokenlist) accumulator)
                       (incf aperte) chiuse))
        ((or (eq (car tokenlist) #\}) (eq (car tokenlist) #\])) 
         (parsemembers (cdr tokenlist)
                       (arraypush (car tokenlist) accumulator)
                       aperte (incf chiuse)))
        (T (parsemembers (cdr tokenlist)
                         (arraypush (car tokenlist) accumulator)
                         aperte chiuse))))


(defun parsepair (tokenlist)
  (when tokenlist
    when (stringp (car tokenlist))
    when (eq (cadr tokenlist) #\:)
    (list (car tokenlist) (parsevalue (cdr (cdr 
                                            tokenlist
                                            ))))))

(defun parsevalue (value)
  (cond ((and (eq (first value) #\{) (eq (car (last value)) #\}))
         (cons
          'jsonobj 
          (parsemembers (removebrackets value) nil 0 0)))
        ((and (eq (first value) #\[) (eq (car (last value)) #\]))
         (cons
          'jsonarray 
          (arrayparse (removebrackets value) nil 0 0)))
        ((not (eq (cdr value) nil)) (error "Valore non accettato."))
        ((stringp (car value)) (car value))
        ((numberp (car value)) (car value))
        (T (error "Valore non accettato."))))

(defun arrayparse (tokenlist accumulator aperte chiuse)
  (cond ((eq (car (last tokenlist)) #\,) (error "Argomento mancante."))
        ((and (null tokenlist) (null accumulator)) nil)
        ((null tokenlist) (list (parsevalue accumulator)))
        ((and (eq (car tokenlist) #\,) (= aperte chiuse))
         (cons (parsevalue accumulator)
               (arrayparse (cdr tokenlist) nil aperte chiuse)))
        ((or (eq (car tokenlist) #\{) (eq (car tokenlist) #\[)) 
         (arrayparse (cdr tokenlist)
                     (arraypush (car tokenlist) accumulator)
                     (incf aperte) chiuse))
        ((or (eq (car tokenlist) #\}) (eq (car tokenlist) #\])) 
         (arrayparse (cdr tokenlist)
                     (arraypush (car tokenlist) accumulator)
                     aperte (incf chiuse)))
        ((or (null accumulator) (not (= aperte chiuse)))
         (arrayparse (cdr tokenlist)
                     (arraypush (car tokenlist) accumulator)
                     aperte chiuse))
        (T (error "Errore di sintassi."))))

(defun removespecialchars (list)
  (remove-if (lambda (x) (member x '(#\Return #\Space #\Newline #\Tab)))
             (processnumbers 
              (processsubstrings 
               (substitute #\" #\' list)
               nil 0)
              nil)))


(defun removebrackets (list)
  (butlast (cdr list)))

(defun processsubstrings (charlist accumulator counter)
  (cond ((and (null charlist) (null accumulator)) nil)
        ((null charlist) (cons (coerce accumulator 'string) nil))
        ((eq (car charlist) #\")
         (processsubstrings (cdr charlist) accumulator (+ 1 counter)))
        ((= counter 0)
         (cons (car charlist)
               (processsubstrings (cdr charlist)
                                  accumulator
                                  counter)))
        ((= counter 1)
         (processsubstrings (cdr charlist)
                            (arraypush (car charlist) accumulator)
                            counter))
        ((= counter 2)
         (cons (coerce accumulator 'string)
               (processsubstrings charlist nil 0)))        
        ((eq (car charlist) #\")
         (processsubstrings (cdr charlist)
                            (arraypush (car charlist) accumulator)
                            (+ 1 counter)))
        (T (error "Errore di sintassi."))))


(defun processnumbers (elements accumulator)
  (cond ((and (null elements) (null accumulator)) nil)
        ((null elements) (cons (stringtonumber
                                (coerce accumulator 'string))
                               nil))
        ((and (or (eq (car elements) #\,)
                  (eq (car elements) #\})
                  (eq (car elements) #\]))
              (not (null accumulator))) 
         (cons (stringtonumber
                (coerce accumulator 'string))
               (processnumbers elements nil)))
        ((stringp (car elements))
         (cons (car elements)
               (processnumbers (cdr elements) accumulator))) 
        ((isnumber (car elements)) 
         (processnumbers (cdr elements)
                         (arraypush (car elements) accumulator)))
        ((or 
          (null accumulator) 
          (null (isnumber (cadr elements))))
         (cons (car elements)
               (processnumbers (cdr elements) accumulator)))
        (T (error "Errore di sintassi."))))

(defun stringtonumber (string)
  (if (null (find #\. string))
      (parse-integer string)
      (parse-float string)))

(defun arraypush (element l)
  (if (null l)
      (list element)
      (cons (first l) (arraypush element (rest l)))))

(defun isnumber (element)
  (member element '(#\. #\+ #\- #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9 #\0)))


(defun jsonaccess (obj &optional field &rest fields)
  (cond ((null field) obj)
        ((null obj) nil)
        ((and (eq 'jsonarray (first obj))
              (null fields))
         (if (listp field)
             (nth (car field) (rest obj))
             (nth field (rest obj))))
        ((and (eq 'jsonobj (first obj))
              (null fields)
              (listp field))
         (jsonaccess obj (car field)))
        ((and (eq 'jsonobj (first obj))
              (null fields))
         (car (cdr (assoc field (rest obj) :test #'equal))))
        ((not (null fields))
         (cond ((listp (car fields))
                (if (numberp field)
                    (retrievevalue (nth field (cdr obj)) (car fields))
                    (retrievevalue (car (cdr (assoc field (rest obj) :test #'equal)))
                                   (car fields))))
               (T (if (numberp field)
                      (retrievevalue (nth field (cdr obj)) fields)
                      (retrievevalue (car (cdr (assoc field (rest obj) :test #'equal)))
                                     fields)))))
        (T (pprint "Error."))))


(defun retrievevalue (obj fields)
  (cond ((null obj) nil)
        ((= (length fields) 1) (jsonaccess obj fields))
        ((stringp (car fields))
         (jsonaccess (car (cdr
                           (assoc (car fields) (rest obj) :test #'equal)))
                     (second fields)
                     (cdr (cdr fields))))
        (T (retrievevalue (nth (car fields) (cdr obj)) (cdr fields)))))

(defun objreverse (jsonobj jsonstring)
  (cond ((and (null jsonobj) (eq (char jsonstring 0) #\{))
         (car (list (concatenate 'string
                                 (string-right-trim
                                  ", " jsonstring) "}"))))	
        ((null jsonobj) nil)
        ((eq (car jsonobj) 'jsonarray)
         (arrayreverse jsonobj ""))
        ((eq (car jsonobj) 'jsonobj)
         (objreverse (cdr jsonobj)
                     (concatenate 'string jsonstring "{")))
        ((ignore-errors (eq (car (car (cdr (car jsonobj)))) 'jsonobj))
         (objreverse (cdr jsonobj)
                     (concatenate 'string jsonstring
                                  "\"" (car (car jsonobj)) "\"" " : "
                                  (objreverse (car (cdr (car jsonobj))) "")
                                  ", ")))
        ((ignore-errors (eq (car (car (cdr (car jsonobj)))) 'jsonarray))
         (objreverse (cdr jsonobj)
                     (concatenate 'string jsonstring
                                  "\"" (car (car jsonobj)) "\"" " : "
                                  (arrayreverse (car (cdr (car jsonobj))) "")
                                  ", ")))
        (T (if (numberp (car (cdr (car jsonobj))))
               (objreverse (cdr jsonobj)
                           (concatenate 'string jsonstring
                                        "\"" (car (car jsonobj)) "\"" " : "
                                        (write-to-string (car (cdr (car jsonobj))))
                                        ", "))
               (objreverse (cdr jsonobj)
                           (concatenate 'string jsonstring
                                        "\"" (car (car jsonobj)) "\"" " : "
                                        "\"" (car (cdr (car jsonobj))) "\""
                                        ", "))))))

(defun arrayreverse (jsonarray jsonstring)
  (cond ((and (null jsonarray) (eq (char jsonstring 0) #\[))
         (car (list (concatenate 'string
                                 (string-right-trim ", " jsonstring) "]"))))
        ((null jsonarray) nil)
        ((eq (car jsonarray) 'jsonarray)
         (arrayreverse (cdr jsonarray) (concatenate 'string jsonstring "[")))
        ((ignore-errors (eq (car (car jsonarray)) 'jsonobj))
         (arrayreverse (cdr jsonarray)
                       (concatenate 'string jsonstring
                                    (objreverse (car jsonarray) "") ", ")))
        ((ignore-errors (eq (car (car jsonarray)) 'jsonarray))
         (arrayreverse (cdr jsonarray)
                       (concatenate 'string jsonstring
                                    (arrayreverse (car jsonarray) "") ", ")))
        (T (if (numberp (car jsonarray))
               (arrayreverse (cdr jsonarray)
                             (concatenate 'string jsonstring
                                          (write-to-string (car jsonarray))
                                          ", "))
               (arrayreverse (cdr jsonarray)
                             (concatenate 'string jsonstring
                                          "\"" (car jsonarray) "\"" ", "))))))

(defun jsonread (filename)
  (with-open-file (in filename
                      :if-does-not-exist :error
                      :direction :input)
    (jsonparse (readchars in))))

(defun readchars (inputstream)
  (let ((json (read-char inputstream nil 'eof)))
    (if (eq json 'eof) ""
        (string-append json (readchars inputstream)))))

(defun jsondump (jsonobj filename)
  (with-open-file (out filename
                       :direction :output
                       :if-exists :supersede
                       :if-does-not-exist :create)
    (format out (objreverse jsonobj ""))))