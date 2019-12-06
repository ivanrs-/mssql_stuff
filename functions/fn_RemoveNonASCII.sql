USE [{DataBase}]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_RemoveNonASCII]    Script Date: 12/6/2019 9:38:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_RemoveNonASCII]
(
   @nstring nvarchar(4000)
)
RETURNS nvarchar(4000)
AS
BEGIN

    DECLARE @Result nvarchar(4000)
    SET @Result = ''

    DECLARE @nchar nvarchar(1)
    DECLARE @position int

    SET @position = 1
    WHILE @position <= LEN(@nstring)
   BEGIN
        SET @nchar = SUBSTRING(@nstring, @position, 1)
        --Unicode & ASCII are the same from 1 to 255.
        --Only Unicode goes beyond 255
        --0 to 31 are non-printable characters
        --If it's not valid char, then it's replaced with a space
        IF UNICODE(@nchar) between 32 and 255 and UNICODE(@nchar) != 124
         SET @Result = @Result + @nchar
	ELSE
		SET @Result = @Result + ' '
        SET @position = @position + 1
    END

    RETURN @Result

END
