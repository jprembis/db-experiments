#!/bin/python3

import random

"""Generate tuples for the marks relation"""

s_ids = ['00128', '12345', '19991', '23121', '44553', '45678',
         '54321', '55739', '76543', '76653', '98765', '98988']

cum_weights = [.1, .3, .6, 1.]  # linear distribution
grades = range(len(cum_weights))
for id in s_ids:
    k = random.randrange(5)
    for grade in random.choices(grades, cum_weights=cum_weights, k=k):
        match grade:
            case 0: l, u = 0, 39    # F [0, 40)
            case 1: l, u = 40, 59   # C [40, 60)
            case 2: l, u = 60, 79   # B [60, 80)
            case 3: l, u = 80, 100  # A [80, 100]
        score = random.randrange(l, 1+u)
        print(f"insert into marks values ('{id}', {score});")
