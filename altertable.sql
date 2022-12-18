/********************************************************************
* This SQL script aims to alter existing mssql table to add         *
* new column has type GUID with primary key.                        *
*                                                                   *
* The script backups existing table before altering it but          *
* you should backup whole database before running this              *
* script.                                                           *
*                                                                   *
* @2022                                                             *
* GoSync_AlterTable.sql                                             *
* ckoparir@gmail.com                                                *
*                                                                   *
*********************************************************************/

-------------------- Enter Table and Database Names ------------------ 

-- Table Name
DECLARE @table NVARCHAR(100) = N'PosSatislari';    

---------------------------------------------------------------------

/****************************** WARNING ! ***************************
*                                                                   * 
*    DO NOT CHANGE ANY PARAMETER IN THE CODE BELOW                  * 
*                                                                   * 
********************************************************************/

DECLARE @tmp NVARCHAR(250) = @table + N'_temp';
DECLARE @sql NVARCHAR(MAX) = N'';

SET NOCOUNT ON;

BEGIN TRY

   BEGIN TRAN

   -- Drop temporary table if it exists
   PRINT('Dropping exisiting temp table');
   IF OBJECT_ID(@tmp, N'U') IS NOT NULL 
      SET @sql = CONCAT(N'DROP TABLE ', @tmp);
      EXEC(@sql);

   -- Insert data and table structure from source table to the temporary table
   PRINT('Copying original table to temp table');
   SET @sql = CONCAT(N'SELECT * INTO ', @tmp, N' FROM ', @table);
   EXEC(@sql); 

   -- Adding new GUID (UQID) column 
   PRINT('Adding new UniqueID GUID (UQID) column...');
   SET @sql = CONCAT(N'ALTER TABLE ', @tmp, N' ADD UQID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()');
   EXEC(@sql);

   /*
   -- Dropping primary key
   PRINT('Dropping primary key...');
   SET @sql = CONCAT(N'ALTER TABLE ', @tmp, CHAR(13), N'DROP CONSTRAINT PK_PosSatislari;');
   EXEC(@sql);
   */

   -- Dropping original table
   PRINT('Dropping ' + @table + '...');
   SET @sql = CONCAT(N'DROP TABLE ', @table)
   EXEC(@sql) 

   -- Adding primary key
   PRINT('Adding primary keys...');
   SET @sql = CONCAT(N'ALTER TABLE ', @tmp, CHAR(13), N'ADD CONSTRAINT PK_', @table, N' Primary Key (ID, UQID)');
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

SET NOCOUNT OFF;