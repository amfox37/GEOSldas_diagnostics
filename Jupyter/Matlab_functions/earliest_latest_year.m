clear all

% Define the start and end dates
start_month = 4;
start_year = 2015;
end_month = 3;
end_year = 2021;

w_days = 75;

run_months = [1:12 1:ceil(w_days/30)];
cnt = 0;
% Loop over the months
for month = run_months
    % Initialize the earliest and latest year variables
    cnt = cnt + 1;
    
     % Check if the current year/month combination is earlier than the earliest
        if datenum(start_year, month, 1) < datenum(start_year, start_month, 1)
            earliest_year(cnt) = start_year+1;
        else
            earliest_year(cnt) = start_year;
        end
        
        % Check if the current year/month combination is later than the latest
        if datenum(end_year, month, 1) > datenum(end_year, end_month,1)
            latest_year(cnt) = end_year-1;
        else
            latest_year(cnt) = end_year;
        end
    
end
