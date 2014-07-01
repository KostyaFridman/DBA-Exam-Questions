-- Factorial function
-- x*y*z = 10^lg(x) * 10^lg(y) *10^lg(z) =  10 ^ (lg(x) + lg(y) + lg(z))

DECLARE @FactorialNumber SMALLINT = 5

SELECT POWER(10.0, SUM(LOG10(Number)))
  FROM (
	SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Number
	  FROM sys.objects
	  ) Z
  WHERE Number <= @FactorialNumber
