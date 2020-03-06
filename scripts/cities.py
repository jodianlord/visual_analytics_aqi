import os, csv

directory = r'C:\\Users\\jodia\\Documents\\visual_analytics_aqi\\datasets\\Air Quality Index'
header_written = False
for entry in os.scandir(directory):
    # Extract Filename
    last_slash_index = entry.path.rindex('\\') + 1
    filename = entry.path[last_slash_index:]
    
    # Extract Country
    dot_index = filename.index('.')
    country_slash_index = filename.rindex('-') + 1
    country = filename[country_slash_index:dot_index]
    country = country.capitalize()

    if country == "States":
        country = "United States"
    elif country == "Kingdom":
        country = "United Kingdom"
    
    print("Filename: " + filename)
    print("Country: ", country)

    # Extract City
    if "united-states" in filename or "united-kingdom" in filename:
        second_last_slash_index = filename.rfind('-', 0, filename.rfind('-'))
        city = filename[0:second_last_slash_index]
    else:
        last_dash_index = filename.rindex('-')
        city = filename[0:last_dash_index]

    print("City: ", city)

    # Write each row of each file to all_cities.csv
    with open(entry.path, newline='', mode='r') as in_file, open('all_cities.csv', newline='', mode='a') as out_file:
        aqireader = csv.reader(in_file)
        citywriter = csv.writer(out_file, delimiter=',')
        for row in aqireader:
            for index_i, header in enumerate(row):
                row[index_i] = header.strip()
            if not header_written:
                row.append('city')
                row.append('country')
                print("First row: ", row)
                citywriter.writerow(row)
                header_written = True
            else:
                if row[0] == "date":
                    continue
                row.append(city)
                row.append(country)
                citywriter.writerow(row)