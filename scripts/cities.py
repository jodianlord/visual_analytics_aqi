import os, csv

directory = r'C:\\Users\\jodia\\Documents\\visual_analytics_aqi\\datasets\\Air Quality Index'
header_written = False
master_header = ['date', 'pm25', 'pm10', 'o3', 'no2', 'so2', 'co', 'aqi', 'city', 'country']
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
    #print("Country: ", country)

    # Extract City
    if "united-states" in filename or "united-kingdom" in filename:
        second_last_slash_index = filename.rfind('-', 0, filename.rfind('-'))
        city = filename[0:second_last_slash_index]
    else:
        last_dash_index = filename.rindex('-')
        city = filename[0:last_dash_index]

    #print("City: ", city)

    # Write each row of each file to all_cities.csv
    with open(entry.path, newline='', mode='r') as in_file, open('all_cities.csv', newline='', mode='a') as out_file:
        aqireader = csv.reader(in_file)
        citywriter = csv.writer(out_file, delimiter=',')
        fileheader = [] #Headers for the current file being read, initialise as blank

        for row in aqireader:
            # remove spaces in each value
            for index_i, header in enumerate(row):
                row[index_i] = header.strip()

            # if first row in file not written, write the master headers
            if not header_written:
                citywriter.writerow(master_header)
                header_written = True

            # if first row in file, strip all the spaces and store it as the fileheader, then go to next row
            if row[0] == "date":
                fileheader = row
                for i in fileheader:
                    i.strip()
                continue

            # empty array the size of the master header to store the row to be written
            writerow = [None] * len(master_header)
            #print("FileHeader: ", fileheader)

            # iterate through row
            for rowindex, item in enumerate(row):
                # identify the item value (date, o3, no2 etc being read)
                value_head = fileheader[rowindex]

                # get the index of this item according to the master header
                master_index = master_header.index(value_head)

                # store it at the index of the row to be written
                if item == 0 or item is None:
                    writerow[master_index] = "0"
                else:
                    writerow[master_index] = item
            # get index of city and country
            master_city_index = master_header.index('city')
            master_country_index = master_header.index('country')
            
            # write city and country to the row
            writerow[master_city_index] = city
            writerow[master_country_index] = country
            #print("Written Row: ", writerow)
            citywriter.writerow(writerow)