SET NOCOUNT ON

-- Define the len of the printed row
DECLARE @stringLen INT = 100 
 
-- An input text
DECLARE @string NVARCHAR(max) = N'
Full backup: This is a copy of all data in the database, including the transaction log. Using this backup type, you can restore the database to the point in time when the backup was taken. It is the most basic of the backups and is often required prior to any of the other backup types. When restoring from a full database backup, all the database files are restored without any other dependencies, the database is available, and it is transactionally consistent. Partial backup: This is a way to back up only those parts of the database that change. This reduces the size of the backup and the time it takes to backup and restore. It is a copy of the primary filegroup and read/write filegroups. To take advantage of this type of backup, you need to group together the tables that change into a set of filegroups and the tables that are static or history in a different set of filegroups. The filegroups containing historical data 
will be marked read/write or read-only. A partial backup normally includes the primary filegroup and read-write filegroups, but read-only filegroups can optionally be included. A partial backup can speed up the backup process for databases with large read-only areas. For example, a large database may have archival data that does not change, so there is no need to back it up every time, which reduces the amount of data to back up. File/filegroup backup: This is a copy of selected files or filegroups of a database. This method is typically used for large databases for which it is not feasible to do a full database backup. A transaction-log backup is needed with this backup type if the backup includes read/write files or filegroups. The challenge is maintaining the files, filegroups, and transaction-log backups because larger databases have many files and filegroups. It also requires more steps to restore the database. ➤
Differential backup: This is a copy of all the data that has changed since the last full backup. The SQL Server 2012 backup process identifies each changed extent and backs it up. Differentials are cumulative: If you do a full backup on Sunday night, the differential taken on Monday night includes all the changes since Sunday night. If you take another differential on Tuesday night, it includes all the changes since Sunday night. When restoring, you would restore the last full database backup and the most recent differential backup. Then you would restore any transaction-log backups since the last differential. This can mean quicker recovery. Whether differentials are good for you depends on what percentage of rows change between full database backups. As the percentage of rows changed approaches the number of rows in the database, the differential backup gets closer to the size of an entire database backup. When this occurs, it is often better to get another full database backup and start a new differential. Another benefit to use differentials is realized when a group of rows is repeatedly changed. Remember that a transaction log backup includes each change that is made. The differen- tial backup includes only the last change for a row. Imagine a database that keeps track of 100 stock values. The stock value is updated every minute. Each row is updated 1,440 times per day. Consider a full database backup on Sunday night and transaction-log back- ups during the week. At the end of the day Friday, restoring from all the transaction logs would mean that you have to replay each change to each row. In this case, each row would be updated 7,200 times (1,440 times/day times 5 days). When you include 100 stocks, the restore would have to replay 720,000 transactions. If you had done a differential backup at the end of each day, you would have to replace only the 100 rows. The differential keeps the most recent version only; and in some situations, it can be a great solution. Partial differential backup: This works the same as a differential backup but is matched to data from a partial backup. It is a copy of all extents modified since the last partial backup. To restore requires the partial backup. 
File differential backup: This is a copy of the file or filegroup of all extents modified since the last file or filegroup backup. A transaction-log backup is required after this backup for read/ write files or filegroups. Moreover, after the restore, you need to restore the transaction log as well. Using the file backup and file differential backup methods increases the complexity of the restore procedures. Furthermore, it may take longer to restore the complete database. Copy-only backup: This can be made for the database or transaction log. The copy-only backup does not interfere with the normal backup restore procedures. A normal full database backup resets the differential backups made afterward, whereas a copy-only backup does not affect the next differential backup; it still contains the changes since the last full backup. A copy-only backup of the transaction log does not truncate the log or affect the next normal transaction log backup. Copy-only backups are useful when you want to make a copy of the database for testing or development purposes without affecting the restore process. Copy- only backups are not supported in SSMS and must be done via T-SQL.'

-- Trim the spaces and New-Row chars from the input tring
SELECT @string = 	REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(@string, NCHAR(10), N' ')
								, NCHAR(13), N' ')
							, N'  ', ' ')
						, N'  ', N' ')

 ;WITH ListOfIds(ID) AS ( SELECT -1 + ROW_NUMBER() OVER(ORDER BY(SELECT NULL) ) FROM SYS.columns )
	  ,ListOfCuttedRows(Id, RowText) AS (SELECT Id, SUBSTRING(@string, ID * @stringLen, @stringLen ) FROM ListOfIds )
	  ,DirtyRows AS (SELECT RowText = SUBSTRING(RowText, ISNULL((CHARINDEX(N' ', RowText)), 1), @stringLen)
						  , Id
						  , FirstWordInRow = LEFT(RowText, (CHARINDEX(N' ', RowText))) 
					   FROM ListOfCuttedRows
					  WHERE RowText IS NOT NULL
					    AND LTRIM ( RowText ) <> ''  )
	  SELECT RowText = RowText + LAG(FirstWordInRow, 1, '') OVER ( ORDER BY ID DESC)
	    FROM DirtyRows
	ORDER BY Id
