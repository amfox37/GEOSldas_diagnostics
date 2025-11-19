from days_in_month import days_in_month
from pentad_of_year import pentad_of_year

def get_dofyr_pentad(date_time):
    """
    Compute DOY (day of year) and pentad for the given date.
    
    Args:
    date_time: dict, representing the date and time. It must contain the following keys:
               year: int, the year (e.g., 2023)
               month: int, the month (1 = January, 2 = February, etc.)
               day: int, the day of the month
    
    Returns:
    date_time: dict, with the following new keys added:
               dofyr: int, the day of the year (1 = January 1)
               pentad: int, the pentad of the year (1 = Jan 1-5)
    """
    # Compute DOY
    date_time['dofyr'] = date_time['day']
    for i in range(1, date_time['month']):
        date_time['dofyr'] += days_in_month(date_time['year'], i)
    
    # Compute pentad
    date_time['pentad'] = pentad_of_year(date_time['dofyr'], date_time['year'])
    
    return date_time
