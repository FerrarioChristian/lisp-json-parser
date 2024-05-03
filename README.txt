La funzione jsonparse accetta una stringa di dati JSON come input
e tenta di parsarla in una struttura di dati Common Lisp. Se l'input non è
una stringa, la funzione restituisce il messaggio di errore "Errore nella 
lettura del file!" La funzione quindi converte la stringa di input in una
lista di caratteri e rimuove eventuali caratteri speciali utilizzando la 
funzione removespecialchars.
La funzione quindi controlla il primo e l'ultimo carattere della lista per
determinare se si tratta di un oggetto o di un array. Se il primo e l'ultimo
carattere sono parentesi graffe {}, chiama la funzione parsemembers
e rimuove le parentesi. Se il primo e l'ultimo carattere sono parentesi quadre
[], chiama la funzione arrayparse e rimuove le parentesi.
Se il primo e l'ultimo carattere non sono parentesi graffe o quadre, la funzione
restituisce il messaggio di errore "Errore di sintassi".

La funzione parsemembers accetta come input una lista di token, un
accumulatore e due interi (aperte e chiuse). 
Se la lista di token e l'accumulatore sono entrambi nulli, restituisce nil.
Se solo la lista di token è nulla, restituisce la coppia parsata.
Se l'ultimo token è una virgola e l'accumulatore è nullo, genera un messaggio
di errore "Argomento mancante!".
Se il token è una virgola e il valore di aperte è uguale a chiuse, restituisce
la coppia parsata e chiama la funzione parsemembers sul resto della tokenlist.
Se il token è una parentesi quadra aperta o una parentesi graffa aperta, chiama
la funzione parsemembers sul resto della tokenlist.
Se il token è una parentesi quadra chiusa o una parentesi graffa chiusa, chiama
la funzione parsemembers sul resto della lista di token e invia il token 
all'accumulatore e incrementa il contatore 'chiuse'.
Se l'accumulatore è nullo o il valore di aperte non è uguale a chiuse, chiama
la funzione parsemembers sul resto della tokenlist.

La funzione parsepair accetta una lista di token come input e
restituisce una coppia di una stringa e un valore. Se la lista di token è nullo,
la funzione restituisce nil. Se il primo token non è una stringa, la funzione
genera il messaggio di errore "Attributo non una stringa!". 
Se il secondo token non è ":", la funzione genera il messaggio di errore "Non è una coppia!".
Se il primo token è una stringa e il secondo token è ":", la funzione restituisce
una lista contenente il primo token come chiave e il risultato della chiamata della
funzione parsevalue sul resto della lista token come valore.

La funzione parsevalue accetta una lista di token come input. Se il primo
token è una parentesi graffa di apertura e l'ultimo token è una parentesi graffa di
chiusura, la funzione chiama la funzione parsemembers e rimuove le parentesi.
Se il primo token è una parentesi quadra aperta e l'ultimo token è una parentesi
quadra chiusa, la funzione chiama la funzione arrayparse e rimuove le parentesi.
Se il resto della tokenlist non è vuoto, la funzione lancia il messaggio di errore
"valore non accettato!" Se il primo token è una stringa,
la funzione restituisce il primo token. Se il primo token è un numero, la funzione
restituisce il primo token. Se il primo token non è una stringa o un numero,
la funzione lancia il messaggio di errore "valore non accettato!"

La funzione arrayparse accetta come input una lista di token, un accumulatore e due interi
(aperte e chiuse). La funzione controlla la fine della lista di token, se la lista di token
e l'accumulatore sono entrambi nulli, restituisce nil. Se solo la lista di token è nullo,
restituisce il valore parsato. Se l'ultimo token è una virgola e l'accumulatore è nullo,
genera il messaggio di errore "Manca argomento!". Se il token è una virgola e il valore di
aperte è uguale a chiuse, restituisce il valore parsato e chiama la funzione arrayparse
sul resto della tokenlist. Se il token è una parentesi aperta o una parentesi quadra aperta,
chiama la funzione arrayparse sul resto della lista di token e invia il token 
all'accumulatore e agli incrementi il valore delle aperte.
Se il token è una parentesi di chiusura o una parentesi quadra di chiusura,
chiama la funzione arrayparse sul resto della tokenlist e invia il token 
all'accumulatore e incrementa il valore di chiuse. Se l'accumulatore è nullo
o il valore di aperte non è uguale a chiuse, continua a chiamare la funzione
arrayparse sul resto della tokenlist. Se nessuna di queste condizioni è soddisfatta,
genera il messaggio di errore "Errore di sintassi".

La funzione jsonaccess consente di accedere ai campi di un oggetto JSON. Prende in input
un oggetto JSON, un campo opzionale e una serie di campi opzionali. Se non viene specificato
alcun campo, la funzione restituirà l'intero oggetto JSON. Se il primo campo specificato
è un numero, la funzione accederà all'elemento dell'array JSON corrispondente. Se il primo
campo specificato è una stringa, la funzione accederà al campo dell'oggetto JSON corrispondente.
Se vengono specificati più campi, la funzione accederà ai campi successivi nidificati 
all'interno del primo campo specificato.

La funzione processsubstrings è utilizzata per elaborare una lista di caratteri, accumulando
i caratteri che si trovano tra le virgolette e restituendo una stringa una volta che le
virgolette vengono chiuse. Prende in input una lista di caratteri, un accumulatore vuoto
e un contatore. Il contatore tiene traccia delle virgolette aperte e chiuse. Quando il 
contatore raggiunge 2, l'accumulatore viene convertito in una stringa e restituito.

La funzione processnumbers prende in input tre parametri: "elements", "accumulator" e "counter".
La funzione esegue una serie di controlli sui valori di input e restituisce un output in base
a questi controlli.
Se sia "elements" che "accumulator" sono "null", la funzione restituisce "nil"
Se "elements" è "null" e "accumulator" contiene un valore, la funzione converte il valore in 
"accumulator" in un numero utilizzando la funzione "stringtonumber" e restituisce una lista
contenente il numero convertito.
Se "elements" è una stringa, la funzione restituisce una lista contenente la stringa in "elements"
e richiama la funzione sulla coda di "elements" e "accumulator"
Se "elements" è un numero, la funzione aggiunge il numero in "elements" all'accumulatore e
richiama la funzione sulla coda di "elements" e "accumulator".