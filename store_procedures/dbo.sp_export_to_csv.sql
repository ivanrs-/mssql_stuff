USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_export_to_csv]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_export_to_csv]
(	
	@database varchar(100),
	@schema   varchar(20),
	@table	  varchar(100),
	@output   varchar(150)
)
AS
BEGIN
--Generate column names as a recordset
declare @columns varchar(8000), @sql varchar(8000), @data_file varchar(100)
select 
	@columns=coalesce(@columns+',','')+column_name+' as '+column_name 
from 
	information_schema.columns
where 
	table_name=@table
select @columns=''''''+replace(replace(@columns,' as ',''''' as '),',',',''''')

--Generate column names in dummy headers file
set @sql='exec master..xp_cmdshell ''bcp " select * from (select '+@columns+') as t" queryout "'+@output+'_headers.csv " -T -c -t,'''
exec(@sql)

--Generate data in the dummy content file
set @sql='exec master..xp_cmdshell ''bcp "select * from '+@database+'.'+@schema+'.'+@table+'" queryout "'+@output+'_content.csv" -c  -T -t,'''
exec(@sql)

--Generate final output by joining headers and content files
set @sql= 'exec master..xp_cmdshell ''copy /b "'+@output+'_headers.csv"+"'+@output+'_content.csv" "'+@output+'"'''
exec(@sql)

--Delete headers and content temp files
set @sql= 'exec master..xp_cmdshell ''del '+@output+'_headers.csv'''
exec(@sql)
set @sql= 'exec master..xp_cmdshell ''del ' +@output+'_content.csv'''
exec(@sql)

END
