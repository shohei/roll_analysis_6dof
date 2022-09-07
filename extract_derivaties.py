import re
import pandas as pd
# import pdb

def get_df(string_array):
    headers = []
    df = pd.DataFrame()
    for i, line in enumerate(string_array):
        line = line.strip()
        cols = re.split('\s+',line)
        if(i==0):
            headers = cols
        else:
            _df = pd.DataFrame([cols], columns=headers)
            df = df.append(_df)
    return df

s = open('for006.dat').read()
page23 = s.split('PAGE  23')[1].split('PAGE  24')[0]
page27 = s.split('PAGE  27')[1].split('PAGE  28')[0]
# print(page23)
# print(page27)
static_string_array = page23\
            .split('---------- DERIVATIVES (PER DEGREE) ----------')[1] \
            .split('PANEL DEFLECTION ANGLES (DEGREES)')[0]\
            .strip()\
            .split('\n')
dynamic_string_array = page27\
            .split('------------ DYNAMIC DERIVATIVES (PER DEGREE) -----------')[1]\
            .split('YAW AND ROLL')[0]\
            .strip()\
            .split('\n')
static_df = get_df(static_string_array)
dynamic_df = get_df(dynamic_string_array)
df = static_df.merge(dynamic_df, how='left', on='ALPHA')
print(df)

