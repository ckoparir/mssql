/*---------------------------------------------------------------
This SQL script aims to alter existing mssql table to add
new column has type GUID with primary key.

The script backups existing table before altering it but
you should backup whole database before running this
script.

This script will be run in a batch file on Windows Systems
and works with Microsoft Sql Server 2014 and later versions.

Example  : 
______________________________________________________________

   ./run.bat 

   Enter Server IP or Hostname   : example.com
   Enter database name           : testdb
   Enter username                : username

   Connecting example.com...

   Password                      : <Password for testdb database>

______________________________________________________________

Date     : 20.12.2022
Filename : altertable.sql
Author   : ckoparir@gmail.com
---------------------------------------------------------------*/

DECLARE @table NVARCHAR(100);

SET NOCOUNT ON;

-- Fetch all table names into cursor
DECLARE db_cursor CURSOR FOR
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME NOT LIKE '%_temp'

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @table

WHILE @@FETCH_STATUS = 0 
BEGIN
   DECLARE @col NVARCHAR(100) = N'';    
   DECLARE @sql NVARCHAR(MAX) = N'';
   DECLARE @tmp NVARCHAR(250) = @table + N'_temp';

   BEGIN TRY

      BEGIN TRAN

      /*
      -- Drop temporary table if it exists
      PRINT('Dropping existing temptable: ' + @tmp);
      IF OBJECT_ID(@tmp, N'U') IS NOT NULL 
         SET @sql = CONCAT(N'DROP TABLE ', @tmp);
         EXEC(@sql);
      */

      SET @col = (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@table AND ORDINAL_POSITION=1);

      -- Insert data and table structure from source table to the temporary table
      PRINT('Copying original table: ' + @table);
      SET @sql = CONCAT(N'SELECT * INTO ', @tmp, N' FROM ', @table);
      EXEC(@sql); 

      -- Adding new GUID (UQID) column 
      PRINT('Adding new UniqueID GUID (UQID) column...');
      SET @sql = CONCAT(N'ALTER TABLE ', @tmp, N' ADD UQID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()');
      EXEC(@sql);

      -- Dropping original table
      PRINT('Dropping ' + @table + '...');
      SET @sql = CONCAT(N'DROP TABLE ', @table)
      EXEC(@sql) 

      -- Adding primary key
      PRINT('Adding primary keys...');
      SET @sql = CONCAT(N'ALTER TABLE ', @tmp, CHAR(13), N'ADD CONSTRAINT PK_', @table, N' Primary Key (', @col, N', UQID);');
      EXEC(@sql);

      -- Renaming temparary table to original tablename
      PRINT('Renaming ' + @tmp + ' to ' + @table + '...');
      SET @sql = CONCAT(N'EXEC sp_rename  ', @table, '_temp, ', @table);
      EXEC(@sql) 

      COMMIT TRAN

   END TRY
   BEGIN CATCH

      IF @@TRANCOUNT > 0
      BEGIN
         PRINT('Rollback all process...!');
         ROLLBACK TRAN
      END

      DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
      DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
      DECLARE @ErrorState INT = ERROR_STATE()

      RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

   END CATCH
   FETCH NEXT FROM db_cursor INTO @table
END

CLOSE db_cursor
DEALLOCATE db_cursor

SET NOCOUNT OFF;