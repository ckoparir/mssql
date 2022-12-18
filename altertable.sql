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

-- Database Name
DECLARE @db NVARCHAR(100) = N'testapi';             

-- Table Name
DECLARE @tbl NVARCHAR(100) = N'PosSatislari';    

---------------------------------------------------------------------

/****************************** WARNING ! ***************************
*                                                                   * 
*    DO NOT CHANGE ANY PARAMETER IN THE CODE BELOW                  * 
*                                                                   * 
********************************************************************/

DECLARE @table NVARCHAR(200) = @db + N'.dbo.' + @tbl;
DECLARE @tmp NVARCHAR(250) = @table + N'_temp';
DECLARE @sql NVARCHAR(MAX) = N'';

SET NOCOUNT ON;

BEGIN TRY

   BEGIN TRAN

   SET @sql = CONCAT(N'USE ', @db);
   EXEC(@sql);

   -- Drop temporary table if it exists
   PRINT('Dropping exisiting temp table');
   IF OBJECT_ID(@tmp, N'U') IS NOT NULL 
      SET @sql = CONCAT(N'DROP TABLE ', @tmp);
      EXEC(@sql);

   -- Insert data and table structure from source table to the temporary table
   PRINT('Copying original table to temp table');
   SET @sql = CONCAT(N'SELECT * INTO ', @tmp, N' FROM ', @table);
   EXEC(@sql); 

   -- Altering table  to add new GUID Primary Key column 
   PRINT('Adding new UniqueID Column to temp table');
   SET @sql = CONCAT(N'ALTER TABLE ', @tmp, N' ADD UQID UNIQUEIDENTIFIER PRIMARY KEY NOT NULL DEFAULT NEWID()');
   EXEC(@sql);

   --SET @sql = CONCAT(N'SELECT * FROM ', @tmp);
   --EXEC(@sql) 

   SET @sql = CONCAT(N'DROP TABLE ', @table, '; ', N' EXEC sp_rename  ', @tbl, '_temp, ', @tbl);
   EXEC(@sql) 

   COMMIT TRAN

END TRY
BEGIN CATCH

   IF @@TRANCOUNT > 0
      ROLLBACK TRAN

   DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
   DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
   DECLARE @ErrorState INT = ERROR_STATE()

   RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

END CATCH

SET NOCOUNT OFF;