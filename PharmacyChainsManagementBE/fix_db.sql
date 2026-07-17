DECLARE @ConstraintName nvarchar(200)
SELECT @ConstraintName = Name FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('USER') AND parent_column_id = (SELECT column_id FROM sys.columns WHERE name = 'must_change_password' AND object_id = OBJECT_ID('USER'))
IF @ConstraintName IS NOT NULL
   EXEC('ALTER TABLE [USER] DROP CONSTRAINT ' + @ConstraintName)

IF EXISTS(SELECT 1 FROM sys.columns WHERE name = 'must_change_password' AND object_id = OBJECT_ID('USER'))
   ALTER TABLE [USER] DROP COLUMN [must_change_password]

IF NOT EXISTS(SELECT 1 FROM [__EFMigrationsHistory] WHERE MigrationId = '20260712153705_SeedRolesAndUsers')
   INSERT INTO [__EFMigrationsHistory] (MigrationId, ProductVersion) VALUES ('20260712153705_SeedRolesAndUsers', '8.0.0')
