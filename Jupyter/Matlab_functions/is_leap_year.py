def is_leap_year(year):
    """
    Determine whether a given year is a leap year.
    
    Args:
    year: int, must be scalar
    
    Returns:
    leap: int, 0 if year is not a leap year, 1 if year is a leap year
    """
    if not isinstance(year, int):
        raise ValueError('error, input to is_leap_year() must be scalar, exiting...')
        
    if year % 4 != 0:
        leap = 0
    elif year % 400 == 0:
        leap = 1
    elif year % 100 == 0:
        leap = 0
    else:
        leap = 1
        
    return leap