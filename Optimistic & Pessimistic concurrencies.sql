Pessimistic concurrency control (SQL Default)  locks resources as they are required, for the duration of a transaction. 
Optimistic concurrency control allows transactions to execute without locking any resources.


-- for more details:
http://technet.microsoft.com/en-us/library/aa213031(v=sql.80).aspx
Optimistic concurrency control uses cursors. 
Pessimistic concurrency control is the default for SQL Server.

Optimistic concurrency control works on the assumption that resource conflicts between
multiple users are unlikely (but not impossible), and allows transactions to execute
without locking any resources. Only when attempting to change data are resources checked 
to determine if any conflicts have occurred. If a conflict occurs, the application must 
read the data and attempt the change again.


Pessimistic concurrency control locks resources as they are required, for the duration 
of a transaction. Unless deadlocks occur, a transaction is assured of successful completion.
