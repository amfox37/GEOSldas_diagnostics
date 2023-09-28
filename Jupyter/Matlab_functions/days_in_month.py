from is_leap_year import is_leap_year


def days_in_month(year, month):
    """
    Determine the number of days in a given month, accounting for leap years.
    
    Args:
    year: int, the year in question
    month: int, the month in question (1 = January, 2 = February, etc.)
    
    Returns:
    n_days: int, the number of days in the given month
    """
    days_in_month_leap = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    days_in_month_nonleap = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    if is_leap_year(year):
        n_days = days_in_month_leap[month-1]
    else:
        n_days = days_in_month_nonleap[month-1]
    
    return n_days
