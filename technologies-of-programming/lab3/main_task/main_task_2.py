from datetime import datetime

year = int(input("Your year of birth: "))
month = int(input("Your month of birth: : "))
day = int(input("Your day of birth: "))

time_in_seconds = (datetime.now() - datetime(year=year, month=month, day=day)).total_seconds()

print("You are {} seconds old.".format(time_in_seconds))
