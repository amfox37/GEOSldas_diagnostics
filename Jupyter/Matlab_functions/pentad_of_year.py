from is_leap_year import is_leap_year

def pentad_of_year(day_of_year, year):
    """
    Compute the pentad of the year for the given day of year and year.
    
    Args:
    day_of_year: int, the day of the year (1 = January 1)
    year: int, the year (e.g., 2023)
    
    Returns:
    pentad: int, the pentad of the year (1 = Jan 1-5)
    """
    if is_leap_year(year) and day_of_year >= 59:
        pentad = (day_of_year - 2) // 5 + 1
    else:
        pentad = (day_of_year - 1) // 5 + 1
    
    return pentad
