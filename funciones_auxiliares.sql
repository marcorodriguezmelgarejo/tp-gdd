create function dbo.maximoDecimal18_2(@val1 decimal(18,2), @val2 decimal(18,2))
returns decimal(18,2)
as
begin
  if @val1 > @val2
    return @val1
  return @val2
end